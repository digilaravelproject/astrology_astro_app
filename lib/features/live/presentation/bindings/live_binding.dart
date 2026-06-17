import 'package:get/get.dart';
import '../../../../core/services/network/api_client.dart';
import '../../data/datasources/live_remote_data_source.dart';
import '../../data/repositories/live_repository_impl.dart';
import '../../domain/repositories/live_repository.dart';
import '../../domain/usecases/live_usecases.dart';
import '../controllers/live_controller.dart';

class LiveBinding extends Bindings {
  @override
  void dependencies() {
    // Data Source
    Get.lazyPut<LiveRemoteDataSource>(
      () => LiveRemoteDataSource(Get.find<ApiClient>()),
    );

    // Repository
    Get.lazyPut<LiveRepository>(
      () => LiveRepositoryImpl(Get.find<LiveRemoteDataSource>()),
    );

    // Use Cases
    Get.lazyPut<GetLiveSessionsUseCase>(
      () => GetLiveSessionsUseCase(Get.find<LiveRepository>()),
    );
    Get.lazyPut<GetCurrentLiveSessionUseCase>(
      () => GetCurrentLiveSessionUseCase(Get.find<LiveRepository>()),
    );
    Get.lazyPut<CreateLiveSessionUseCase>(
      () => CreateLiveSessionUseCase(Get.find<LiveRepository>()),
    );
    Get.lazyPut<DeleteLiveSessionUseCase>(
      () => DeleteLiveSessionUseCase(Get.find<LiveRepository>()),
    );
    Get.lazyPut<StartLiveSessionUseCase>(
      () => StartLiveSessionUseCase(Get.find<LiveRepository>()),
    );
    Get.lazyPut<StopLiveSessionUseCase>(
      () => StopLiveSessionUseCase(Get.find<LiveRepository>()),
    );
    Get.lazyPut<UpdateLiveSessionUseCase>(
      () => UpdateLiveSessionUseCase(Get.find<LiveRepository>()),
    );
    Get.lazyPut<StartBroadcastUseCase>(
      () => StartBroadcastUseCase(Get.find<LiveRepository>()),
    );
    Get.lazyPut<StopBroadcastUseCase>(
      () => StopBroadcastUseCase(Get.find<LiveRepository>()),
    );
    Get.lazyPut<GetLiveCommentsUseCase>(
      () => GetLiveCommentsUseCase(Get.find<LiveRepository>()),
    );

    // Controller
    Get.lazyPut<LiveController>(
      () => LiveController(
        Get.find<GetLiveSessionsUseCase>(),
        Get.find<GetCurrentLiveSessionUseCase>(),
        Get.find<CreateLiveSessionUseCase>(),
        Get.find<DeleteLiveSessionUseCase>(),
        Get.find<StartLiveSessionUseCase>(),
        Get.find<StopLiveSessionUseCase>(),
        Get.find<UpdateLiveSessionUseCase>(),
        Get.find<StartBroadcastUseCase>(),
        Get.find<StopBroadcastUseCase>(),
        Get.find<GetLiveCommentsUseCase>(),
      ),
    );
  }
}

