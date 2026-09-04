import 'package:get/get.dart';
import 'package:astro_astrologer/features/call/presentation/controllers/call_controller.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:astro_astrologer/core/services/network/api_client.dart';
import 'package:astro_astrologer/core/services/network/network_info.dart';
import 'package:dio/dio.dart';
import 'package:astro_astrologer/core/services/network/websocket_service.dart';
import 'package:astro_astrologer/features/chat/data/datasources/chat_remote_data_source.dart';
import 'package:astro_astrologer/features/chat/data/datasources/chat_local_data_source.dart';
import 'package:astro_astrologer/features/chat/data/repositories/chat_repository_impl.dart';
import 'package:astro_astrologer/features/chat/domain/repositories/i_chat_repository.dart';
import 'package:astro_astrologer/features/chat/domain/usecases/sync_message_status_usecase.dart';
import 'package:astro_astrologer/features/notification/data/repositories/notice_repository.dart';
import 'package:astro_astrologer/features/notification/data/datasources/notice_service.dart';
import 'package:astro_astrologer/features/notification/presentation/controllers/notice_controller.dart';
import 'package:astro_astrologer/features/auth/presentation/controllers/auth_controller.dart';
import 'package:astro_astrologer/features/home/presentation/controllers/dashboard_controller.dart';
import 'package:astro_astrologer/features/followers/data/repositories/follower_repository.dart';
import 'package:astro_astrologer/features/followers/data/datasources/follower_service.dart';
import 'package:astro_astrologer/features/followers/presentation/controllers/follower_controller.dart';
import 'package:astro_astrologer/features/profile/dataSource/skill_data_source.dart';
import 'package:astro_astrologer/features/profile/repository/skill_repository.dart';
import 'package:astro_astrologer/features/profile/usecase/skill_usecase.dart';
import 'package:astro_astrologer/features/live/presentation/bindings/live_binding.dart';
import 'package:astro_astrologer/features/live/presentation/controllers/live_controller.dart';

import 'package:astro_astrologer/features/auth/domain/repositories/auth_repository.dart';
import 'package:astro_astrologer/features/auth/data/datasources/auth_service.dart';
import 'package:astro_astrologer/features/splash/presentation/controllers/splash_controller.dart';
import 'package:astro_astrologer/features/splash/domain/repositories/splash_repository.dart';
import 'package:astro_astrologer/features/splash/data/datasources/splash_service.dart';
import 'package:astro_astrologer/features/training/dataSource/training_video_data_source.dart';
import 'package:astro_astrologer/features/training/repository/training_video_repository.dart';
import 'package:astro_astrologer/features/training/usecase/training_video_use_case.dart';
import 'package:astro_astrologer/features/training/controller/training_video_controller.dart';
import 'package:astro_astrologer/features/training/controller/training_video_detail_controller.dart';
import 'package:astro_astrologer/features/notification/data/repositories/notification_repository.dart';
import 'package:astro_astrologer/features/notification/domain/usecases/get_notification_count_usecase.dart';
import 'package:astro_astrologer/features/notification/domain/usecases/get_notifications_usecase.dart';
import 'package:astro_astrologer/features/notification/domain/usecases/get_notification_detail_usecase.dart';
import 'package:astro_astrologer/features/notification/domain/usecases/mark_notification_read_usecase.dart';
import 'package:astro_astrologer/features/notification/domain/usecases/mark_all_notifications_read_usecase.dart';
import 'package:astro_astrologer/features/notification/domain/usecases/delete_notification_usecase.dart';
import 'package:astro_astrologer/features/notification/domain/usecases/delete_all_notifications_usecase.dart';
import 'package:astro_astrologer/features/notification/presentation/controllers/notification_controller.dart';
import 'package:astro_astrologer/features/schedule/data/datasources/schedule_remote_data_source.dart';
import 'package:astro_astrologer/features/schedule/data/repositories/schedule_repository.dart';
import 'package:astro_astrologer/features/schedule/domain/usecases/set_sleep_hours_usecase.dart';
import 'package:astro_astrologer/features/schedule/domain/usecases/get_sleep_hours_usecase.dart';
import 'package:astro_astrologer/features/schedule/presentation/controllers/schedule_controller.dart';

import '../../features/profile/presentation/controllers/skill_controller.dart';


class InitialBindings extends Bindings {
  @override
  void dependencies() {
    // Core services
    Get.lazyPut(() => Dio(), fenix: true);
    Get.lazyPut(() => ApiClient(), fenix: true);
    Get.lazyPut(() => Connectivity(), fenix: true);
    Get.lazyPut(() => NetworkInfo(Get.find<Connectivity>()), fenix: true);
    Get.putAsync<WebSocketService>(
      () => WebSocketService().init(),
      permanent: true,
    );

    // Chat global dependencies (needed by WebSocketService)
    Get.lazyPut<IChatRemoteDataSource>(
      () => ChatRemoteDataSourceImpl(apiClient: Get.find<ApiClient>()),
      fenix: true,
    );
    Get.lazyPut<IChatLocalDataSource>(
      () => ChatLocalDataSourceImpl(),
      fenix: true,
    );
    Get.lazyPut<IChatRepository>(
      () => ChatRepositoryImpl(
        remoteDataSource: Get.find<IChatRemoteDataSource>(),
        localDataSource: Get.find<IChatLocalDataSource>(),
      ),
      fenix: true,
    );
    Get.lazyPut(
      () => SyncMessageStatusUseCase(Get.find<IChatRepository>()),
      fenix: true,
    );

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
    Get.lazyPut(
      () => CheckLoginStatusUseCase(Get.find<AuthService>()),
      fenix: true,
    );
    Get.lazyPut(() => GetUserInfoUseCase(Get.find<AuthService>()), fenix: true);
    Get.lazyPut(
      () => AstrologerSignupUseCase(Get.find<AuthService>()),
      fenix: true,
    );
    Get.lazyPut(() => ResendOtpUseCase(Get.find<AuthService>()), fenix: true);
    Get.lazyPut(
      () => UpdateProfilePhotoUseCase(Get.find<AuthService>()),
      fenix: true,
    );
    Get.lazyPut(
      () => UpdateProfileUseCase(Get.find<AuthService>()),
      fenix: true,
    );
    Get.lazyPut(() => GetProfileUseCase(Get.find<AuthService>()), fenix: true);
    Get.lazyPut(
      () => DeleteAccountUseCase(Get.find<AuthService>()),
      fenix: true,
    );
    Get.lazyPut(
      () => ToggleOnlineUseCase(Get.find<AuthService>()),
      fenix: true,
    );

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
        deleteAccountUseCase: Get.find<DeleteAccountUseCase>(),
        toggleOnlineUseCase: Get.find<ToggleOnlineUseCase>(),
      ),
      fenix: true,
    );

    // Notification / Notice
    Get.lazyPut(() => NoticeRepository(Get.find<ApiClient>()), fenix: true);
    Get.lazyPut(() => NoticeService(Get.find<NoticeRepository>()), fenix: true);
    Get.lazyPut(
      () => GetNoticesUseCase(Get.find<NoticeService>()),
      fenix: true,
    );
    Get.lazyPut(
      () => NoticeController(getNoticesUseCase: Get.find<GetNoticesUseCase>()),
      fenix: true,
    );

    // Home / Dashboard
    Get.lazyPut(() => DashboardController(), fenix: true);

    Get.lazyPut(() => FollowerRepository(Get.find<ApiClient>()), fenix: true);
    Get.lazyPut(
      () => FollowerService(Get.find<FollowerRepository>()),
      fenix: true,
    );
    Get.lazyPut(
      () => GetFollowersUseCase(Get.find<FollowerService>()),
      fenix: true,
    );
    Get.lazyPut(
      () => GetFavoritesUseCase(Get.find<FollowerService>()),
      fenix: true,
    );
    Get.lazyPut(
      () => ToggleLikeUseCase(Get.find<FollowerService>()),
      fenix: true,
    );
    Get.lazyPut(
      () => FollowerController(
        getFollowersUseCase: Get.find<GetFollowersUseCase>(),
        getFavoritesUseCase: Get.find<GetFavoritesUseCase>(),
        toggleLikeUseCase: Get.find<ToggleLikeUseCase>(),
      ),
      fenix: true,
    );

    // Profile / Skills
    Get.lazyPut(
      () => AstrologerSkillsRemoteDataSource(Get.find<ApiClient>()),
      fenix: true,
    );
    Get.lazyPut(
      () => AstrologerSkillsRepository(
        Get.find<AstrologerSkillsRemoteDataSource>(),
      ),
      fenix: true,
    );
    Get.lazyPut(
      () =>
          UpdateAstrologerSkillsUseCase(Get.find<AstrologerSkillsRepository>()),
      fenix: true,
    );
    Get.lazyPut(
      () =>
          AstrologerSkillsController(Get.find<UpdateAstrologerSkillsUseCase>()),
      fenix: true,
    );

    // Training Videos
    Get.lazyPut(
      () => TrainingVideoRemoteDataSource(Get.find<ApiClient>()),
      fenix: true,
    );
    Get.lazyPut(
      () => TrainingVideoRepository(Get.find<TrainingVideoRemoteDataSource>()),
      fenix: true,
    );
    Get.lazyPut(
      () => GetTrainingVideosUseCase(Get.find<TrainingVideoRepository>()),
      fenix: true,
    );
    Get.lazyPut(
      () => GetTrainingVideoDetailUseCase(Get.find<TrainingVideoRepository>()),
      fenix: true,
    );
    Get.lazyPut(
      () => TrainingVideoController(Get.find<GetTrainingVideosUseCase>()),
      fenix: true,
    );
    Get.lazyPut(
      () => TrainingVideoDetailController(
        Get.find<GetTrainingVideoDetailUseCase>(),
      ),
      fenix: true,
    );

    // Schedule
    Get.lazyPut(
      () => ScheduleRemoteDataSource(Get.find<ApiClient>()),
      fenix: true,
    );
    Get.lazyPut(
      () => ScheduleRepository(Get.find<ScheduleRemoteDataSource>()),
      fenix: true,
    );
    Get.lazyPut(
      () => SetSleepHoursUseCase(Get.find<ScheduleRepository>()),
      fenix: true,
    );
    Get.lazyPut(
      () => GetSleepHoursUseCase(Get.find<ScheduleRepository>()),
      fenix: true,
    );
    Get.lazyPut(
      () => ScheduleController(
        Get.find<SetSleepHoursUseCase>(),
        Get.find<GetSleepHoursUseCase>(),
      ),
      fenix: true,
    );

    // Notification Count & List
    Get.lazyPut(
      () => NotificationRepository(Get.find<ApiClient>()),
      fenix: true,
    );
    Get.lazyPut(
      () => GetNotificationCountUseCase(Get.find<NotificationRepository>()),
      fenix: true,
    );
    Get.lazyPut(
      () => GetNotificationsUseCase(Get.find<NotificationRepository>()),
      fenix: true,
    );
    Get.lazyPut(
      () => GetNotificationDetailUseCase(Get.find<NotificationRepository>()),
      fenix: true,
    );
    Get.lazyPut(
      () => MarkNotificationReadUseCase(Get.find<NotificationRepository>()),
      fenix: true,
    );
    Get.lazyPut(
      () => MarkAllNotificationsReadUseCase(Get.find<NotificationRepository>()),
      fenix: true,
    );
    Get.lazyPut(
      () => DeleteNotificationUseCase(Get.find<NotificationRepository>()),
      fenix: true,
    );
    Get.lazyPut(
      () => DeleteAllNotificationsUseCase(Get.find<NotificationRepository>()),
      fenix: true,
    );
    Get.put(
      NotificationController(
        Get.find<GetNotificationCountUseCase>(),
        Get.find<GetNotificationsUseCase>(),
        Get.find<GetNotificationDetailUseCase>(),
        Get.find<MarkNotificationReadUseCase>(),
        Get.find<MarkAllNotificationsReadUseCase>(),
        Get.find<DeleteNotificationUseCase>(),
        Get.find<DeleteAllNotificationsUseCase>(),
      ),
      permanent: true,
    );

    // Call dependencies
    Get.put(CallController(), permanent: true);

    // Live dependencies
    LiveBinding().dependencies();
    Get.find<LiveController>();
  }
}
