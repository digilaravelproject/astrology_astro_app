import 'package:get/get.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import '../services/network/api_client.dart';
import '../services/network/network_info.dart';
import 'package:dio/dio.dart';
import '../../features/notification/data/repositories/notice_repository.dart';
import '../../features/notification/domain/services/notice_service.dart';
import '../../features/notification/controllers/notice_controller.dart';
import '../../features/auth/controllers/auth_controller.dart';
import '../../features/home/controllers/dashboard_controller.dart';
import '../../features/followers/data/repositories/follower_repository.dart';
import '../../features/followers/domain/services/follower_service.dart';
import '../../features/followers/controllers/follower_controller.dart';
import '../../features/profile/controllers/skill_controller.dart';
import '../../features/profile/dataSource/skill_data_source.dart';
import '../../features/profile/repository/skill_repository.dart';
import '../../features/profile/usecase/skill_usecase.dart';

import '../../features/auth/domain/repositories/auth_repository.dart';
import '../../features/auth/domain/services/auth_service.dart';
import '../../features/splash/controllers/splash_controller.dart';
import '../../features/splash/domain/repositories/splash_repository.dart';
import '../../features/splash/domain/services/splash_service.dart';
import '../../features/training/dataSource/training_video_data_source.dart';
import '../../features/training/repository/training_video_repository.dart';
import '../../features/training/usecase/training_video_use_case.dart';
import '../../features/training/controller/training_video_controller.dart';
import '../../features/training/controller/training_video_detail_controller.dart';

class InitialBindings extends Bindings {
  @override
  void dependencies() {
    // Core services
    Get.lazyPut(() => Dio(), fenix: true);
    Get.lazyPut(() => ApiClient(), fenix: true);
    Get.lazyPut(() => Connectivity(), fenix: true);
    Get.lazyPut(() => NetworkInfo(Get.find<Connectivity>()), fenix: true);

    // Splash
    Get.lazyPut(() => SplashRepository(Get.find<ApiClient>()), fenix: true);
    Get.lazyPut(() => SplashService(Get.find<SplashRepository>()), fenix: true);
    Get.lazyPut(() => SplashController(Get.find<SplashService>()), fenix: true);

    // Auth
    Get.lazyPut(() => AuthRepository(Get.find<ApiClient>()), fenix: true);
    Get.lazyPut(() => AuthService(Get.find<AuthRepository>()), fenix: true);
    Get.lazyPut(() => LoginUseCase(Get.find<AuthService>()), fenix: true);
    Get.lazyPut(() => RegisterUseCase(Get.find<AuthService>()), fenix: true);
    Get.lazyPut(() => VerifyOtpUseCase(Get.find<AuthService>()), fenix: true);
    Get.lazyPut(() => SendOtpUseCase(Get.find<AuthService>()), fenix: true);
    Get.lazyPut(() => LogoutUseCase(Get.find<AuthService>()), fenix: true);
    Get.lazyPut(() => CheckLoginStatusUseCase(Get.find<AuthService>()), fenix: true);
    Get.lazyPut(() => GetUserInfoUseCase(Get.find<AuthService>()), fenix: true);
    Get.lazyPut(() => AstrologerSignupUseCase(Get.find<AuthService>()), fenix: true);
    Get.lazyPut(() => ResendOtpUseCase(Get.find<AuthService>()), fenix: true);
    Get.lazyPut(() => UpdateProfilePhotoUseCase(Get.find<AuthService>()), fenix: true);
    Get.lazyPut(() => UpdateProfileUseCase(Get.find<AuthService>()), fenix: true);
    Get.lazyPut(() => GetProfileUseCase(Get.find<AuthService>()), fenix: true);
    
    Get.lazyPut(
          () => AuthController(
        loginUseCase: Get.find<LoginUseCase>(),
        registerUseCase: Get.find<RegisterUseCase>(),
        verifyOtpUseCase: Get.find<VerifyOtpUseCase>(),
        sendOtpUseCase: Get.find<SendOtpUseCase>(),
        logoutUseCase: Get.find<LogoutUseCase>(),
        checkLoginStatusUseCase: Get.find<CheckLoginStatusUseCase>(),
        getUserInfoUseCase: Get.find<GetUserInfoUseCase>(),
        astrologerSignupUseCase: Get.find<AstrologerSignupUseCase>(),
        resendOtpUseCase: Get.find<ResendOtpUseCase>(),
        updateProfilePhotoUseCase: Get.find<UpdateProfilePhotoUseCase>(),
        updateProfileUseCase: Get.find<UpdateProfileUseCase>(),
        getProfileUseCase: Get.find<GetProfileUseCase>(),
      ),
      fenix: true,
    );

    // Notification / Notice
    Get.lazyPut(() => NoticeRepository(Get.find<ApiClient>()), fenix: true);
    Get.lazyPut(() => NoticeService(Get.find<NoticeRepository>()), fenix: true);
    Get.lazyPut(() => GetNoticesUseCase(Get.find<NoticeService>()), fenix: true);
    Get.lazyPut(() => NoticeController(getNoticesUseCase: Get.find<GetNoticesUseCase>()), fenix: true);

    // Home / Dashboard
    Get.lazyPut(() => DashboardController(), fenix: true);

    Get.lazyPut(() => FollowerRepository(Get.find<ApiClient>()), fenix: true);
    Get.lazyPut(() => FollowerService(Get.find<FollowerRepository>()), fenix: true);
    Get.lazyPut(() => GetFollowersUseCase(Get.find<FollowerService>()), fenix: true);
    Get.lazyPut(() => GetFavoritesUseCase(Get.find<FollowerService>()), fenix: true);
    Get.lazyPut(() => ToggleLikeUseCase(Get.find<FollowerService>()), fenix: true);
    Get.lazyPut(() => FollowerController(
      getFollowersUseCase: Get.find<GetFollowersUseCase>(),
      getFavoritesUseCase: Get.find<GetFavoritesUseCase>(),
      toggleLikeUseCase: Get.find<ToggleLikeUseCase>(),
    ), fenix: true);

    // Profile / Skills
    Get.lazyPut(() => AstrologerSkillsRemoteDataSource(Get.find<ApiClient>()), fenix: true);
    Get.lazyPut(() => AstrologerSkillsRepository(Get.find<AstrologerSkillsRemoteDataSource>()), fenix: true);
    Get.lazyPut(() => UpdateAstrologerSkillsUseCase(Get.find<AstrologerSkillsRepository>()), fenix: true);
    Get.lazyPut(() => AstrologerSkillsController(Get.find<UpdateAstrologerSkillsUseCase>()), fenix: true);

    // Training Videos
    Get.lazyPut(() => TrainingVideoRemoteDataSource(Get.find<ApiClient>()), fenix: true);
    Get.lazyPut(() => TrainingVideoRepository(Get.find<TrainingVideoRemoteDataSource>()), fenix: true);
    Get.lazyPut(() => GetTrainingVideosUseCase(Get.find<TrainingVideoRepository>()), fenix: true);
    Get.lazyPut(() => GetTrainingVideoDetailUseCase(Get.find<TrainingVideoRepository>()), fenix: true);
    Get.lazyPut(() => TrainingVideoController(Get.find<GetTrainingVideosUseCase>()), fenix: true);
    Get.lazyPut(() => TrainingVideoDetailController(Get.find<GetTrainingVideoDetailUseCase>()), fenix: true);
  }
}
