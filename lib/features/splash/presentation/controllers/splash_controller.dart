import 'package:permission_handler/permission_handler.dart';
import 'dart:async';
import 'package:get/get.dart';
import 'package:astro_astrologer/core/services/storage/shared_prefs.dart';
import 'package:astro_astrologer/core/constants/app_constants.dart';
import 'package:astro_astrologer/routes/route_helper.dart';
import 'package:astro_astrologer/routes/app_routes.dart';
import 'package:astro_astrologer/core/services/callkit_service.dart';
import 'package:astro_astrologer/features/splash/data/datasources/splash_service.dart';
import 'package:astro_astrologer/core/services/websocket/websocket_service.dart';
import 'package:astro_astrologer/core/services/fcm_notification_service.dart';
import 'package:astro_astrologer/core/services/cold_start_detector.dart';
import 'package:astro_astrologer/core/bindings/initial_bindings.dart';
import 'package:astro_astrologer/features/call/presentation/controllers/call_controller.dart';
import 'package:astro_astrologer/core/enums/session_status_enums.dart';
import 'package:astro_astrologer/core/services/sound_vibration_service.dart';
import 'package:flutter_callkit_incoming/flutter_callkit_incoming.dart';
import 'package:astro_astrologer/core/constants/app_urls.dart';
import 'package:astro_astrologer/core/services/network/api_client.dart';
import 'package:astro_astrologer/features/chat/presentation/widgets/floating_chat_bubble.dart';
import 'package:astro_astrologer/core/services/foreground_task_service.dart';
import 'package:astro_astrologer/features/chat/presentation/pages/chat_screen.dart';
import 'package:astro_astrologer/features/chat/presentation/bindings/chat_binding.dart';
import 'package:astro_astrologer/features/chat/presentation/pages/assistance_chat_room_screen.dart';

class SplashController extends GetxController {
  final SplashService _splashService;

  SplashController(this._splashService);

  final isLoading = true.obs;

  @override
  void onInit() {
    super.onInit();
    initApp();
  }

  Future<void> initApp() async {
    try {
      isLoading.value = true;

      // ── FAST PATH: Cold-Start Communication (Call/Chat) ──────────────────
      final intent = ColdStartDetector.currentIntent;
      final isLoggedIn = SharedPrefs.getBool(AppConstants.isLoggedIn) ?? false;
      final userData = SharedPrefs.getString(AppConstants.userData);

      if (isLoggedIn && userData != null && userData.isNotEmpty && intent != null && intent.type != ColdStartType.none) {
        print('[SPLASH] Cold-start communication intent detected: ${intent.type} (sessionId=${intent.sessionId}). Executing ZERO-LAG fast path.');
        ColdStartDetector.currentIntent = null; // consume

        // Connect WebSocket in background so signalling/messages are received
        try {
          if (Get.isRegistered<WebSocketService>()) {
            Get.find<WebSocketService>().connect();
          } else {
            Get.put(WebSocketService()).connect();
          }
        } catch (e) {
          print('[SPLASH] WebSocket fast path connect error: $e');
        }

        try {
          FCMNotificationService.registerDeviceToken(null);
        } catch (_) {}

        // Wait briefly for navigator mounting if onInit fired before frame
        int retries = 0;
        while (Get.context == null && retries < 20) {
          await Future.delayed(const Duration(milliseconds: 25));
          retries++;
        }

        if (intent.type == ColdStartType.call) {
          _dispatchColdStartCall(intent);
        } else if (intent.type == ColdStartType.chat) {
          _dispatchColdStartChat(intent);
        } else if (intent.type == ColdStartType.assistanceChat) {
          _dispatchColdStartAssistance(intent);
        }
        return;
      }

      // Initialize splash service
      final isReady = await _splashService.initialize();

      // Only wait 2 seconds if NOT handling an accepted call or chat via CallKit!
      if (!CallkitService.isHandlingAcceptedCall && !CallkitService.isHandlingAcceptedChat) {
        await Future.delayed(const Duration(seconds: 2));
      }

      bool cameraGranted = await Permission.camera.isGranted;
      bool micGranted = await Permission.microphone.isGranted;
      bool notifGranted = await Permission.notification.isGranted;

      if (cameraGranted && micGranted && notifGranted) {
        if (isReady) {
          print(
            '[SPLASH] isLoggedIn: $isLoggedIn, hasUserData: ${userData != null && userData.isNotEmpty}',
          );

          if (isLoggedIn && userData != null && userData.isNotEmpty) {
            try {
              if (Get.isRegistered<WebSocketService>()) {
                Get.find<WebSocketService>().connect();
              } else {
                Get.put(WebSocketService()).connect();
              }
            } catch (e) {
              print('[SPLASH] WebSocketService init error: $e');
            }
            try {
              FCMNotificationService.registerDeviceToken(null);
            } catch (_) {}
            
            // Check if a call or chat screen is already opened or being handled from CallKit/notification
            final String currentRoute = Get.currentRoute.toLowerCase();
            final bool isCallOrChatActive = currentRoute.contains('call') ||
                currentRoute.contains('chat') ||
                CallkitService.isHandlingAcceptedCall ||
                CallkitService.isHandlingAcceptedChat;

            if (isCallOrChatActive) {
              print('[SPLASH] Active call/chat detected ($currentRoute). Preserving navigation stack — skipping stack reset.');
              return;
            }

            // Navigate to dashboard — DashboardController.onReady() will handle
            // any ongoing chat session via server API (more reliable than SharedPrefs)
            Get.offAllNamed(RouteHelper.getDashboardRoute());
            Future.delayed(const Duration(milliseconds: 500), () {
               // Check if there's a pending chat assistance notification
               final Map<String, dynamic>? data = FCMNotificationService.pendingNotificationData;
               if (data != null) {
                 final type = data['type']?.toString();
                 if (type == 'assistance_chat' || type == 'chat_assistance') {
                    FCMNotificationService.pendingNotificationData = null;
                    final String rawSessionId = data['session_id']?.toString() ?? data['chat_session_id']?.toString() ?? data['id']?.toString() ?? '';
                    final int? sId = int.tryParse(rawSessionId);
                    if (sId != null && sId > 0) {
                      final userName = data['user_name']?.toString() ?? data['sender_name']?.toString() ?? 'User';
                      final userImage = data['user_avatar']?.toString() ?? data['sender_image']?.toString() ?? '';
                      Get.to(() => AssistanceChatRoomScreen(
                        sessionId: sId,
                        userName: userName,
                        userImage: userImage,
                      ));
                    }
                 }
               }
            });
          } else {
            Get.offAllNamed(RouteHelper.getLoginRoute());
          }
        } else {
          // Handle maintenance or version issues
          // For now, just navigate to login
          Get.offAllNamed(RouteHelper.getLoginRoute());
        }
      } else {
        Get.offAllNamed(RouteHelper.getPermissionRoute());
      }
    } catch (e) {
      print('[SPLASH] Error during initialization: $e');
      final isLoggedIn = SharedPrefs.getBool(AppConstants.isLoggedIn) ?? false;
      final userData = SharedPrefs.getString(AppConstants.userData);
      if (isLoggedIn && userData != null && userData.isNotEmpty) {
        Get.offAllNamed(RouteHelper.getDashboardRoute());
      } else {
        Get.offAllNamed(RouteHelper.getLoginRoute());
      }
    } finally {
      isLoading.value = false;
    }
  }

  void _dispatchColdStartCall(ColdStartIntent intent) {
    if (!Get.isRegistered<CallController>()) {
      InitialBindings().dependencies();
    }
    final ctrl = Get.find<CallController>();
    ctrl.sessionId = intent.sessionId;
    ctrl.isAcceptedLocally = true;
    ctrl.isCallScreenVisible = true;
    if (intent.name != null && intent.name!.isNotEmpty) {
      ctrl.consumerName = intent.name;
    }
    if (intent.avatar != null && intent.avatar!.isNotEmpty) {
      ctrl.consumerImage = intent.avatar;
    }
    if (intent.offerSdp != null && intent.offerSdp!.isNotEmpty) {
      ctrl.incomingOfferSdp = intent.offerSdp;
    }

    // Direct instant transition to CallScreen (replacing Splash directly)
    Get.offAllNamed(AppRoutes.callScreen);

    // Run accept API in background without blocking screen transition
    Future(() async {
      try {
        String finalOfferSdp = ctrl.incomingOfferSdp ?? '';
        if (finalOfferSdp.isEmpty) {
          final fetchedSdp = await ctrl.fetchOfferSdpFromCurrentSession();
          if (fetchedSdp != null && fetchedSdp.isNotEmpty) {
            finalOfferSdp = fetchedSdp;
          }
        }
        bool success = false;
        if (finalOfferSdp.isNotEmpty) {
          success = await ctrl.acceptCall(finalOfferSdp);
        } else {
          success = await ctrl.acceptCallDirect();
        }
        FlutterCallkitIncoming.endCall(intent.sessionId.toString());
        if (success && ctrl.status.value == CallStatus.ongoing) {
          ctrl.session.showOngoingNotification();
        }
      } catch (e) {
        print('[SPLASH] Cold start call accept error: $e');
      }
    });
  }

  void _dispatchColdStartChat(ColdStartIntent intent) {
    final cleanName = intent.name?.isNotEmpty == true ? intent.name! : 'User';
    FloatingChatBubble.name = cleanName;
    SoundVibrationService().stopRingtone();
    FlutterCallkitIncoming.endCall(intent.sessionId.toString());

    final fallbackAcceptedAt = DateTime.now();
    final String startedAtStr = fallbackAcceptedAt.toUtc().toIso8601String();

    final chatScreen = ChatScreen(
      sessionId: intent.sessionId,
      initialStatus: 'ongoing',
      userName: cleanName,
      userImage: intent.avatar ?? '',
      startedAtString: startedAtStr,
    );

    // Direct transition to ChatScreen (replacing Splash directly)
    Get.offAll(() => chatScreen, binding: ChatBinding());

    // Run accept API in background
    Future(() async {
      try {
        if (Get.isRegistered<ApiClient>()) {
          await Get.find<ApiClient>().post(
            AppUrls.acceptChatSession(intent.sessionId),
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
        print('[SPLASH] Cold start chat accept error: $e');
      }
    });
  }

  void _dispatchColdStartAssistance(ColdStartIntent intent) {
    final userName = intent.name?.isNotEmpty == true ? intent.name! : 'User';
    final userImage = intent.avatar ?? '';
    Get.offAll(() => AssistanceChatRoomScreen(
      sessionId: intent.sessionId,
      userName: userName,
      userImage: userImage,
    ));
  }
}
