import 'dart:io';
import 'package:get/get.dart';
import 'package:astro_astrologer/core/utils/custom_snackbar.dart';
import 'package:astro_astrologer/features/profile/model/gallery_model.dart';
import 'package:astro_astrologer/features/profile/usecase/gallery_usecases.dart';

class GalleryController extends GetxController {
  final GetGalleryImagesUseCase getGalleryImagesUseCase;
  final UploadGalleryImagesUseCase uploadGalleryImagesUseCase;
  final ToggleGalleryVisibilityUseCase toggleGalleryVisibilityUseCase;
  final DeleteGalleryImageUseCase deleteGalleryImageUseCase;

  GalleryController({
    required this.getGalleryImagesUseCase,
    required this.uploadGalleryImagesUseCase,
    required this.toggleGalleryVisibilityUseCase,
    required this.deleteGalleryImageUseCase,
  });

  var images = <GalleryImage>[].obs;
  var isLoading = false.obs;
  var isUploading = false.obs;

  @override
  void onInit() {
    super.onInit();
    fetchImages();
  }

  Future<void> fetchImages() async {
    isLoading.value = true;
    try {
      final result = await getGalleryImagesUseCase.execute(status: 'all');
      images.assignAll(result);
    } catch (e) {
      CustomSnackBar.showError('Failed to fetch images: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> uploadImages(List<File> files) async {
    if (files.isEmpty) return;
    
    isUploading.value = true;
    try {
      final response = await uploadGalleryImagesUseCase.execute(files, 'pending');
      if (response.isSuccess) {
        CustomSnackBar.showSuccess('Images uploaded successfully');
        fetchImages();
      } else {
        CustomSnackBar.showError(response.message);
      }
    } catch (e) {
      CustomSnackBar.showError('Upload failed: $e');
    } finally {
      isUploading.value = false;
    }
  }

  Future<void> toggleVisibility(int id) async {
    try {
      final response = await toggleGalleryVisibilityUseCase.execute(id);
      if (response.isSuccess) {
        // Update local state
        final index = images.indexWhere((img) => img.id == id);
        if (index != -1) {
          final img = images[index];
          images[index] = GalleryImage(
            id: img.id,
            url: img.url,
            status: img.status,
            isVisible: !img.isVisible,
            createdAt: img.createdAt,
          );
        }
        CustomSnackBar.showSuccess('Visibility updated');
      } else {
        CustomSnackBar.showError(response.message);
      }
    } catch (e) {
      CustomSnackBar.showError('Failed to toggle visibility: $e');
    }
  }

  Future<void> deleteImage(int id) async {
    try {
      final response = await deleteGalleryImageUseCase.execute(id);
      if (response.isSuccess) {
        images.removeWhere((img) => img.id == id);
        CustomSnackBar.showSuccess('Image deleted successfully');
      } else {
        CustomSnackBar.showError(response.message);
      }
    } catch (e) {
      CustomSnackBar.showError('Failed to delete image: $e');
    }
  }
}
