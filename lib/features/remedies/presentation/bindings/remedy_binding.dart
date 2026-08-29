import 'package:get/get.dart';
import '../../../../core/services/network/api_client.dart';
import '../../data/datasources/remedy_remote_data_source.dart';
import '../../data/repositories/remedy_repository.dart';
import '../../domain/usecases/get_remedies_usecase.dart';
import '../../domain/usecases/get_remedy_details_usecase.dart';
import '../controllers/remedy_controller.dart';

class RemedyBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => RemedyRemoteDataSource(Get.find<ApiClient>()));
    Get.lazyPut(() => RemedyRepository(Get.find<RemedyRemoteDataSource>()));
    Get.lazyPut(() => GetRemediesUseCase(Get.find<RemedyRepository>()));
    Get.lazyPut(() => GetRemedyDetailsUseCase(Get.find<RemedyRepository>()));
    Get.lazyPut(
      () => RemedyController(
        Get.find<GetRemediesUseCase>(),
        Get.find<GetRemedyDetailsUseCase>(),
      ),
    );
  }
}
