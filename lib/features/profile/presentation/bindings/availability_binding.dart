import 'package:get/get.dart';
import '../../../../core/services/network/api_client.dart';
import '../../data/datasources/availability_remote_data_source.dart';
import '../../data/repositories/availability_repository.dart';
import '../../domain/repositories/availability_repository_interface.dart';
import '../../domain/usecases/get_availability_usecase.dart';
import '../../domain/usecases/update_availability_usecase.dart';
import '../controllers/availability_controller.dart';

class AvailabilityBinding extends Bindings {
  @override
  void dependencies() {
    // Data Source
    Get.lazyPut<AvailabilityRemoteDataSource>(
      () => AvailabilityRemoteDataSource(Get.find<ApiClient>()),
    );

    // Repository
    Get.lazyPut<AvailabilityRepositoryInterface>(
      () => AvailabilityRepository(Get.find<AvailabilityRemoteDataSource>()),
    );

    // Use Cases
    Get.lazyPut<GetAvailabilityUseCase>(
      () => GetAvailabilityUseCase(Get.find<AvailabilityRepositoryInterface>()),
    );

    Get.lazyPut<UpdateAvailabilityUseCase>(
      () => UpdateAvailabilityUseCase(Get.find<AvailabilityRepositoryInterface>()),
    );

    // Controller
    Get.lazyPut<AvailabilityController>(
      () => AvailabilityController(
        Get.find<GetAvailabilityUseCase>(),
        Get.find<UpdateAvailabilityUseCase>(),
      ),
    );
  }
}
