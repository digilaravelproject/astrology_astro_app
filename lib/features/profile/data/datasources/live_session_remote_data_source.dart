import '../../../../core/constants/app_urls.dart';
import '../../../../core/services/network/api_client.dart';
import '../../../../core/services/network/response_model.dart';

class LiveSessionRemoteDataSource {
  final ApiClient _apiClient;

  LiveSessionRemoteDataSource(this._apiClient);

  Future<ResponseModel> getLiveSessions({String filter = 'all', int perPage = 15}) async {
    print('[LIVE_DS] Getting live sessions: filter=$filter, perPage=$perPage');
    final result = await _apiClient.get('${AppUrls.liveSessions}?filter=$filter&per_page=$perPage');
    print('[LIVE_DS] Get live sessions response: ${result.toString()}');
    return result;
  }

  Future<ResponseModel> createLiveSession(Map<String, dynamic> data) async {
    print('[LIVE_DS] Creating live session: $data');
    final result = await _apiClient.post(AppUrls.liveSessions, data: data);
    print('[LIVE_DS] Create response: ${result.toString()}');
    return result;
  }

  Future<ResponseModel> deleteLiveSession(int id) async {
    print('[LIVE_DS] Deleting live session: $id');
    final result = await _apiClient.delete(AppUrls.deleteLiveSession(id));
    print('[LIVE_DS] Delete response: ${result.toString()}');
    return result;
  }
}
