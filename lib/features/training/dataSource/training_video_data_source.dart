import '../../../core/services/network/api_client.dart';
import '../../../core/services/network/response_model.dart';
import '../../../core/constants/app_urls.dart';

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