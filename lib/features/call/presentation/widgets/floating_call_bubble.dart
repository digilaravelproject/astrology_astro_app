import 'dart:async';
import 'dart:isolate';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:flutter_overlay_window/flutter_overlay_window.dart';
import 'package:astro_astrologer/features/call/presentation/pages/call_screen.dart';
import 'package:astro_astrologer/core/services/local_notification_service.dart';
import 'package:astro_astrologer/core/services/foreground_task_service.dart';
import 'package:astro_astrologer/features/call/presentation/controllers/call_controller.dart';

class FloatingCallBubble {
  static int? sessionId;
  static String? name;
  static VoidCallback? onTapCallback;
  static final RxString callStatus = 'initiated'.obs;

  static final RxBool _isActive = false.obs;
  static bool get isActive => _isActive.value;
  
  static StreamSubscription? _overlaySub;
  static const MethodChannel _appRetainChannel = MethodChannel('com.suryapath.astrologer/app_retain');

  static ReceivePort? _receivePort;

  static void _setupIsolatePort() {
    if (_receivePort != null) return;
    _receivePort = ReceivePort();
    IsolateNameServer.removePortNameMapping('overlay_call_port');
    IsolateNameServer.registerPortWithName(_receivePort!.sendPort, 'overlay_call_port');
    _receivePort!.listen((message) async {
      if (message == 'tap') {
        debugPrint("==== CALL OVERLAY TAPPED VIA ISOLATE PORT ====");
        try {
          debugPrint("==== ATTEMPTING TO BRING APP TO FOREGROUND FOR CALL ====");
          await _appRetainChannel.invokeMethod('bringToForeground');
        } catch (e) {
          debugPrint("==== Error bringing app to foreground: $e ====");
        }
        Future.delayed(const Duration(milliseconds: 500), () {
          debugPrint("==== CALLING CALL ON TAP CALLBACK ====");
          if (onTapCallback != null) {
            onTapCallback?.call();
          } else {
            FloatingCallBubble.dismiss();
            Get.to(() => const CallScreen());
          }
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
    
    if (_isActive.value && FloatingCallBubble.sessionId == sessionId) {
      callStatus.value = status;
      _syncData();
      return;
    }
    FloatingCallBubble.sessionId = sessionId;
    FloatingCallBubble.name = name;
    onTapCallback = onTap;
    callStatus.value = status;
    _isActive.value = true;

    try {
      final String statusText = (status == 'ongoing') 
          ? '$name • Call' 
          : 'Incoming Call / Calling $name ($status)...';

      



      if (await FlutterOverlayWindow.isActive()) {
        await FlutterOverlayWindow.shareData({
          'type': 'update',
          'sessionId': sessionId,
          'name': name,
          'imageUrl': imageUrl,
          'status': status,
          'isCall': true,
          'unreadCount': 0,
        });
      }
    } catch (e) {
      debugPrint("FloatingCallBubble show error: $e");
    }
  }

  static Future<void> dismiss({bool stopForegroundService = true}) async {
    _isActive.value = false;
    final int? idToCancel = sessionId;
    sessionId = null;
    onTapCallback = null;
    _overlaySub?.cancel();
    _overlaySub = null;

    if (stopForegroundService) {
      
      try {
        await ForegroundTaskService.stopService();
      } catch (_) {}
    }
    try {
      if (await FlutterOverlayWindow.isActive()) {
        await FlutterOverlayWindow.closeOverlay();
      }
    } catch (_) {}
  }

  static void updateStatus(String status) {
    callStatus.value = status;
    _syncData();
  }

  static Future<void> _syncData() async {
    if (_isActive.value) {
      try {
        if (await FlutterOverlayWindow.isActive()) {
          await FlutterOverlayWindow.shareData({
            'type': 'update',
            'status': callStatus.value,
            'isCall': true,
            'unreadCount': 0,
          });
        }
      } catch (_) {}
    }
  }
}

class FloatingCallBubbleWidget extends StatefulWidget {
  final int sessionId;
  final String name;
  final String imageUrl;
  final String? startedAt;

  const FloatingCallBubbleWidget({
    super.key,
    required this.sessionId,
    required this.name,
    required this.imageUrl,
    this.startedAt,
  });

  @override
  State<FloatingCallBubbleWidget> createState() => _FloatingCallBubbleWidgetState();
}

class _FloatingCallBubbleWidgetState extends State<FloatingCallBubbleWidget> {
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

  DateTime? _parseSmartDate(dynamic input) {
    if (input == null) return null;
    if (input is DateTime) return input;
    final dateStr = input.toString().trim();
    if (dateStr.isEmpty) return null;

    DateTime? parsed;
    try {
      parsed = DateTime.tryParse(dateStr.replaceAll(' ', 'T'));
    } catch (_) {}

    if (parsed == null) {
      try {
        parsed = DateTime.tryParse(dateStr);
      } catch (_) {}
    }

    if (parsed == null) return null;

    final now = DateTime.now();

    if (parsed.isAfter(now)) {
      String isoUtc = dateStr.replaceAll(' ', 'T');
      if (!isoUtc.endsWith('Z') && !isoUtc.contains('+')) {
        isoUtc += 'Z';
      }
      final utcDate = DateTime.tryParse(isoUtc)?.toLocal();
      if (utcDate != null && !utcDate.isAfter(now)) {
        return utcDate;
      }
      final offsetDate = parsed.subtract(now.timeZoneOffset);
      if (!offsetDate.isAfter(now)) {
        return offsetDate;
      }
    }

    return parsed;
  }

  void _startTimer(String? startedAtStr) {
    void updateDuration() {
      final startedAt = _parseSmartDate(startedAtStr);
      if (startedAt != null) {
        final diff = DateTime.now().difference(startedAt).inSeconds;
        if (diff > 0) {
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
      final currentStatus = FloatingCallBubble.callStatus.value.toLowerCase();
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
      color: const Color(0xFFE65100),
      child: SafeArea(
        bottom: false,
        child: GestureDetector(
          onTap: () {
            if (FloatingCallBubble.onTapCallback != null) {
              FloatingCallBubble.onTapCallback?.call();
            } else {
              Get.to(() => const CallScreen());
            }
          },
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            color: const Color(0xFFE65100),
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
                      Text(
                        'Call with ${widget.name}',
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
                        final status = FloatingCallBubble.callStatus.value;
                        if (status == 'ongoing') {
                          int durationSec = _elapsedSeconds.value;
                          if (Get.isRegistered<CallController>()) {
                            final callCtrl = Get.find<CallController>();
                            if (callCtrl.durationSeconds.value > 0) {
                              durationSec = callCtrl.durationSeconds.value;
                            }
                          }
                          return Text(
                            'Active Call • ${_formatDuration(durationSec)}',
                            style: const TextStyle(
                              color: Colors.white70,
                              fontSize: 12,
                            ),
                          );
                        } else {
                          return Text(
                            'Call Status: ${status.capitalizeFirst}...',
                            style: const TextStyle(
                              color: Colors.white70,
                              fontSize: 12,
                            ),
                          );
                        }
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
                      color: Color(0xFF6A0C22),
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
