import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:astro_astrologer/core/services/network/api_client.dart';
import 'package:astro_astrologer/core/services/network/multipart.dart';
import 'package:astro_astrologer/core/services/network/response_model.dart';
import 'package:astro_astrologer/core/constants/app_urls.dart';

class GalleryRepository {
  final ApiClient apiClient;

  GalleryRepository({required this.apiClient});

  Future<ResponseModel> getGalleryImages({int perPage = 15, String status = 'pending'}) async {
    String url = '${AppUrls.galleryList}?per_page=$perPage';
    if (status != 'all') {
      url += '&status=$status';
    }
    return await apiClient.get(url);
  }

  Future<ResponseModel> uploadGalleryImages(List<File> images, String status) async {
    final List<MultipartBody> multipartBody = images.map((image) => MultipartBody('images[]', XFile(image.path))).toList();
    
    return await apiClient.postMultipartData(
      AppUrls.uploadGallery,
      {'status': status},
      multipartBody,
      [],
    );
  }

  Future<ResponseModel> toggleVisibility(int id) async {
    return await apiClient.put(AppUrls.toggleGalleryVisibility(id), data: {});
  }

  Future<ResponseModel> deleteGalleryImage(int id) async {
    return await apiClient.delete(AppUrls.deleteGalleryImage(id));
  }
}
