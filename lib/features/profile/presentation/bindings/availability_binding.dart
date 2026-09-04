import 'package:get/get.dart';
import 'package:astro_astrologer/core/services/network/api_client.dart';
import 'package:astro_astrologer/features/profile/data/datasources/availability_remote_data_source.dart';
import 'package:astro_astrologer/features/profile/data/repositories/availability_repository.dart';
import 'package:astro_astrologer/features/profile/domain/repositories/availability_repository_interface.dart';
import 'package:astro_astrologer/features/profile/domain/usecases/get_availability_usecase.dart';
import 'package:astro_astrologer/features/profile/domain/usecases/update_availability_usecase.dart';
import 'package:astro_astrologer/features/profile/presentation/controllers/availability_controller.dart';

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
      () => UpdateAvailabilityUseCase(
        Get.find<AvailabilityRepositoryInterface>(),
      ),
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
