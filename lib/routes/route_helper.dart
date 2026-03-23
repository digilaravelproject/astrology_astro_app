import 'package:astro_astrologer/features/profile/screens/skill_details_screen.dart';
import 'package:get/get.dart';
import '../features/auth/screens/login_screen.dart';
import '../features/auth/screens/otp_verification_screen.dart';
import '../features/auth/screens/registration_screen.dart';
import '../features/profile/binding/skill_binding.dart';
import '../features/splash/screens/splash_screen.dart';
import '../features/home/screens/home_screen.dart';
import '../features/home/screens/dashboard_screen.dart';
import 'app_routes.dart';

class RouteHelper {
  static String getSplashRoute() => AppRoutes.splash;
  static String getLoginRoute() => AppRoutes.login;
  static String getOtpRoute() => AppRoutes.otp;
  static String getRegistrationNameRoute() => AppRoutes.registrationName;
  static String getHomeRoute() => AppRoutes.home;
  static String getDashboardRoute() => AppRoutes.dashboard;

  static List<GetPage> routes = [
    GetPage(
      name: AppRoutes.splash,
      page: () => const SplashScreen(),
    ),
    GetPage(
      name: AppRoutes.login,
      page: () => const LoginScreen(),
      transition: Transition.fadeIn,
    ),
    GetPage(
      name: AppRoutes.otp,
      page: () => const OtpVerificationScreen(),
      transition: Transition.rightToLeft,
    ),
    GetPage(
      name: AppRoutes.registrationName,
      page: () => const RegistrationScreen(),
      transition: Transition.rightToLeft,
    ),
    GetPage(
      name: AppRoutes.home,
      page: () => const DashboardScreen(),
      transition: Transition.fadeIn,
    ),
    GetPage(
      name: AppRoutes.dashboard,
      page: () => const DashboardScreen(),
      transition: Transition.fadeIn,
    ),
    GetPage(
      name: AppRoutes.skillDetailScreen,
      page: () => const SkillDetailsScreen(),
      binding: AstrologerSkillsBinding(),
      transition: Transition.fadeIn,
    ),
  ];
}
