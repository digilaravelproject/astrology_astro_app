import 'package:get/get.dart';
import '../../../../core/services/network/api_client.dart';
import '../../data/datasources/live_session_remote_data_source.dart';
import '../../data/repositories/live_session_repository.dart';
import '../../domain/repositories/live_session_repository_interface.dart';
import '../../domain/usecases/live_session_usecases.dart';
import '../controllers/live_session_controller.dart';

class LiveScheduleBinding extends Bindings {
  @override
  void dependencies() {
    // Data Source
    Get.lazyPut<LiveSessionRemoteDataSource>(
      () => LiveSessionRemoteDataSource(Get.find<ApiClient>()),
    );

    // Repository
    Get.lazyPut<LiveSessionRepositoryInterface>(
      () => LiveSessionRepository(Get.find<LiveSessionRemoteDataSource>()),
    );

    // Use Cases
    Get.lazyPut<GetLiveSessionsUseCase>(
      () => GetLiveSessionsUseCase(Get.find<LiveSessionRepositoryInterface>()),
    );
    Get.lazyPut<CreateLiveSessionUseCase>(
      () => CreateLiveSessionUseCase(Get.find<LiveSessionRepositoryInterface>()),
    );
    Get.lazyPut<DeleteLiveSessionUseCase>(
      () => DeleteLiveSessionUseCase(Get.find<LiveSessionRepositoryInterface>()),
    );

    // Controller
    Get.lazyPut<LiveSessionController>(
      () => LiveSessionController(
        Get.find<GetLiveSessionsUseCase>(),
        Get.find<CreateLiveSessionUseCase>(),
        Get.find<DeleteLiveSessionUseCase>(),
      ),
    );
  }
}
