import 'dart:async';
import 'dart:isolate';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:astro_astrologer/core/constants/app_urls.dart';
import 'package:astro_astrologer/core/services/network/websocket_service.dart';
import 'package:astro_astrologer/core/services/local_notification_service.dart';


class FloatingChatBubble {
  static final RxInt unreadCount = 0.obs;
  static int? sessionId;
  static String? name;
  static VoidCallback? onTapCallback;
  static final RxString chatStatus = 'initiated'.obs;

  static final RxBool _isActive = false.obs;
  static bool get isActive => _isActive.value;
  
  static StreamSubscription? _overlaySub;
  static const MethodChannel _appRetainChannel = MethodChannel('com.suryapath.astrologer/app_retain');

  static ReceivePort? _receivePort;

  static void _setupIsolatePort() {
    if (_receivePort != null) return;
    _receivePort = ReceivePort();
    IsolateNameServer.removePortNameMapping('overlay_chat_port');
    IsolateNameServer.registerPortWithName(_receivePort!.sendPort, 'overlay_chat_port');
    _receivePort!.listen((message) async {
      if (message == 'tap') {
        debugPrint("==== OVERLAY TAPPED VIA ISOLATE PORT ====");
        try {
          debugPrint("==== ATTEMPTING TO BRING TO FOREGROUND ====");
          await _appRetainChannel.invokeMethod('bringToForeground');
          debugPrint("==== BROUGHT TO FOREGROUND SUCCESS ====");
        } catch (e) {
          debugPrint("==== Error bringing app to foreground: $e ====");
        }
        Future.delayed(const Duration(milliseconds: 500), () {
          debugPrint("==== CALLING ON TAP CALLBACK ====");
          onTapCallback?.call();
        });
      }
    });
  }

  static Future<void> show({
    required BuildContext context,
    required int sessionId,
    required String name,
    required String imageUrl,
    String? startedAt,
    required String status,
    required VoidCallback onTap,
  }) async {
    _setupIsolatePort();
    
    if (_isActive && FloatingChatBubble.sessionId == sessionId) {
      // Just update status if already active
      chatStatus.value = status;
      return;
    }
    
    FloatingChatBubble.sessionId = sessionId;
    FloatingChatBubble.name = name;
    unreadCount.value = 0;
    onTapCallback = onTap;
    chatStatus.value = status;
    _isActive.value = true;

    try {
      // Show system notification banner instead of FlutterOverlayWindow
      LocalNotificationService.showOngoingChatNotification(
        sessionId: sessionId,
        title: status == 'ongoing' ? 'Active Chat with $name' : 'Incoming Chat Request from $name',
        body: 'Tap to return to chat session',
      );
    } catch (e) {
      debugPrint("FloatingChatBubble show notification error: $e");
    }
  }

  static Future<void> dismiss() async {
    _isActive.value = false;
    if (sessionId != null) {
      try {
        LocalNotificationService.cancelOngoingChatNotification(sessionId!);
      } catch (_) {}
    }
    sessionId = null;
    onTapCallback = null;
    unreadCount.value = 0;
    _overlaySub?.cancel();
    _overlaySub = null;
  }

  static void incrementUnreadCount() {
    unreadCount.value++;
  }

  static void updateStatus(String status) {
    chatStatus.value = status;
  }
}

class FloatingChatBubbleWidget extends StatefulWidget {
  final int sessionId;
  final String name;
  final String imageUrl;
  final String? startedAt;

  const FloatingChatBubbleWidget({
    Key? key,
    required this.sessionId,
    required this.name,
    required this.imageUrl,
    this.startedAt,
  }) : super(key: key);

  @override
  State<FloatingChatBubbleWidget> createState() => _FloatingChatBubbleWidgetState();
}

class _FloatingChatBubbleWidgetState extends State<FloatingChatBubbleWidget> {
  double xPosition = 20.0;
  double yPosition = 120.0;
  Timer? _timer;
  final RxInt _elapsedSeconds = 0.obs;

  @override
  void initState() {
    super.initState();
    _startTimer(widget.startedAt);
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _startTimer(String? startedAtStr) {
    if (startedAtStr != null && startedAtStr.isNotEmpty) {
      try {
        final startedAt = DateTime.tryParse(startedAtStr)?.toLocal();
        if (startedAt != null) {
          final now = DateTime.now();
          final diff = now.difference(startedAt).inSeconds;
          _elapsedSeconds.value = diff > 0 ? diff : 0;
        }
      } catch (_) {}
    }
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      final currentStatus = FloatingChatBubble.chatStatus.value;
      if (currentStatus == 'ongoing') {
        final actualStartedAtStr = widget.startedAt ?? WebSocketService.sessionStartTimes[widget.sessionId];
        if (actualStartedAtStr != null && actualStartedAtStr.isNotEmpty) {
          try {
            final startedAt = DateTime.tryParse(actualStartedAtStr)?.toLocal();
            if (startedAt != null) {
              final diff = DateTime.now().difference(startedAt).inSeconds;
              _elapsedSeconds.value = diff > 0 ? diff : 0;
            } else {
              _elapsedSeconds.value++;
            }
          } catch (_) {
            _elapsedSeconds.value++;
          }
        } else {
          _elapsedSeconds.value++;
        }
      }
    });
  }

  String _formatDuration(int totalSeconds) {
    final int minutes = totalSeconds ~/ 60;
    final int seconds = totalSeconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.of(context).size;
    
    // Constraints to keep bubble inside screen bounds
    return Positioned(
      top: MediaQuery.of(context).padding.top + 8,
      left: 12,
      right: 12,
      child: GestureDetector(
        onTap: () {
          FloatingChatBubble.onTapCallback?.call();
        },
        child: Material(
          elevation: 6,
          borderRadius: BorderRadius.circular(30),
          color: const Color(0xFF1E1E2C),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            decoration: BoxDecoration(
              color: const Color(0xFF1E1E2C),
              borderRadius: BorderRadius.circular(30),
              border: Border.all(color: const Color(0xFFFF6F00).withValues(alpha: 0.5), width: 1),
            ),
            child: Row(
              children: [
                const Icon(Icons.call, color: Colors.greenAccent, size: 20),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        widget.name,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 2),
                      Obx(() {
                        final currentStatus = FloatingChatBubble.chatStatus.value;
                        if (currentStatus == 'initiated' || currentStatus == 'ringing' || currentStatus == 'waiting') {
                          return const Text(
                            'Incoming Chat Request...',
                            style: TextStyle(
                              color: Colors.white70,
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                            ),
                          );
                        }
                        return Text(
                          _formatDuration(_elapsedSeconds.value),
                          style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 12,
                          ),
                        );
                      }),
                    ],
                  ),
                ),
                GestureDetector(
                  onTap: () {
                    FloatingChatBubble.dismiss();
                  },
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: const BoxDecoration(
                      color: Colors.redAccent,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.call_end, color: Colors.white, size: 18),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInitials() {
    final String initial = widget.name.isNotEmpty ? widget.name[0].toUpperCase() : 'A';
    return Container(
      color: const Color(0xFFFF6F00),
      child: Center(
        child: Text(
          initial,
          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
        ),
      ),
    );
  }
}
