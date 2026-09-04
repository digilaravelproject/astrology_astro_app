import 'package:get/get.dart';
import 'package:astro_astrologer/features/panchang/data/repositories/panchang_repository_impl.dart';
import 'package:astro_astrologer/features/panchang/presentation/controllers/panchang_controller.dart';
import 'package:astro_astrologer/features/panchang/domain/repositories/panchang_repository.dart';
import 'package:astro_astrologer/features/panchang/domain/usecases/get_panchang_usecase.dart';

class PanchangBinding extends Bindings {
  @override
  void dependencies() {
    // Repository
    Get.lazyPut<PanchangRepository>(() => PanchangRepositoryImpl());

    // UseCase
    Get.lazyPut<GetPanchangUseCase>(
      () => GetPanchangUseCase(repository: Get.find<PanchangRepository>()),
    );

    // Controller
    Get.lazyPut<PanchangController>(
      () => PanchangController(
        getPanchangUseCase: Get.find<GetPanchangUseCase>(),
      ),
    );
  }
}
