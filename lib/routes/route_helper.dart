import 'package:astro_astrologer/features/chat/presentation/pages/chat_screen.dart';
import 'package:astro_astrologer/features/chat/presentation/bindings/chat_binding.dart';
import 'package:astro_astrologer/features/call/presentation/pages/call_screen.dart';
import 'package:astro_astrologer/features/live/presentation/pages/live_room_screen.dart';

import 'package:astro_astrologer/features/splash/presentation/screens/permission_screen.dart';
import 'package:astro_astrologer/features/profile/presentation/screens/skill_details_screen.dart';
import 'package:astro_astrologer/features/profile/presentation/screens/other_details_screen.dart';
import 'package:astro_astrologer/features/training/training_videos_list_screen.dart';
import 'package:astro_astrologer/features/training/traning_video_binding.dart';
import 'package:astro_astrologer/features/schedule/set_sleep_hours_screen.dart';
import 'package:astro_astrologer/features/schedule/presentation/bindings/schedule_binding.dart';
import 'package:astro_astrologer/features/finance/presentation/screens/bank_accounts_screen.dart';
import 'package:astro_astrologer/features/finance/presentation/screens/add_bank_account_screen.dart';
import 'package:astro_astrologer/features/finance/presentation/bindings/finance_binding.dart';
import 'package:get/get.dart';
import 'package:astro_astrologer/features/auth/presentation/screens/login_screen.dart';
import 'package:astro_astrologer/features/auth/presentation/screens/otp_verification_screen.dart';
import 'package:astro_astrologer/features/auth/presentation/screens/registration_screen.dart';
import 'package:astro_astrologer/features/profile/binding/skill_binding.dart';
import 'package:astro_astrologer/features/profile/presentation/screens/faq_screen.dart';
import 'package:astro_astrologer/features/profile/presentation/screens/payment_policy_screen.dart';
import 'package:astro_astrologer/features/profile/presentation/screens/privacy_policy_screen.dart';
import 'package:astro_astrologer/features/profile/presentation/screens/terms_and_conditions_screen.dart';
import 'package:astro_astrologer/features/profile/presentation/screens/about_us_screen.dart';
import 'package:astro_astrologer/features/live/presentation/pages/live_schedule_screen.dart';
import 'package:astro_astrologer/features/live/presentation/bindings/live_binding.dart';
import 'package:astro_astrologer/features/profile/presentation/screens/feedback_screen.dart';
import 'package:astro_astrologer/features/profile/presentation/screens/help_support_screen.dart';
import 'package:astro_astrologer/features/profile/presentation/screens/gallery_screen.dart';
import 'package:astro_astrologer/features/profile/binding/gallery_binding.dart';
import 'package:astro_astrologer/features/profile/presentation/screens/my_reviews_screen.dart';
import 'package:astro_astrologer/features/profile/binding/review_binding.dart';
import 'package:astro_astrologer/features/splash/presentation/screens/splash_screen.dart';
import 'package:astro_astrologer/features/home/presentation/screens/home_screen.dart';
import 'package:astro_astrologer/features/home/presentation/screens/dashboard_screen.dart';
import 'package:astro_astrologer/features/support/presentation/bindings/support_binding.dart';
import 'app_routes.dart';
import 'package:astro_astrologer/features/panchang/panchang_screen.dart';
import 'package:astro_astrologer/features/panchang/presentation/bindings/panchang_binding.dart';

class RouteHelper {
  static String getPermissionRoute() => AppRoutes.permission;
  static String getSplashRoute() => AppRoutes.splash;
  static String getLoginRoute() => AppRoutes.login;
  static String getOtpRoute() => AppRoutes.otp;
  static String getRegistrationNameRoute() => AppRoutes.registrationName;
  static String getHomeRoute() => AppRoutes.home;
  static String getDashboardRoute() => AppRoutes.dashboard;
  static String getPanchangRoute() => AppRoutes.panchangScreen;

  static List<GetPage> routes = [
    GetPage(name: AppRoutes.permission, page: () => const PermissionScreen()),
    GetPage(name: AppRoutes.splash, page: () => const SplashScreen()),
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
    GetPage(
      name: AppRoutes.otherDetailsScreen,
      page: () => const OtherDetailsScreen(),
      binding: AstrologerSkillsBinding(),
      transition: Transition.fadeIn,
    ),
    GetPage(
      name: AppRoutes.trainingVideosScreen,
      page: () => const TrainingVideosListScreen(),
      binding: TrainingVideoBinding(),
      transition: Transition.fadeIn,
    ),

    GetPage(
      name: AppRoutes.setSleepHoursScreen,
      page: () => const SetSleepHoursScreen(),
      binding: ScheduleBinding(),
      transition: Transition.rightToLeft,
    ),

    GetPage(
      name: AppRoutes.faq,
      page: () => const FaqScreen(),
      transition: Transition.rightToLeft,
      binding: SupportBinding(),
    ),
    GetPage(
      name: AppRoutes.privacyPolicy,
      page: () => const PrivacyPolicyScreen(),
      transition: Transition.rightToLeft,
      binding: SupportBinding(),
    ),
    GetPage(
      name: AppRoutes.paymentPolicy,
      page: () => const PaymentPolicyScreen(),
      transition: Transition.rightToLeft,
      binding: SupportBinding(),
    ),
    GetPage(
      name: AppRoutes.termsAndConditions,
      page: () => const TermsAndConditionsScreen(),
      transition: Transition.rightToLeft,
      binding: SupportBinding(),
    ),
    GetPage(
      name: AppRoutes.aboutUs,
      page: () => const AboutUsScreen(),
      transition: Transition.rightToLeft,
      binding: SupportBinding(),
    ),
    GetPage(
      name: AppRoutes.feedback,
      page: () => const FeedbackScreen(),
      transition: Transition.rightToLeft,
      binding: SupportBinding(),
    ),
    GetPage(
      name: AppRoutes.customerSupport,
      page: () => const HelpSupportScreen(),
      transition: Transition.rightToLeft,
      binding: SupportBinding(),
    ),
    GetPage(
      name: AppRoutes.gallery,
      page: () => const GalleryScreen(),
      binding: GalleryBinding(),
    ),
    GetPage(
      name: AppRoutes.myReviews,
      page: () => const MyReviewsScreen(),
      binding: ReviewBinding(),
      transition: Transition.rightToLeft,
    ),

    // Finance routes
    GetPage(
      name: AppRoutes.bankAccounts,
      page: () => const BankAccountsScreen(),
      binding: FinanceBinding(),
      transition: Transition.rightToLeft,
    ),
    GetPage(
      name: AppRoutes.addBankAccount,
      page: () => const AddBankAccountScreen(),
      binding: FinanceBinding(),
      transition: Transition.rightToLeft,
    ),
    GetPage(
      name: AppRoutes.liveSchedule,
      page: () => const LiveScheduleScreen(),
      binding: LiveBinding(),
      transition: Transition.rightToLeft,
    ),
    GetPage(
      name: AppRoutes.panchangScreen,
      page: () => const PanchangScreen(),
      binding: PanchangBinding(),
      transition: Transition.fadeIn,
    ),
    GetPage(
      name: AppRoutes.chatScreen,
      page: () {
        final args = Get.arguments as Map<String, dynamic>? ?? {};
        return ChatScreen(
          userName: args['userName'] ?? 'User',
          userImage: args['userImage'] ?? '',
          sessionId: args['sessionId'] ?? 0,
          initialStatus: args['initialStatus'] ?? 'ongoing',
          isPackageChat: args['isPackageChat'] ?? false,
        );
      },
      binding: ChatBinding(),
    ),
    GetPage(
      name: AppRoutes.callScreen,
      page: () => const CallScreen(),
    ),
    GetPage(
      name: AppRoutes.liveRoomScreen,
      page: () {
        final session = Get.arguments;
        return LiveRoomScreen(session: session);
      },
      binding: LiveBinding(),
    ),
  ];
}
