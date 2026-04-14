import '../../../../core/services/network/api_client.dart';
import '../../../../core/services/network/response_model.dart';
import '../../../../core/constants/app_urls.dart';
import '../../domain/models/follower_model.dart';

class FollowerRepository {
  final ApiClient apiClient;

  FollowerRepository(this.apiClient);

  Future<ResponseModel> getFollowers({String? query, int? page, int? perPage}) async {
    final queryParams = <String, dynamic>{};
    if (query != null && query.isNotEmpty) queryParams['query'] = query;
    if (page != null) queryParams['page'] = page;
    if (perPage != null) queryParams['per_page'] = perPage;

    return await apiClient.get(AppUrls.getFollowers, queryParameters: queryParams);
  }

  Future<ResponseModel> getFavorites({String? query, int? page, int? perPage}) async {
    final queryParams = <String, dynamic>{};
    if (query != null && query.isNotEmpty) queryParams['query'] = query;
    if (page != null) queryParams['page'] = page;
    if (perPage != null) queryParams['per_page'] = perPage;

    return await apiClient.get(AppUrls.getFavorites, queryParameters: queryParams);
  }

  Future<ResponseModel> toggleLike(int id) async {
    return await apiClient.post(AppUrls.toggleLike(id));
  }
}
