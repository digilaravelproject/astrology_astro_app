import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:async';
import 'package:get/get.dart';
import 'package:astro_astrologer/core/services/storage/shared_prefs.dart';
import 'package:astro_astrologer/core/constants/app_constants.dart';
import 'package:astro_astrologer/routes/route_helper.dart';
import 'package:astro_astrologer/features/splash/data/datasources/splash_service.dart';
import 'package:astro_astrologer/core/services/websocket/websocket_service.dart';
import 'package:astro_astrologer/core/services/fcm_notification_service.dart';
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

      // Initialize splash service
      final isReady = await _splashService.initialize();

      // Wait for 2 seconds to show splash screen
      await Future.delayed(const Duration(seconds: 2));

      bool cameraGranted = await Permission.camera.isGranted;
      bool micGranted = await Permission.microphone.isGranted;
      bool notifGranted = await Permission.notification.isGranted;

      if (cameraGranted && micGranted && notifGranted) {
        if (isReady) {
          // Check if user is logged in and has user data
          final isLoggedIn =
              SharedPrefs.getBool(AppConstants.isLoggedIn) ?? false;
          final userData = SharedPrefs.getString(AppConstants.userData);

          print(
            '[SPLASH] isLoggedIn: $isLoggedIn, hasUserData: ${userData != null && userData.isNotEmpty}',
          );

          if (isLoggedIn && userData != null && userData.isNotEmpty) {
            Get.find<WebSocketService>().connect();
            FCMNotificationService.registerDeviceToken(null);
            
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
      // Handle errors
      Get.offAllNamed(RouteHelper.getLoginRoute());
    } finally {
      isLoading.value = false;
    }
  }
}
