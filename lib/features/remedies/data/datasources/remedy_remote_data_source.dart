import '../../../../core/services/network/api_client.dart';
import '../../../../core/services/network/response_model.dart';

class RemedyRemoteDataSource {
  final ApiClient _apiClient;

  RemedyRemoteDataSource(this._apiClient);

  Future<ResponseModel> getRemedies() async {
    return await _apiClient.get('/user/remedies');
  }
}
