import 'dart:io';
import 'package:astro_astrologer/core/services/foreground_task_service.dart';
import 'package:astro_astrologer/core/enums/session_status_enums.dart';
import 'package:shared_preferences/shared_preferences.dart';

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
import 'package:astro_astrologer/features/splash/presentation/controllers/splash_controller.dart';
import 'package:astro_astrologer/routes/route_helper.dart';
import 'package:astro_astrologer/routes/app_routes.dart';

class CallkitService {
  static String? lastAcceptedSessionId;
  static bool isHandlingAcceptedCall = false;
  static bool isHandlingAcceptedChat = false;
  static int? pendingAcceptedSessionId;
  static String? pendingAcceptedCallerName;
  static String? pendingAcceptedCallerAvatar;

  static void resetAcceptedFlags() {
    isHandlingAcceptedCall = false;
    isHandlingAcceptedChat = false;
    pendingAcceptedSessionId = null;
    pendingAcceptedCallerName = null;
    pendingAcceptedCallerAvatar = null;
  }

  static void _navigateDirectlyToCallScreen(CallController ctrl) async {
    int retries = 0;
    while (Get.context == null && retries < 40) {
      await Future.delayed(const Duration(milliseconds: 50));
      retries++;
    }
    if (Get.context != null && !ctrl.isCallScreenVisible) {
      debugPrint('CallKit: Navigating directly to CallScreen (currentRoute=${Get.currentRoute})');
      ctrl.isCallScreenVisible = true;
      if (Get.currentRoute == AppRoutes.splash || Get.currentRoute == '' || Get.currentRoute == '/') {
        // App started from killed state: put Dashboard at root and push CallScreen
        Get.offAllNamed(RouteHelper.getDashboardRoute());
        Get.toNamed(AppRoutes.callScreen);
      } else if (Get.currentRoute != AppRoutes.callScreen) {
        Get.toNamed(AppRoutes.callScreen);
      }
    }
  }

  static void _navigateDirectlyToChatScreen(int sId, String userName, String startedAtStr) async {
    int retries = 0;
    while (Get.context == null && retries < 40) {
      await Future.delayed(const Duration(milliseconds: 50));
      retries++;
    }
    if (Get.context != null) {
      debugPrint('CallKit: Navigating directly to ChatScreen (currentRoute=${Get.currentRoute})');
      final chatScreen = ChatScreen(
        sessionId: sId,
        initialStatus: 'ongoing',
        userName: userName,
        userImage: '',
        startedAtString: startedAtStr,
      );
      if (Get.currentRoute == AppRoutes.splash || Get.currentRoute == '' || Get.currentRoute == '/') {
        Get.offAllNamed(RouteHelper.getDashboardRoute());
        Get.to(() => chatScreen, binding: ChatBinding());
      } else {
        Get.to(() => chatScreen, binding: ChatBinding());
      }
    }
  }

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

          // Store clean caller name
          final cleanName = callerName != null
              ? callerName.replaceAll('Chat Req: ', '').replaceAll('Call Req: ', '').trim()
              : 'User';
          FloatingChatBubble.name = cleanName;

          if (payload == null) {
            debugPrint('CallKit: ERROR - Payload is still null after reconstruction attempt!');
            break;
          }
          debugPrint('CallKit: Processing payload: $payload');
          
          // Force app to launch into foreground immediately
          ForegroundTaskService.launchApp();

          if (payload.startsWith('call_')) {
            // ── Incoming CALL accepted ──
            isHandlingAcceptedCall = true;
            isHandlingAcceptedChat = false;

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
              pendingAcceptedSessionId = sId;
              lastAcceptedSessionId = sId.toString();
            }
            ctrl.consumerName = cleanName;
            pendingAcceptedCallerName = cleanName;

            final String? offerFromExtra = event.callKitParams.extra?['offer'] as String?;
            if (offerFromExtra != null && offerFromExtra.isNotEmpty && (ctrl.incomingOfferSdp == null || ctrl.incomingOfferSdp!.isEmpty)) {
              ctrl.incomingOfferSdp = offerFromExtra;
            }

            // Direct instant navigation to CallScreen!
            _navigateDirectlyToCallScreen(ctrl);

            // Execute accept call logic in background without blocking navigation
            Future(() async {
              String finalOfferSdp = ctrl.incomingOfferSdp ?? '';
              try {
                if (finalOfferSdp.isEmpty) {
                  debugPrint('CallKit: incomingOfferSdp is empty. Fetching from current session...');
                  final fetchedSdp = await ctrl.fetchOfferSdpFromCurrentSession();
                  if (fetchedSdp != null && fetchedSdp.isNotEmpty) {
                    finalOfferSdp = fetchedSdp;
                  }
                }

                bool success = false;
                if (finalOfferSdp.isNotEmpty) {
                  debugPrint('CallKit: Calling ctrl.acceptCall(offerSdp)...');
                  success = await ctrl.acceptCall(finalOfferSdp);
                } else {
                  debugPrint('CallKit: Calling ctrl.acceptCallDirect()...');
                  success = await ctrl.acceptCallDirect();
                }
                debugPrint('CallKit: Accept result success = $success');

                if (sessionId != null) {
                  FlutterCallkitIncoming.endCall(sessionId);
                }
                if (success && ctrl.status.value == CallStatus.ongoing) {
                  ctrl.session.showOngoingNotification();
                }
              } catch (e) {
                debugPrint('CallKit: Exception during acceptCall: $e');
              }
            });
          } else if (payload.startsWith('chat_')) {
            // ── Incoming CHAT accepted ──
            debugPrint('CallKit: Entered chat_ block');
            isHandlingAcceptedChat = true;
            isHandlingAcceptedCall = false;

            final sIdStr = payload.replaceFirst('chat_', '');
            final sId = int.tryParse(sIdStr);
            if (sId == null) {
              debugPrint('CallKit: ERROR - Failed to parse sId from $sIdStr');
              break;
            }
            pendingAcceptedSessionId = sId;
            pendingAcceptedCallerName = cleanName;
            lastAcceptedSessionId = sId.toString();

            // Stop ringtone immediately
            SoundVibrationService().stopRingtone();
            if (sessionId != null) {
              FlutterCallkitIncoming.endCall(sessionId);
            }

            final fallbackAcceptedAt = DateTime.now();
            final String finalStartedAtStr = fallbackAcceptedAt.toUtc().toIso8601String();

            // Direct instant navigation to ChatScreen!
            _navigateDirectlyToChatScreen(sId, cleanName, finalStartedAtStr);

            // Execute accept API and foreground notification in background
            Future(() async {
              try {
                if (!Get.isRegistered<ApiClient>()) {
                  InitialBindings().dependencies();
                }
                if (Get.isRegistered<ApiClient>()) {
                  await Get.find<ApiClient>().post(
                    AppUrls.acceptChatSession(sId),
                    handleError: false,
                    showErrorScreen: false,
                  );
                }
                ForegroundTaskService.startActiveSessionNotification(
                  title: 'Active Chat',
                  type: 'Chat',
                  startedAt: fallbackAcceptedAt,
                );
              } catch (e) {
                debugPrint('CallKit: Error calling acceptChatSession API: $e');
              }
            });
          }
          break;

        // ──────────────────────────────────────────────────────────────
        // DECLINE
        // ──────────────────────────────────────────────────────────────
        case CallEventActionCallDecline():
          debugPrint('CallKit: DECLINED');
          resetAcceptedFlags();
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
          resetAcceptedFlags();
          break;

        case CallEventActionCallTimeout():
          debugPrint('CallKit: Call Timeout');
          resetAcceptedFlags();
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
    final String nameCallerParam = callerName;
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
        isShowFullLockedScreen: true,

        ringtonePath: 'system_ringtone_default',
        backgroundColor: '#0A0A0A',
        backgroundUrl: 'assets/images/background.png',
        actionColor: '#4CAF50',
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
