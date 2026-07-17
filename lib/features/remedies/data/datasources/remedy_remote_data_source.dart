import '../../../../core/services/network/api_client.dart';
import '../../../../core/services/network/response_model.dart';
import '../../../../core/constants/app_urls.dart';

class RemedyRemoteDataSource {
  final ApiClient _apiClient;

  RemedyRemoteDataSource(this._apiClient);

  Future<ResponseModel> getRemedies() async {
    return await _apiClient.get(AppUrls.remedies);
  }

  Future<ResponseModel> getRemedyDetails(int id) async {
    return await _apiClient.get(AppUrls.remedyDetails(id));
  }
}
