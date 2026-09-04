import 'package:astro_astrologer/core/services/network/api_client.dart';
import 'package:astro_astrologer/core/services/network/response_model.dart';
import 'package:astro_astrologer/core/constants/app_urls.dart';
import 'package:get/get.dart';

class TrainingVideoRemoteDataSource {
  final ApiClient _apiClient;

  TrainingVideoRemoteDataSource(this._apiClient);

  Future<ResponseModel> getTrainingVideos(String type) async {
    return await _apiClient.get(AppUrls.trainingVideos);
  }

  Future<ResponseModel> getTrainingVideoDetail(int id) async {
    return await _apiClient.get(AppUrls.trainingVideoDetail(id));
  }
}
