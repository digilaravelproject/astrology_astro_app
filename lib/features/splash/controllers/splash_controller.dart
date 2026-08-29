import 'package:permission_handler/permission_handler.dart';
import 'dart:async';
import 'package:get/get.dart';
import '../../../core/services/storage/shared_prefs.dart';
import '../../../core/constants/app_constants.dart';
import '../../../routes/route_helper.dart';
import '../domain/services/splash_service.dart';
import '../../../core/services/network/websocket_service.dart';
import '../../../core/services/fcm_notification_service.dart';

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

      if (isReady) {
        // Wait for 2 seconds to show splash screen
        await Future.delayed(const Duration(seconds: 2));

        // Check if user is logged in and has user data
        final isLoggedIn =
            SharedPrefs.getBool(AppConstants.isLoggedIn) ?? false;
        final userData = SharedPrefs.getString(AppConstants.userData);

        print(
          '[SPLASH] isLoggedIn: $isLoggedIn, hasUserData: ${userData != null && userData.isNotEmpty}',
        );

        bool cameraGranted = await Permission.camera.isGranted;
        bool micGranted = await Permission.microphone.isGranted;
        bool notifGranted = await Permission.notification.isGranted;

        if (cameraGranted && micGranted && notifGranted) {
          if (isLoggedIn && userData != null && userData.isNotEmpty) {
            Get.find<WebSocketService>().connect();
            FCMNotificationService.registerDeviceToken(null);
            Get.offAllNamed(RouteHelper.getDashboardRoute());
          } else {
            Get.offAllNamed(RouteHelper.getLoginRoute());
          }
        } else {
          Get.offAllNamed(RouteHelper.getPermissionRoute());
        }
      } else {
        // Handle maintenance or version issues
        // For now, just navigate to login
        Get.offAllNamed(RouteHelper.getLoginRoute());
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
