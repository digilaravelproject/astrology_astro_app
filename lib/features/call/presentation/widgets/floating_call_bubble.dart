import 'dart:async';
import 'dart:isolate';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:flutter_overlay_window/flutter_overlay_window.dart';
import 'package:astro_astrologer/features/call/presentation/pages/call_screen.dart';

class FloatingCallBubble {
  static int? sessionId;
  static String? name;
  static VoidCallback? onTapCallback;
  static final RxString callStatus = 'initiated'.obs;

  static bool _isActive = false;
  static bool get isActive => _isActive;
  
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
    
    if (_isActive && FloatingCallBubble.sessionId == sessionId) {
      callStatus.value = status;
      _syncData();
      return;
    }
    FloatingCallBubble.sessionId = sessionId;
    FloatingCallBubble.name = name;
    onTapCallback = onTap;
    callStatus.value = status;
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
          'isCall': true,
          'unreadCount': 0,
        });
      } else {
        await FlutterOverlayWindow.showOverlay(
          enableDrag: true,
          overlayTitle: "Call in progress",
          overlayContent: "Active call with $name",
          flag: OverlayFlag.defaultFlag,
          visibility: NotificationVisibility.visibilitySecret,
          positionGravity: PositionGravity.none,
          height: 260,
          width: 260,
        );
        
        await FlutterOverlayWindow.shareData({
          'type': 'init',
          'sessionId': sessionId,
          'name': name,
          'imageUrl': imageUrl,
          'status': status,
          'startedAt': startedAt,
          'isCall': true,
          'unreadCount': 0,
        });
      }
      
      // Listen for tap events from overlay ALWAYS
      _overlaySub?.cancel();
      _overlaySub = FlutterOverlayWindow.overlayListener.listen((event) async {
        if (event != null && event is Map && event['action'] == 'tap') {
          debugPrint("==== CALL OVERLAY TAPPED ====");
          try {
            await _appRetainChannel.invokeMethod('bringToForeground');
          } catch (e) {
            debugPrint("==== Error bringing app to foreground: $e ====");
          }
          Future.delayed(const Duration(milliseconds: 500), () {
            if (onTapCallback != null) {
              onTapCallback?.call();
            } else {
              FloatingCallBubble.dismiss();
              Get.to(() => const CallScreen());
            }
          });
        }
      });

    } catch (e) {
      debugPrint("FloatingCallBubble show error: $e");
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
    callStatus.value = status;
    _syncData();
  }

  static Future<void> _syncData() async {
    if (_isActive) {
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
