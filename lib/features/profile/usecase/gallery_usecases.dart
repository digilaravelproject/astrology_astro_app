import 'dart:io';
import 'package:astro_astrologer/core/services/network/response_model.dart';
import 'package:astro_astrologer/features/profile/model/gallery_model.dart';
import 'package:astro_astrologer/features/profile/repository/gallery_repository.dart';

class GetGalleryImagesUseCase {
  final GalleryRepository repository;
  GetGalleryImagesUseCase({required this.repository});

  Future<List<GalleryImage>> execute({int perPage = 15, String status = 'pending'}) async {
    final response = await repository.getGalleryImages(perPage: perPage, status: status);
    if (response.isSuccess && response.body != null) {
      List<dynamic> dataList = [];
      if (response.body is List) {
        dataList = response.body;
      } else if (response.body is Map) {
        // Handle both paginated 'data' and direct 'gallery' keys
        dataList = response.body['data'] ?? response.body['gallery'] ?? [];
      }
      return dataList.map((json) => GalleryImage.fromJson(json)).toList();
    }
    return [];
  }
}

class UploadGalleryImagesUseCase {
  final GalleryRepository repository;
  UploadGalleryImagesUseCase({required this.repository});

  Future<ResponseModel> execute(List<File> images, String status) async {
    return await repository.uploadGalleryImages(images, status);
  }
}

class ToggleGalleryVisibilityUseCase {
  final GalleryRepository repository;
  ToggleGalleryVisibilityUseCase({required this.repository});

  Future<ResponseModel> execute(int id) async {
    return await repository.toggleVisibility(id);
  }
}

class DeleteGalleryImageUseCase {
  final GalleryRepository repository;
  DeleteGalleryImageUseCase({required this.repository});

  Future<ResponseModel> execute(int id) async {
    return await repository.deleteGalleryImage(id);
  }
}
