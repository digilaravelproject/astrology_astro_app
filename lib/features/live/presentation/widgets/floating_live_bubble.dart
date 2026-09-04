import 'dart:async';
import 'dart:isolate';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:flutter_overlay_window/flutter_overlay_window.dart';
import 'package:astro_astrologer/features/live/data/models/live_session_model.dart';
import 'package:astro_astrologer/features/live/presentation/pages/live_schedule_screen.dart';

class FloatingLiveBubble {
  static int? sessionId;
  static String? title;
  static VoidCallback? onTapCallback;
  static final RxString liveStatus = 'initiated'.obs;

  static bool _isActive = false;
  static bool get isActive => _isActive;

  static StreamSubscription? _overlaySub;
  static const MethodChannel _appRetainChannel = MethodChannel(
    'com.suryapath.astrologer/app_retain',
  );

  static ReceivePort? _receivePort;

  static void _setupIsolatePort() {
    if (_receivePort != null) return;
    _receivePort = ReceivePort();
    IsolateNameServer.removePortNameMapping('overlay_live_port');
    IsolateNameServer.registerPortWithName(
      _receivePort!.sendPort,
      'overlay_live_port',
    );
    _receivePort!.listen((message) async {
      if (message == 'tap') {
        debugPrint("==== LIVE OVERLAY TAPPED VIA ISOLATE PORT ====");
        try {
          debugPrint(
            "==== ATTEMPTING TO BRING APP TO FOREGROUND FOR LIVE ====",
          );
          await _appRetainChannel.invokeMethod('bringToForeground');
        } catch (e) {
          debugPrint("==== Error bringing app to foreground: $e ====");
        }
        Future.delayed(const Duration(milliseconds: 500), () {
          debugPrint("==== CALLING LIVE ON TAP CALLBACK ====");
          if (onTapCallback != null) {
            onTapCallback?.call();
          } else {
            FloatingLiveBubble.dismiss();
            Get.to(() => const LiveScheduleScreen());
          }
        });
      }
    });
  }

  static Future<void> show({
    required BuildContext context,
    required int sessionId,
    required String title,
    required String status,
    String? startedAt,
    required VoidCallback onTap,
  }) async {
    _setupIsolatePort();

    if (_isActive && FloatingLiveBubble.sessionId == sessionId) {
      liveStatus.value = status;
      _syncData();
      return;
    }
    FloatingLiveBubble.sessionId = sessionId;
    FloatingLiveBubble.title = title;
    onTapCallback = onTap;
    liveStatus.value = status;
    _isActive = true;

    try {
      if (await FlutterOverlayWindow.isActive()) {
        await FlutterOverlayWindow.shareData({
          'type': 'update',
          'sessionId': sessionId,
          'name': title,
          'imageUrl': '',
          'status': status,
          'isLive': true,
          'unreadCount': 0,
        });
      } else {
        await FlutterOverlayWindow.showOverlay(
          enableDrag: true,
          overlayTitle: "Live stream in progress",
          overlayContent: "Ongoing live: $title",
          flag: OverlayFlag.defaultFlag,
          visibility: NotificationVisibility.visibilitySecret,
          positionGravity: PositionGravity.none,
          height: 260,
          width: 260,
        );

        await FlutterOverlayWindow.shareData({
          'type': 'init',
          'sessionId': sessionId,
          'name': title,
          'imageUrl': '',
          'status': status,
          'startedAt': startedAt,
          'isLive': true,
          'unreadCount': 0,
        });
      }

      _overlaySub?.cancel();
      _overlaySub = FlutterOverlayWindow.overlayListener.listen((event) async {
        if (event != null && event is Map && event['action'] == 'tap') {
          debugPrint("==== LIVE OVERLAY TAPPED ====");
          try {
            await _appRetainChannel.invokeMethod('bringToForeground');
          } catch (e) {
            debugPrint("==== Error bringing app to foreground: $e ====");
          }
          Future.delayed(const Duration(milliseconds: 500), () {
            if (onTapCallback != null) {
              onTapCallback?.call();
            } else {
              FloatingLiveBubble.dismiss();
              Get.to(() => const LiveScheduleScreen());
            }
          });
        }
      });
    } catch (e) {
      debugPrint("FloatingLiveBubble show error: $e");
    }
  }

  static Future<void> dismiss() async {
    _isActive = false;
    sessionId = null;
    onTapCallback = null;
    _overlaySub?.cancel();
    _overlaySub = null;
    try {
      if (await FlutterOverlayWindow.isActive()) {
        await FlutterOverlayWindow.closeOverlay();
      }
    } catch (_) {}
  }

  static void updateStatus(String status) {
    liveStatus.value = status;
    _syncData();
  }

  static Future<void> _syncData() async {
    if (_isActive) {
      try {
        if (await FlutterOverlayWindow.isActive()) {
          await FlutterOverlayWindow.shareData({
            'type': 'update',
            'status': liveStatus.value,
            'isLive': true,
            'unreadCount': 0,
          });
        }
      } catch (_) {}
    }
  }
}
