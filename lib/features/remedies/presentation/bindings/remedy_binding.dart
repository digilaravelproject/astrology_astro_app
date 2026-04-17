import 'package:get/get.dart';
import '../../data/datasources/remedy_remote_data_source.dart';
import '../../data/repositories/remedy_repository.dart';
import '../../domain/usecases/get_remedies_usecase.dart';
import '../../domain/usecases/get_remedy_details_usecase.dart';
import '../controllers/remedy_controller.dart';

class RemedyBinding extends Bindings {
  @override
  void dependencies() {
    // Data Source
    Get.lazyPut<RemedyRemoteDataSourceInterface>(() => RemedyRemoteDataSource(apiClient: Get.find()));

    // Repository
    Get.lazyPut<RemedyRepositoryInterface>(() => RemedyRepository(remoteDataSource: Get.find<RemedyRemoteDataSourceInterface>()));

    // UseCase
    Get.lazyPut(() => GetRemediesUseCase(Get.find<RemedyRepositoryInterface>()));
    Get.lazyPut(() => GetRemedyDetailsUseCase(Get.find<RemedyRepositoryInterface>()));

    // Controller
    Get.lazyPut(() => RemedyController(
          getRemediesUseCase: Get.find(),
          getRemedyDetailsUseCase: Get.find(),
        ));
  }
}
