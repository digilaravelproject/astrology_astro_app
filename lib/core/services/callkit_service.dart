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
import 'package:astro_astrologer/core/bindings/initial_bindings.dart';
import 'package:astro_astrologer/core/services/sound_vibration_service.dart';
import 'package:astro_astrologer/routes/route_helper.dart';
import 'package:astro_astrologer/routes/app_routes.dart';

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
          String? payload = event.callKitParams.extra?['payload'] as String?;
          final callerName = event.callKitParams.nameCaller;
          final sessionId = event.callKitParams.id;
          final handleStr = event.callKitParams.handle;

          // Reconstruct payload if lost during cold boot (Android CallKit issue)
          if (payload == null && sessionId != null) {
            if (handleStr == 'Chat Request' ||
                (callerName != null && callerName.contains('Chat Req'))) {
              payload = 'chat_$sessionId';
            } else {
              payload = 'call_$sessionId';
            }
            debugPrint('CallKit: Reconstructed payload -> $payload');
          }

          // Store clean caller name for floating bubble
          if (callerName != null) {
            FloatingChatBubble.name =
                callerName
                    .replaceAll('Chat Req: ', '')
                    .replaceAll('Call Req: ', '')
                    .trim();
          }

          if (payload == null) {
            debugPrint('CallKit: ERROR - Payload is still null after reconstruction attempt!');
            break;
          }
          debugPrint('CallKit: Processing payload: $payload');
          
          // Force app to launch into foreground when accept is tapped
          ForegroundTaskService.launchApp();

          if (payload.startsWith('call_')) {
            // ── Incoming CALL accepted ──
            int retries = 0;
            while (!Get.isRegistered<CallController>() && retries < 40) {
              await Future.delayed(const Duration(milliseconds: 100));
              retries++;
            }
            if (!Get.isRegistered<CallController>()) {
              debugPrint('CallKit: Forcing InitialBindings for CallController...');
              InitialBindings().dependencies();
            }
            if (!Get.isRegistered<CallController>()) {
              debugPrint('CallKit: ERROR - CallController still not registered!');
              break;
            }
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

            debugPrint('CallKit: Executing call accept logic...');
            bool success = false;
            String finalOfferSdp = offerSdp;

            try {
              // If offerSdp is empty (likely due to cold boot), try to fetch it from the backend API
              if (finalOfferSdp.isEmpty) {
                debugPrint('CallKit: incomingOfferSdp is empty. Attempting to fetch from current session...');
                final fetchedSdp = await ctrl.fetchOfferSdpFromCurrentSession();
                if (fetchedSdp != null && fetchedSdp.isNotEmpty) {
                  finalOfferSdp = fetchedSdp;
                  debugPrint('CallKit: Successfully fetched offerSdp from API.');
                }
              }

              if (finalOfferSdp.isNotEmpty) {
                debugPrint('CallKit: Calling ctrl.acceptCall(offerSdp)...');
                success = await ctrl.acceptCall(finalOfferSdp);
              } else {
                debugPrint('CallKit: Calling ctrl.acceptCallDirect()...');
                success = await ctrl.acceptCallDirect();
              }
            } catch (e) {
              debugPrint('CallKit: Exception during acceptCall: $e');
            }

            debugPrint('CallKit: Accept result success = $success');

            if (success) {
              // End CallKit telecom session so "Hang Up" notification disappears.
              // The actual call continues over our WebRTC implementation.
              Future.delayed(const Duration(milliseconds: 500), () {
                FlutterCallkitIncoming.endCall(sessionId!);
              });
              
              // Wait until splash screen is gone and navigator is ready
              int waitRetries = 0;
              while ((Get.key.currentState == null || Get.currentRoute == RouteHelper.getSplashRoute() || Get.currentRoute.isEmpty || Get.currentRoute == '/') && waitRetries < 150) {
                await Future.delayed(const Duration(milliseconds: 100));
                waitRetries++;
              }

              if (Get.key.currentState == null) {
                debugPrint('CallKit: Navigation failed, UI not ready.');
              } else {
                if (!ctrl.isCallScreenVisible) {
                  debugPrint('CallKit: Navigating to CallScreen.');
                  Get.toNamed(AppRoutes.callScreen);
                }
              }
            } else {
              debugPrint('CallKit: Failed to accept call. Not navigating to CallScreen.');
            }
          } else if (payload.startsWith('chat_')) {
            // ── Incoming CHAT accepted ──
            debugPrint('CallKit: Entered chat_ block');
            final sIdStr = payload.replaceFirst('chat_', '');
            debugPrint('CallKit: Parsed sIdStr: $sIdStr');
            final sId = int.tryParse(sIdStr);
            if (sId == null) {
               debugPrint('CallKit: ERROR - Failed to parse sId from $sIdStr');
               break;
            }
            debugPrint('CallKit: Valid sId: $sId');

            // Stop ringtone immediately
            SoundVibrationService().stopRingtone();

            // End CallKit telecom session so it doesn't linger
            Future.delayed(const Duration(milliseconds: 500), () {
              debugPrint('CallKit: Ending CallKit session for $sessionId');
              FlutterCallkitIncoming.endCall(sessionId);
            });

            // 1. Call POST /chat/{id}/accept API — required to change status from initiated → ongoing
            bool accepted = false;
            String? backendStartedAtStr;
            // Record accept time as canonical start — passed to ChatScreen and ForegroundTask
            final fallbackAcceptedAt = DateTime.now();
            try {
              int retries = 0;
              debugPrint('CallKit: Waiting for ApiClient...');
              while (!Get.isRegistered<ApiClient>() && retries < 10) {
                await Future.delayed(const Duration(milliseconds: 100));
                retries++;
              }
              debugPrint('CallKit: ApiClient registered? ${Get.isRegistered<ApiClient>()} (retries: $retries)');
              
              if (!Get.isRegistered<ApiClient>()) {
                debugPrint('CallKit: Forcing InitialBindings registration for cold boot...');
                InitialBindings().dependencies();
              }

              if (Get.isRegistered<ApiClient>()) {
                debugPrint('CallKit: Calling accept API for session $sId...');
                final resp = await Get.find<ApiClient>().post(
                  AppUrls.acceptChatSession(sId),
                  handleError: false,
                  showErrorScreen: false,
                );
                accepted = resp.isSuccess;
                debugPrint(
                  'CallKit: Chat accept API for session $sId → isSuccess=$accepted, resp message=${resp.message}',
                );

                if (accepted) {
                  final body = resp.body;
                  if (body != null) {
                    final sessionData = body is Map ? (body['session'] ?? body['data']?['session'] ?? body['data']) : null;
                    if (sessionData != null && sessionData is Map) {
                      backendStartedAtStr = sessionData['started_at']?.toString() ?? sessionData['accepted_at']?.toString();
                    }
                  }

                  ForegroundTaskService.startActiveSessionNotification(
                    title: 'Active Chat',
                    type: 'Chat',
                    startedAt: fallbackAcceptedAt,
                  );
                } else {
                  // Fallback for cold boot: the background isolate might have already accepted the chat.
                  // Try to fetch the active session to get the true backend started_at.
                  debugPrint('CallKit: accept API returned false. Trying to fetch current session for started_at...');
                  try {
                    final currentResp = await Get.find<ApiClient>().get(AppUrls.getCurrentSession);
                    if (currentResp.isSuccess && currentResp.body != null) {
                      final body = currentResp.body;
                      final sessionData = body is Map ? (body['session'] ?? body['data']?['session'] ?? body['data']) : null;
                      if (sessionData != null && sessionData is Map && sessionData['id'] == sId) {
                        backendStartedAtStr = sessionData['started_at']?.toString() ?? sessionData['accepted_at']?.toString();
                        debugPrint('CallKit: Recovered started_at from getCurrentSession: $backendStartedAtStr');
                      }
                    }
                  } catch (e) {
                    debugPrint('CallKit: Error fetching current session: $e');
                  }
                }
              }
            } catch (e) {
              debugPrint('CallKit: Error calling acceptChatSession API: $e');
            }

            // Set last accepted session to avoid duplicate notifications
            lastAcceptedSessionId = sId.toString();

            // 2. Navigate to ChatScreen — pass acceptedAt so all 3 timers start from same moment
            final String finalStartedAtStr = backendStartedAtStr ?? fallbackAcceptedAt.toUtc().toIso8601String();
            Future.microtask(() async {
              debugPrint('CallKit: Navigation task for ChatScreen started');
              // Wait until splash screen is gone and navigator is ready
              int waitRetries = 0;
              while ((Get.key.currentState == null || Get.currentRoute == RouteHelper.getSplashRoute() || Get.currentRoute.isEmpty || Get.currentRoute == '/') && waitRetries < 150) {
                await Future.delayed(const Duration(milliseconds: 100));
                waitRetries++;
              }
              
              if (Get.key.currentState == null || Get.currentRoute == RouteHelper.getSplashRoute() || Get.currentRoute.isEmpty || Get.currentRoute == '/') {
                debugPrint('CallKit: Navigation failed, UI not ready after 15 seconds. Current route: ${Get.currentRoute}');
                return;
              }
              
              debugPrint('CallKit: Current route before navigating to ChatScreen: ${Get.currentRoute}');

              Get.to(
                () => ChatScreen(
                  sessionId: sId,
                  initialStatus: 'ongoing',
                  userName: FloatingChatBubble.name ?? 'User',
                  userImage: '',
                  startedAtString: finalStartedAtStr,
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
          String? payload = event.callKitParams.extra?['payload'] as String?;
          final callerName = event.callKitParams.nameCaller;
          final sessionId = event.callKitParams.id;
          final handleStr = event.callKitParams.handle;

          // Reconstruct payload if lost during cold boot (Android CallKit issue)
          if (payload == null && sessionId != null) {
            if (handleStr == 'Chat Request' ||
                (callerName != null && callerName.contains('Chat Req'))) {
              payload = 'chat_$sessionId';
            } else {
              payload = 'call_$sessionId';
            }
            debugPrint('CallKit: Reconstructed payload in DECLINE -> $payload');
          }

          if (payload == null) {
            debugPrint('CallKit: DECLINE ERROR - Payload is null');
            break;
          }

          // Ensure ApiClient is registered if app was killed
          int apiRetries = 0;
          while (!Get.isRegistered<ApiClient>() && apiRetries < 10) {
            await Future.delayed(const Duration(milliseconds: 100));
            apiRetries++;
          }
          if (!Get.isRegistered<ApiClient>()) {
            debugPrint('CallKit: DECLINE - Forcing InitialBindings registration...');
            InitialBindings().dependencies();
          }

          if (payload.startsWith('call_')) {
            // ── Reject incoming call — calls POST /call/{id}/reject ──
            int retries = 0;
            while (!Get.isRegistered<CallController>() && retries < 10) {
              await Future.delayed(const Duration(milliseconds: 100));
              retries++;
            }
            final sIdStr = payload.replaceFirst('call_', '');
            final sId = int.tryParse(sIdStr);

            if (Get.isRegistered<CallController>()) {
              final ctrl = Get.find<CallController>();
              if (sId != null) {
                ctrl.sessionId = sId;
              }
              ctrl.rejectCall();
            } else if (sId != null) {
               // Fallback: call reject API directly
               try {
                 if (Get.isRegistered<ApiClient>()) {
                   await Get.find<ApiClient>().post(
                     AppUrls.rejectCall(sId),
                     handleError: false,
                     showErrorScreen: false,
                   );
                   debugPrint('CallKit: Call reject API called directly for session $sId');
                 }
               } catch (e) {
                 debugPrint('CallKit: Error rejecting call directly: $e');
               }
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
    if (lastAcceptedSessionId == sessionId) {
      debugPrint('CallKit: Ignoring incoming call for already accepted session $sessionId');
      return;
    }
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
