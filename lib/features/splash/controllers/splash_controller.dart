import 'dart:async';
import 'package:get/get.dart';
import '../../../core/services/storage/shared_prefs.dart';
import '../../../core/constants/app_constants.dart';
import '../../../routes/route_helper.dart';
import '../domain/services/splash_service.dart';

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
        final isLoggedIn = SharedPrefs.getBool(AppConstants.isLoggedIn) ?? false;
        final userData = SharedPrefs.getString(AppConstants.userData);

        print('[SPLASH] isLoggedIn: $isLoggedIn, hasUserData: ${userData != null && userData.isNotEmpty}');

        if (isLoggedIn && userData != null && userData.isNotEmpty) {
          print('[SPLASH] User is logged in, navigating to dashboard');
          Get.offAllNamed(RouteHelper.getDashboardRoute());
        } else {
          print('[SPLASH] User is not logged in, navigating to login');
          Get.offAllNamed(RouteHelper.getLoginRoute());
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
