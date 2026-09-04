import 'dart:async';
import 'dart:isolate';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:astro_astrologer/core/constants/app_urls.dart';
import 'package:astro_astrologer/core/services/websocket/websocket_service.dart';
import 'package:astro_astrologer/core/services/local_notification_service.dart';
import 'package:astro_astrologer/core/services/foreground_task_service.dart';
import 'package:astro_astrologer/core/widgets/custom_image_widget.dart';
import 'package:astro_astrologer/features/chat/presentation/controllers/chat_controller.dart';
import 'package:astro_astrologer/core/services/callkit_service.dart';

class FloatingChatBubble {
  static final RxInt unreadCount = 0.obs;
  static int? sessionId;
  static String? name;
  static VoidCallback? onTapCallback;
  static final RxString chatStatus = 'initiated'.obs;

  static final RxBool _isActive = false.obs;
  static bool get isActive => _isActive.value;

  static StreamSubscription? _overlaySub;
  static const MethodChannel _appRetainChannel = MethodChannel(
    'com.suryapath.astrologer/app_retain',
  );

  static ReceivePort? _receivePort;

  static void _setupIsolatePort() {
    if (_receivePort != null) return;
    _receivePort = ReceivePort();
    IsolateNameServer.removePortNameMapping('overlay_chat_port');
    IsolateNameServer.registerPortWithName(
      _receivePort!.sendPort,
      'overlay_chat_port',
    );
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
    BuildContext? context,
    required int sessionId,
    required String name,
    required String imageUrl,
    String? startedAt,
    required String status,
    required VoidCallback onTap,
  }) async {
    debugPrint(
      "==== [DEBUG LOG ASTRO] FloatingChatBubble.show called for sessionId=$sessionId, status=$status ====",
    );
    _setupIsolatePort();

    // Listen for foreground task tap events
    ForegroundTaskService.listenTaskData((data) {
      if (data is Map && data['action'] == 'tap') {
        onTapCallback?.call();
      }
    });

    if (_isActive.value && FloatingChatBubble.sessionId == sessionId) {
      debugPrint(
        "==== [DEBUG LOG ASTRO] FloatingChatBubble already active for sessionId=$sessionId. Updating status to $status ====",
      );
      chatStatus.value = status;
      onTapCallback =
          onTap; // Always refresh the tap callback so latest logic is used
      return;
    }

    FloatingChatBubble.sessionId = sessionId;
    FloatingChatBubble.name = name;
    unreadCount.value = 0;
    onTapCallback = onTap;
    chatStatus.value = status;
    _isActive.value = true;
    debugPrint(
      "==== [DEBUG LOG ASTRO] FloatingChatBubble set _isActive = true for sessionId=$sessionId ====",
    );

    try {
      int? startedAtMillis;
      DateTime? startedAtDate;
      if (startedAt != null && startedAt.isNotEmpty) {
        String isoUtc = startedAt.trim().replaceAll(' ', 'T');
        bool hasTimezone = isoUtc.endsWith('Z') || isoUtc.contains(RegExp(r'[+-]\d{2}(:?\d{2})?$'));
        
        if (!hasTimezone) {
          isoUtc += 'Z';
        }
        
        DateTime? parsed = DateTime.tryParse(isoUtc)?.toLocal();
        if (parsed != null) {
          final now = DateTime.now();
          if (!parsed.isAfter(now)) {
            startedAtDate = parsed;
          }
        }
        
        if (startedAtDate == null) {
           DateTime? fallbackParsed = DateTime.tryParse(startedAt.trim().replaceAll(' ', 'T')) ?? DateTime.tryParse(startedAt.trim());
           startedAtDate = fallbackParsed?.toLocal();
        }
      }

      final normalizedStatus = status.toLowerCase();
      if (normalizedStatus == 'ongoing' || normalizedStatus == 'accepted') {
        // Start persistent silent notification with timer
        await ForegroundTaskService.startActiveSessionNotification(
          title: 'Active Chat with $name',
          type: 'Chat',
          startedAt: startedAtDate,
        );
      } else {
        // For ringing/initiated, if we want to show a waiting state notification, we could.
        // For now, we only show persistent notification for ongoing session.
        await ForegroundTaskService.stopService();
      }
    } catch (e) {
      debugPrint("FloatingChatBubble show notification error: $e");
    }
  }

  static Future<void> dismiss({bool stopForegroundService = true}) async {
    _isActive.value = false;
    final int? idToCancel = sessionId;
    sessionId = null;
    onTapCallback = null;
    unreadCount.value = 0;
    _overlaySub?.cancel();
    _overlaySub = null;

    if (stopForegroundService) {
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

  // Allow ChatController to sync its timer if the bubble was already running
  static int get currentElapsedSeconds => _currentElapsedSeconds;
  static int _currentElapsedSeconds = 0;
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
  State<FloatingChatBubbleWidget> createState() =>
      _FloatingChatBubbleWidgetState();
}

class _FloatingChatBubbleWidgetState extends State<FloatingChatBubbleWidget> {
  Timer? _timer;
  final RxInt _elapsedSeconds = 0.obs;

  @override
  void initState() {
    super.initState();
    // Sync initially if the bubble already had a value (though usually it starts at 0 or syncs from _setupTimer)
    _elapsedSeconds.value = FloatingChatBubble._currentElapsedSeconds;
    
    // Listen to changes and update the static variable
    ever(_elapsedSeconds, (val) {
      FloatingChatBubble._currentElapsedSeconds = val;
    });
    
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
    
    // Check if the string already has a timezone indicator like Z or +05:30
    bool hasTimezone = isoUtc.endsWith('Z') || isoUtc.contains(RegExp(r'[+-]\d{2}(:?\d{2})?$'));
    
    if (!hasTimezone) {
      isoUtc += 'Z';
    }

    DateTime? parsed = DateTime.tryParse(isoUtc)?.toLocal();
    if (parsed != null) {
      final now = DateTime.now();
      // If adding Z made it in the future, it means the original string was likely already Local Time.
      if (!parsed.isAfter(now)) {
        return parsed;
      }
    }

    // Fallback: Parse without Z
    parsed = DateTime.tryParse(dateStr.replaceAll(' ', 'T')) ?? DateTime.tryParse(dateStr);
    return parsed?.toLocal();
  }

  void _startTimer() {
    void updateDuration() {
      final actualStr =
          widget.startedAt ??
          WebSocketService.sessionStartTimes[widget.sessionId];
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
    final String initial =
        name.trim().isNotEmpty ? name.trim()[0].toUpperCase() : 'U';
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
            // If this is the session we just accepted, force the status to ongoing
            // so that ChatScreen doesn't show the incoming popup again.
            if (CallkitService.lastAcceptedSessionId ==
                FloatingChatBubble.sessionId?.toString()) {
              FloatingChatBubble.chatStatus.value = 'ongoing';
            }
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
                    child:
                        (widget.imageUrl.trim().isNotEmpty && widget.imageUrl != 'null')
                            ? CustomImageWidget(
                              imagePath: widget.imageUrl,
                              width: 36,
                              height: 36,
                              fit: BoxFit.cover,
                              fallbackWidget: _buildInitialAvatar(widget.name),
                              errorBuilder:
                                  (_, __, ___) =>
                                      _buildInitialAvatar(widget.name),
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
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.25),
                              borderRadius: BorderRadius.circular(6),
                              border: Border.all(
                                color: Colors.white.withOpacity(0.4),
                                width: 0.8,
                              ),
                            ),
                            child: const Text('CHAT'.tr,
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
                        final currentStatus =
                            FloatingChatBubble.chatStatus.value;
                        if (currentStatus == 'initiated' ||
                            currentStatus == 'ringing' ||
                            currentStatus == 'waiting') {
                          return const Text('Incoming Chat Request...'.tr,
                            style: TextStyle(
                              color: Colors.white70,
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                            ),
                          );
                        }
                          // Evaluate both to ensure Obx registers listeners for both
                          // Otherwise if ChatController is deleted, Obx gets stuck because
                          // it was only listening to ChatController's elapsedSeconds.
                          final fallbackTime = _elapsedSeconds.value;
                          final timeToDisplay = Get.isRegistered<ChatController>()
                              ? Get.find<ChatController>().elapsedSeconds.value
                              : fallbackTime;

                          return Text(
                            'Active Chat • ${_formatDuration(timeToDisplay)}',
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
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: const Text('Return'.tr,
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
