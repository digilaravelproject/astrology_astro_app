import 'package:astro_astrologer/core/services/foreground_task_service.dart';

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
import 'package:astro_astrologer/core/constants/app_urls.dart';
import 'package:astro_astrologer/core/services/network/api_client.dart';
import 'package:astro_astrologer/core/services/sound_vibration_service.dart';
import 'package:astro_astrologer/routes/route_helper.dart';

class CallkitService {
  static String? lastAcceptedSessionId;

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
            FloatingChatBubble.name =
                callerName
                    .replaceAll('Chat Req: ', '')
                    .replaceAll('Call Req: ', '')
                    .trim();
          }

          if (payload == null) break;

          if (payload.startsWith('call_')) {
            // ── Incoming CALL accepted ──
            int retries = 0;
            while (!Get.isRegistered<CallController>() && retries < 40) {
              await Future.delayed(const Duration(milliseconds: 100));
              retries++;
            }
            if (!Get.isRegistered<CallController>()) break;
            final ctrl = Get.find<CallController>();
            
            final sIdStr = payload.replaceFirst('call_', '');
            final sId = int.tryParse(sIdStr);
            if (sId != null) {
              ctrl.sessionId = sId;
              lastAcceptedSessionId = sId.toString();
            }
            if (callerName != null) {
              ctrl.consumerName = callerName
                  .replaceAll('Chat Req: ', '')
                  .replaceAll('Call Req: ', '')
                  .trim();
            }

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
                
                // Wait until splash screen is gone to avoid Get.offAllNamed clearing this route
                int waitRetries = 0;
                while ((Get.currentRoute == RouteHelper.getSplashRoute() || Get.currentRoute.isEmpty) && waitRetries < 50) {
                  await Future.delayed(const Duration(milliseconds: 100));
                  waitRetries++;
                }

                if (!ctrl.isCallScreenVisible) {
                  Get.to(() => const CallScreen());
                }
              }
            });
          } else if (payload.startsWith('chat_')) {
            // ── Incoming CHAT accepted ──
            final sId = int.tryParse(payload.replaceFirst('chat_', ''));
            if (sId == null) break;

            // Stop ringtone immediately
            SoundVibrationService().stopRingtone();

            // End CallKit telecom session so it doesn't linger
            Future.delayed(const Duration(milliseconds: 500), () {
              FlutterCallkitIncoming.endCall(sessionId);
            });

            // 1. Call POST /chat/{id}/accept API — required to change status from initiated → ongoing
            bool accepted = false;
            // Record accept time as canonical start — passed to ChatScreen and ForegroundTask
            final acceptedAt = DateTime.now();
            try {
              int retries = 0;
              while (!Get.isRegistered<ApiClient>() && retries < 40) {
                await Future.delayed(const Duration(milliseconds: 100));
                retries++;
              }
              if (Get.isRegistered<ApiClient>()) {
                final resp = await Get.find<ApiClient>().post(
                  AppUrls.acceptChatSession(sId),
                  handleError: false,
                  showErrorScreen: false,
                );
                accepted = resp.isSuccess;
                debugPrint(
                  'CallKit: Chat accept API for session $sId → isSuccess=$accepted',
                );

                if (accepted) {
                  ForegroundTaskService.startActiveSessionNotification(
                    title: 'Active Chat',
                    type: 'Chat',
                    startedAt: acceptedAt,
                  );
                }
              }
            } catch (e) {
              debugPrint('CallKit: Error calling acceptChatSession API: $e');
            }

            // Set last accepted session to avoid duplicate notifications
            lastAcceptedSessionId = sId.toString();

            // 2. Navigate to ChatScreen — pass acceptedAt so all 3 timers start from same moment
            WidgetsBinding.instance.addPostFrameCallback((_) async {
              // Wait until splash screen is gone to avoid Get.offAllNamed clearing this route
              int waitRetries = 0;
              while ((Get.currentRoute == RouteHelper.getSplashRoute() || Get.currentRoute.isEmpty) && waitRetries < 50) {
                await Future.delayed(const Duration(milliseconds: 100));
                waitRetries++;
              }

              Get.to(
                () => ChatScreen(
                  sessionId: sId,
                  initialStatus: 'ongoing',
                  userName: FloatingChatBubble.name ?? 'User',
                  userImage: '',
                  startedAtString: acceptedAt.toUtc().toIso8601String(),
                ),
                binding: ChatBinding(),
              );
            });
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
            int retries = 0;
            while (!Get.isRegistered<CallController>() && retries < 40) {
              await Future.delayed(const Duration(milliseconds: 100));
              retries++;
            }
            if (Get.isRegistered<CallController>()) {
              final ctrl = Get.find<CallController>();
              final sIdStr = payload.replaceFirst('call_', '');
              final sId = int.tryParse(sIdStr);
              if (sId != null) {
                ctrl.sessionId = sId;
              }
              ctrl.rejectCall();
            }
          } else if (payload.startsWith('chat_')) {
            // ── Reject chat request — use sessionId from payload directly ──
            final chatSessionId = int.tryParse(
              payload.replaceFirst('chat_', ''),
            );
            debugPrint('CallKit: Rejecting chat session $chatSessionId');

            // Stop ringtone immediately
            SoundVibrationService().stopRingtone();
            FloatingChatBubble.dismiss();

            if (chatSessionId != null) {
              int retries = 0;
              while (!Get.isRegistered<ApiClient>() && retries < 40) {
                await Future.delayed(const Duration(milliseconds: 100));
                retries++;
              }
              // Try via controller first (sets status, cleans up UI)
              if (Get.isRegistered<ChatController>() &&
                  Get.find<ChatController>().sessionId != null) {
                Get.find<ChatController>().rejectChatSession();
              } else {
                // Fallback: call reject API directly using payload sessionId
                try {
                  if (Get.isRegistered<ApiClient>()) {
                    await Get.find<ApiClient>().post(
                      AppUrls.rejectChatSession(chatSessionId),
                      handleError: false,
                      showErrorScreen: false,
                    );
                    debugPrint(
                      'CallKit: Chat reject API called for session $chatSessionId',
                    );
                  }
                } catch (e) {
                  debugPrint('CallKit: Error rejecting chat: $e');
                }
              }
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
    final String notifTitle = type == 'call' ? 'Incoming Call' : 'Chat Request';
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
        isCustomNotification: false,
        isShowLogo: false,
        isShowFullLockedScreen: true,

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
