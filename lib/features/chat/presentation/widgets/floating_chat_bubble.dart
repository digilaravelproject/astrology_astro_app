import 'dart:async';
import 'dart:isolate';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:astro_astrologer/core/constants/app_urls.dart';
import 'package:astro_astrologer/core/services/network/websocket_service.dart';
import 'package:astro_astrologer/core/services/local_notification_service.dart';
import 'package:astro_astrologer/core/services/foreground_task_service.dart';


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
    debugPrint("==== [DEBUG LOG ASTRO] FloatingChatBubble.show called for sessionId=$sessionId, status=$status ====");
    _setupIsolatePort();
    
    if (_isActive.value && FloatingChatBubble.sessionId == sessionId) {
      debugPrint("==== [DEBUG LOG ASTRO] FloatingChatBubble already active for sessionId=$sessionId. Updating status to $status ====");
      chatStatus.value = status;
      return;
    }
    
    FloatingChatBubble.sessionId = sessionId;
    FloatingChatBubble.name = name;
    unreadCount.value = 0;
    onTapCallback = onTap;
    chatStatus.value = status;
    _isActive.value = true;
    debugPrint("==== [DEBUG LOG ASTRO] FloatingChatBubble set _isActive = true for sessionId=$sessionId ====");

    try {
      // Kill any old foreground task service to prevent 2 notifications
      ForegroundTaskService.stopService();

      int? startedAtMillis;
      if (startedAt != null && startedAt.isNotEmpty) {
        String isoUtc = startedAt.trim().replaceAll(' ', 'T');
        if (!isoUtc.endsWith('Z') && !isoUtc.contains('+') && !isoUtc.contains('-')) {
          isoUtc += 'Z';
        }
        startedAtMillis = DateTime.tryParse(isoUtc)?.toLocal().millisecondsSinceEpoch;
      }

      LocalNotificationService.showOngoingChatNotification(
        sessionId: sessionId,
        title: status == 'ongoing' ? '$name • Chat' : 'Incoming Chat Request from $name',
        body: 'Tap to return to chat session',
        startedAtMillis: startedAtMillis,
      );
    } catch (e) {
      debugPrint("FloatingChatBubble show notification error: $e");
    }
  }

  static Future<void> dismiss({bool stopForegroundService = true}) async {
    debugPrint("==== [DEBUG LOG ASTRO] FloatingChatBubble.dismiss called! stopForegroundService=$stopForegroundService, currentSessionId=$sessionId, caller trace: ${StackTrace.current} ====");
    _isActive.value = false;
    final int? idToCancel = sessionId;
    sessionId = null;
    onTapCallback = null;
    unreadCount.value = 0;
    _overlaySub?.cancel();
    _overlaySub = null;

    if (stopForegroundService) {
      try {
        await LocalNotificationService.cancelOngoingChatNotification(idToCancel);
      } catch (_) {}
      try {
        await ForegroundTaskService.stopService();
      } catch (_) {}
    }
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
    super.key,
    required this.sessionId,
    required this.name,
    required this.imageUrl,
    this.startedAt,
  });

  @override
  State<FloatingChatBubbleWidget> createState() => _FloatingChatBubbleWidgetState();
}

class _FloatingChatBubbleWidgetState extends State<FloatingChatBubbleWidget> {
  Timer? _timer;
  final RxInt _elapsedSeconds = 0.obs;

  @override
  void initState() {
    super.initState();
    _startTimer();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  DateTime? _parseSmartDate(dynamic input) {
    if (input == null) return null;
    if (input is DateTime) return input.toLocal();
    final dateStr = input.toString().trim();
    if (dateStr.isEmpty) return null;

    String isoUtc = dateStr.replaceAll(' ', 'T');
    if (!isoUtc.endsWith('Z') && !isoUtc.contains('+') && !isoUtc.contains('-')) {
      isoUtc += 'Z';
    }

    DateTime? parsed = DateTime.tryParse(isoUtc)?.toLocal();
    if (parsed == null) {
      parsed = DateTime.tryParse(dateStr)?.toLocal();
    }

    if (parsed == null) return null;

    final now = DateTime.now();
    if (parsed.isAfter(now)) {
      final offsetDate = parsed.subtract(now.timeZoneOffset);
      if (!offsetDate.isAfter(now)) {
        return offsetDate;
      }
    }

    return parsed;
  }

  void _startTimer() {
    void updateDuration() {
      final actualStr = widget.startedAt ?? WebSocketService.sessionStartTimes[widget.sessionId];
      final startedAt = _parseSmartDate(actualStr);
      if (startedAt != null) {
        final diff = DateTime.now().difference(startedAt).inSeconds;
        if (diff >= 0) {
          _elapsedSeconds.value = diff;
        } else {
          _elapsedSeconds.value++;
        }
      } else {
        _elapsedSeconds.value++;
      }
    }

    updateDuration();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      final currentStatus = FloatingChatBubble.chatStatus.value.toLowerCase();
      if (currentStatus == 'ongoing' || currentStatus == 'accepted') {
        updateDuration();
      }
    });
  }

  String _formatDuration(int totalSeconds) {
    final int minutes = totalSeconds ~/ 60;
    final int seconds = totalSeconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  Widget _buildInitialAvatar(String name) {
    final String initial = name.trim().isNotEmpty ? name.trim()[0].toUpperCase() : 'U';
    return Container(
      width: 36,
      height: 36,
      alignment: Alignment.center,
      decoration: const BoxDecoration(
        color: Colors.white,
        shape: BoxShape.circle,
      ),
      child: Text(
        initial,
        style: const TextStyle(
          color: Color(0xFFE65100),
          fontWeight: FontWeight.bold,
          fontSize: 16,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFFE65100), Color(0xFFFF6F00)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(color: Colors.black26, blurRadius: 8, offset: Offset(0, 3)),
        ],
      ),
      child: SafeArea(
        bottom: false,
        child: GestureDetector(
          onTap: () {
            FloatingChatBubble.onTapCallback?.call();
          },
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            child: Row(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(18),
                  child: Container(
                    width: 36,
                    height: 36,
                    decoration: const BoxDecoration(
                      color: Colors.white24,
                      shape: BoxShape.circle,
                    ),
                    child: widget.imageUrl.trim().isNotEmpty
                        ? Image.network(
                            widget.imageUrl,
                            width: 36,
                            height: 36,
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) => _buildInitialAvatar(widget.name),
                          )
                        : _buildInitialAvatar(widget.name),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Row(
                        children: [
                          Flexible(
                            child: Text(
                              widget.name,
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.25),
                              borderRadius: BorderRadius.circular(6),
                              border: Border.all(color: Colors.white.withOpacity(0.4), width: 0.8),
                            ),
                            child: const Text(
                              'CHAT',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 10,
                                fontWeight: FontWeight.w700,
                                letterSpacing: 0.5,
                              ),
                            ),
                          ),
                        ],
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
                          'Active Chat • ${_formatDuration(_elapsedSeconds.value)}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        );
                      }),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: const Text(
                    'Return',
                    style: TextStyle(
                      color: Color(0xFFE65100),
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
