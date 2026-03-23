import '../../../../core/services/network/api_client.dart';
import '../../../../core/services/network/response_model.dart';
import '../../../../core/constants/app_urls.dart';
import '../../domain/models/follower_model.dart';

class FollowerRepository {
  final ApiClient apiClient;

  FollowerRepository(this.apiClient);

  Future<ResponseModel> getFollowers() async {
    return await apiClient.get(AppUrls.getFollowers);
  }

  Future<ResponseModel> getFavorites() async {
    return await apiClient.get(AppUrls.getFavorites);
  }

  Future<ResponseModel> toggleLike(int id) async {
    return await apiClient.post(AppUrls.toggleLike(id));
  }
}
