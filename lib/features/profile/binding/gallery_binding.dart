import 'package:get/get.dart';
import 'package:astro_astrologer/core/utils/logger.dart';
import 'package:astro_astrologer/features/profile/repository/gallery_repository.dart';
import 'package:astro_astrologer/features/profile/usecase/gallery_usecases.dart';
import 'package:astro_astrologer/features/profile/controllers/gallery_controller.dart';

class GalleryBinding extends Bindings {
  @override
  void dependencies() {
    Logger.d('GalleryBinding: Initializing dependencies');
    Get.lazyPut(() => GalleryRepository(apiClient: Get.find()));
    Get.lazyPut(() => GetGalleryImagesUseCase(repository: Get.find()));
    Get.lazyPut(() => UploadGalleryImagesUseCase(repository: Get.find()));
    Get.lazyPut(() => ToggleGalleryVisibilityUseCase(repository: Get.find()));
    Get.lazyPut(() => DeleteGalleryImageUseCase(repository: Get.find()));
    
    Logger.d('GalleryBinding: Putting GalleryController');
    Get.put(GalleryController(
      getGalleryImagesUseCase: Get.find(),
      uploadGalleryImagesUseCase: Get.find(),
      toggleGalleryVisibilityUseCase: Get.find(),
      deleteGalleryImageUseCase: Get.find(),
    ));
  }
}
