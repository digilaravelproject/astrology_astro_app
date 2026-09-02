import 'package:flutter/material.dart';
import 'package:flutter_callkit_incoming/entities/entities.dart';
import 'package:flutter_callkit_incoming/flutter_callkit_incoming.dart';
import 'package:get/get.dart';
import 'package:astro_astrologer/features/chat/presentation/widgets/floating_chat_bubble.dart';
import 'package:astro_astrologer/features/call/presentation/controllers/call_controller.dart';
import 'package:astro_astrologer/features/call/presentation/pages/call_screen.dart';
import 'package:astro_astrologer/features/chat/presentation/controllers/chat_controller.dart';
import 'package:astro_astrologer/features/chat/presentation/pages/chat_screen.dart';
import 'package:astro_astrologer/features/chat/presentation/bindings/chat_binding.dart';
import 'package:astro_astrologer/core/constants/app_constants.dart';

class CallkitService {
  static void init() {
    FlutterCallkitIncoming.onEvent.listen((CallEvent? event) async {
      switch (event) {
        // ──────────────────────────────────────────────────────────────
        // ACCEPT
        // ──────────────────────────────────────────────────────────────
        case CallEventActionCallAccept():
          debugPrint('CallKit: ACCEPTED');
          final payload = event.callKitParams.extra?['payload'] as String?;
          final callerName = event.callKitParams.nameCaller;
          final sessionId = event.callKitParams.id;

          // Store clean caller name for floating bubble
          if (callerName != null) {
            FloatingChatBubble.name = callerName
                .replaceAll('Chat Req: ', '')
                .replaceAll('Call Req: ', '')
                .trim();
          }

          if (payload == null) break;

          if (payload.startsWith('call_')) {
            // ── Incoming CALL accepted ──
            if (!Get.isRegistered<CallController>()) break;
            final ctrl = Get.find<CallController>();
            final offerSdp = ctrl.incomingOfferSdp ?? '';

            WidgetsBinding.instance.addPostFrameCallback((_) async {
              bool success;
              if (offerSdp.isNotEmpty) {
                success = await ctrl.acceptCall(offerSdp);
              } else {
                success = await ctrl.acceptCallDirect();
              }
              if (success) {
                // End CallKit telecom session so "Hang Up" notification disappears.
                // The actual call continues over our WebRTC implementation.
                Future.delayed(const Duration(milliseconds: 500), () {
                  FlutterCallkitIncoming.endCall(sessionId);
                });
                if (!ctrl.isCallScreenVisible) {
                  Get.to(() => const CallScreen());
                }
              }
            });
          } else if (payload.startsWith('chat_')) {
            // ── Incoming CHAT accepted ──
            final sId = int.tryParse(payload.replaceFirst('chat_', ''));
            if (sId == null) break;

            // End CallKit telecom session so it doesn't linger
            Future.delayed(const Duration(milliseconds: 500), () {
              FlutterCallkitIncoming.endCall(sessionId);
            });

            if (Get.isRegistered<ChatController>()) {
              WidgetsBinding.instance.addPostFrameCallback((_) {
                Get.to(
                  () => ChatScreen(
                    sessionId: sId,
                    initialStatus: 'ongoing',
                    userName: FloatingChatBubble.name ?? 'User',
                    userImage: '',
                  ),
                  binding: ChatBinding(),
                );
              });
            }
          }
          break;

        // ──────────────────────────────────────────────────────────────
        // DECLINE
        // ──────────────────────────────────────────────────────────────
        case CallEventActionCallDecline():
          debugPrint('CallKit: DECLINED');
          final payload = event.callKitParams.extra?['payload'] as String?;

          if (payload == null) break;

          if (payload.startsWith('call_')) {
            // ── Reject incoming call — calls POST /call/{id}/reject ──
            if (Get.isRegistered<CallController>()) {
              Get.find<CallController>().rejectCall();
            }
          } else if (payload.startsWith('chat_')) {
            // ── Reject chat request ──
            if (Get.isRegistered<ChatController>()) {
              Get.find<ChatController>().rejectChatSession();
            }
          }
          break;

        case CallEventActionCallEnded():
          debugPrint('CallKit: Call Ended');
          break;

        case CallEventActionCallTimeout():
          debugPrint('CallKit: Call Timeout');
          if (Get.isRegistered<CallController>()) {
            Get.find<CallController>().cleanUp();
          }
          break;

        default:
          break;
      }
    });
  }

  static Future<void> showCallkitNotification({
    required String sessionId,
    required String callerName,
    required String avatar,
    required String type, // 'call' or 'chat'
  }) async {
    final String notifTitle =
        type == 'call' ? 'Incoming Call' : 'Chat Request';
    final String nameCallerParam =
        type == 'call' ? callerName : 'Chat Req: $callerName';
    final String payloadStr = '${type}_$sessionId';
    final String safeAvatar =
        (avatar.isNotEmpty && avatar != 'null')
            ? avatar
            : 'assets/images/app_logo.png';

    CallKitParams callKitParams = CallKitParams(
      id: sessionId,
      nameCaller: nameCallerParam,
      appName: AppConstants.appName,
      avatar: safeAvatar,
      handle: notifTitle,
      type: 0,
      duration: 30000,
      extra: <String, dynamic>{'payload': payloadStr, 'sessionId': sessionId},
      headers: <String, dynamic>{'apiKey': 'Abc@123!', 'platform': 'flutter'},
      android: const AndroidParams(
        isCustomNotification: true,
        isShowLogo: false,
        isShowFullLockedScreen: false, // Disable full-screen call activity — notification banner only
        ringtonePath: 'system_ringtone_default',
        backgroundColor: '#0A0A0A',
        backgroundUrl: 'assets/images/background.png',
        actionColor: '#FF6B00',
        textColor: '#FFFFFF',
        textAccept: 'Accept',
        textDecline: 'Decline',
      ),
    );
    await FlutterCallkitIncoming.showCallkitIncoming(callKitParams);
  }

  static Future<void> showIncomingCall(CallKitParams params) async {
    await FlutterCallkitIncoming.showCallkitIncoming(params);
  }

  static Future<void> endCall(String sessionId) async {
    await FlutterCallkitIncoming.endCall(sessionId);
  }

  static Future<void> endAllCalls() async {
    await FlutterCallkitIncoming.endAllCalls();
  }
}
