import 'package:astro_astrologer/features/profile/screens/skill_details_screen.dart';
import 'package:astro_astrologer/features/profile/screens/other_details_screen.dart';
import 'package:astro_astrologer/features/training/training_videos_list_screen.dart';
import 'package:astro_astrologer/features/training/traning_video_binding.dart';
import 'package:astro_astrologer/features/schedule/set_sleep_hours_screen.dart';
import 'package:astro_astrologer/features/schedule/presentation/bindings/schedule_binding.dart';
import 'package:astro_astrologer/features/finance/presentation/screens/bank_accounts_screen.dart';
import 'package:astro_astrologer/features/finance/presentation/screens/add_bank_account_screen.dart';
import 'package:astro_astrologer/features/finance/presentation/bindings/finance_binding.dart';
import 'package:get/get.dart';
import '../features/auth/screens/login_screen.dart';
import '../features/auth/screens/otp_verification_screen.dart';
import '../features/auth/screens/registration_screen.dart';
import '../features/profile/binding/skill_binding.dart';
import '../features/profile/screens/faq_screen.dart';
import '../features/profile/screens/payment_policy_screen.dart';
import '../features/profile/screens/privacy_policy_screen.dart';
import '../features/profile/screens/terms_and_conditions_screen.dart';
import '../features/profile/screens/about_us_screen.dart';
import '../features/profile/screens/live_schedule_screen.dart';
import '../features/profile/presentation/bindings/live_schedule_binding.dart';
import '../features/profile/screens/feedback_screen.dart';
import '../features/profile/screens/help_support_screen.dart';
import 'package:astro_astrologer/features/profile/screens/gallery_screen.dart';
import 'package:astro_astrologer/features/profile/binding/gallery_binding.dart';
import 'package:astro_astrologer/features/profile/screens/my_reviews_screen.dart';
import 'package:astro_astrologer/features/profile/binding/review_binding.dart';
import '../features/splash/screens/splash_screen.dart';
import '../features/home/screens/home_screen.dart';
import '../features/home/screens/dashboard_screen.dart';
import '../features/support/presentation/bindings/support_binding.dart';
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
      binding: LiveScheduleBinding(),
      transition: Transition.rightToLeft,
    ),
  ];
}
