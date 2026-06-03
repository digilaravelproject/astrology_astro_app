import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:astro_astrologer/core/constants/app_urls.dart';
import 'package:astro_astrologer/core/services/network/websocket_service.dart';
import 'package:flutter_overlay_window/flutter_overlay_window.dart';

class FloatingChatBubble {
  static final RxInt unreadCount = 0.obs;
  static int? sessionId;
  static String? name;
  static VoidCallback? onTapCallback;
  static final RxString chatStatus = 'initiated'.obs;

  static bool _isActive = false;
  static bool get isActive => _isActive;

  static Future<void> show({
    required BuildContext context,
    required int sessionId,
    required String name,
    required String imageUrl,
    String? startedAt,
    required String status,
    required VoidCallback onTap,
  }) async {
    FloatingChatBubble.sessionId = sessionId;
    FloatingChatBubble.name = name;
    unreadCount.value = 0;
    onTapCallback = onTap;
    chatStatus.value = status;
    _isActive = true;

    try {
      final bool isGranted = await FlutterOverlayWindow.isPermissionGranted();
      if (!isGranted) {
        await FlutterOverlayWindow.requestPermission();
      }

      if (await FlutterOverlayWindow.isActive()) {
        await FlutterOverlayWindow.shareData({
          'type': 'update',
          'sessionId': sessionId,
          'name': name,
          'imageUrl': imageUrl,
          'status': status,
          'unreadCount': 0,
        });
      } else {
        await FlutterOverlayWindow.showOverlay(
          enableDrag: true,
          overlayTitle: "Chat Bubble",
          overlayContent: "Ongoing chat",
          flag: OverlayFlag.defaultFlag,
          visibility: NotificationVisibility.visibilityPublic,
          positionGravity: PositionGravity.auto,
          height: 250,
          width: 250,
        );
        
        await FlutterOverlayWindow.shareData({
          'type': 'init',
          'sessionId': sessionId,
          'name': name,
          'imageUrl': imageUrl,
          'status': status,
          'startedAt': startedAt,
          'unreadCount': 0,
        });

        // Listen for tap events from overlay
        FlutterOverlayWindow.overlayListener.listen((event) {
          if (event != null && event is Map && event['action'] == 'tap') {
            onTapCallback?.call();
          }
        });
      }
    } catch (e) {
      debugPrint("FloatingChatBubble show error: $e");
    }
  }

  static Future<void> dismiss() async {
    _isActive = false;
    sessionId = null;
    onTapCallback = null;
    unreadCount.value = 0;
    try {
      if (await FlutterOverlayWindow.isActive()) {
        await FlutterOverlayWindow.closeOverlay();
      }
    } catch (_) {}
  }

  static void incrementUnreadCount() {
    unreadCount.value++;
    _syncData();
  }

  static void updateStatus(String status) {
    chatStatus.value = status;
    _syncData();
  }

  static Future<void> _syncData() async {
    if (_isActive) {
      try {
        if (await FlutterOverlayWindow.isActive()) {
          await FlutterOverlayWindow.shareData({
            'type': 'update',
            'status': chatStatus.value,
            'unreadCount': unreadCount.value,
          });
        }
      } catch (_) {}
    }
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
    if (xPosition < 0) xPosition = 0;
    if (xPosition > size.width - 80) xPosition = size.width - 80;
    if (yPosition < 40) yPosition = 40;
    if (yPosition > size.height - 100) yPosition = size.height - 100;

    return Positioned(
      left: xPosition,
      top: yPosition,
      child: GestureDetector(
        onPanUpdate: (details) {
          setState(() {
            xPosition += details.delta.dx;
            yPosition += details.delta.dy;
          });
        },
        onTap: () {
          FloatingChatBubble.onTapCallback?.call();
        },
        child: Material(
          type: MaterialType.transparency,
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              Container(
                width: 65,
                height: 65,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black26,
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ],
                  border: Border.all(
                    color: const Color(0xFFFF6F00), // Saffron border
                    width: 2.5,
                  ),
                ),
                child: ClipOval(
                  child: widget.imageUrl.isNotEmpty
                      ? Image.network(
                          widget.imageUrl.startsWith('http')
                              ? widget.imageUrl
                              : '${AppUrls.baseImageUrl}${widget.imageUrl}',
                          fit: BoxFit.cover,
                          errorBuilder: (c, e, s) => _buildInitials(),
                        )
                      : _buildInitials(),
                ),
              ),
              
              // Timing overlay
              Positioned(
                bottom: -4,
                left: 0,
                right: 0,
                child: Center(
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: const Color(0xFF2E1A47), // Deep Violet
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Obx(() {
                      final currentStatus = FloatingChatBubble.chatStatus.value;
                      if (currentStatus == 'initiated' || currentStatus == 'ringing') {
                        return const Text(
                          'Waiting',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 9,
                            fontWeight: FontWeight.bold,
                          ),
                        );
                      }
                      return Text(
                        _formatDuration(_elapsedSeconds.value),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 9,
                          fontWeight: FontWeight.bold,
                        ),
                      );
                    }),
                  ),
                ),
              ),
              
              // Unread count badge
              Obx(() {
                final count = FloatingChatBubble.unreadCount.value;
                if (count <= 0) return const SizedBox.shrink();
                return Positioned(
                  top: -2,
                  right: -2,
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: const BoxDecoration(
                      color: Colors.red,
                      shape: BoxShape.circle,
                    ),
                    constraints: const BoxConstraints(
                      minWidth: 18,
                      minHeight: 18,
                    ),
                    child: Center(
                      child: Text(
                        '$count',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 9,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                );
              }),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInitials() {
    final String initial = widget.name.isNotEmpty ? widget.name[0].toUpperCase() : 'C';
    return Container(
      color: const Color(0xFF2E1A47),
      child: Center(
        child: Text(
          initial,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 22,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}
