import '../../../core/services/network/api_client.dart';
import '../../../core/services/network/response_model.dart';

class TrainingVideoRemoteDataSource {
  final ApiClient _apiClient;

  TrainingVideoRemoteDataSource(this._apiClient);

  Future<ResponseModel> getTrainingVideos(String type) async {
    return await _apiClient.get(
      '/api/v1/astrologer/training-videos',
    );
  }

  Future<ResponseModel> getTrainingVideoDetail(int id) async {
    return await _apiClient.get('/api/v1/astrologer/training-videos/$id');
  }
}