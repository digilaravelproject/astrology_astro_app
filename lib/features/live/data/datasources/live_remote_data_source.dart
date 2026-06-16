import '../../../../core/constants/app_urls.dart';
import '../../../../core/services/network/api_client.dart';
import '../../../../core/services/network/response_model.dart';

class LiveRemoteDataSource {
  final ApiClient _apiClient;

  LiveRemoteDataSource(this._apiClient);

  Future<ResponseModel> getLiveSessions({String filter = 'all', int perPage = 15}) async {
    print('[LIVE_DS] Getting live sessions: filter=$filter, perPage=$perPage');
    final result = await _apiClient.get('${AppUrls.liveSessions}?filter=$filter&per_page=$perPage');
    print('[LIVE_DS] Get live sessions response: ${result.toString()}');
    return result;
  }

  Future<ResponseModel> getCurrentLiveSession() async {
    print('[LIVE_DS] Getting current active live session');
    final result = await _apiClient.get(AppUrls.currentLiveSession);
    print('[LIVE_DS] Get current live session response: ${result.toString()}');
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

  Future<ResponseModel> startLiveSession(int id) async {
    print('[LIVE_DS] Starting live session: $id');
    final result = await _apiClient.post(AppUrls.startLiveSession(id), data: {});
    print('[LIVE_DS] Start response: ${result.toString()}');
    return result;
  }

  Future<ResponseModel> stopLiveSession(int id) async {
    print('[LIVE_DS] Stopping live session: $id');
    final result = await _apiClient.post(AppUrls.stopLiveSession(id), data: {});
    print('[LIVE_DS] Stop response: ${result.toString()}');
    return result;
  }

  Future<ResponseModel> updateLiveSession(int id, Map<String, dynamic> data) async {
    print('[LIVE_DS] Updating live session: $id, $data');
    final result = await _apiClient.put(AppUrls.updateLiveSession(id), data: data);
    print('[LIVE_DS] Update response: ${result.toString()}');
    return result;
  }

  Future<ResponseModel> startBroadcast(int id) async {
    print('[LIVE_DS] Starting LiveKit broadcast: $id');
    final result = await _apiClient.post(AppUrls.startBroadcast(id), data: {});
    print('[LIVE_DS] Start broadcast response: ${result.toString()}');
    return result;
  }

  Future<ResponseModel> stopBroadcast(int id) async {
    print('[LIVE_DS] Stopping LiveKit broadcast: $id');
    final result = await _apiClient.post(AppUrls.stopBroadcast(id), data: {});
    print('[LIVE_DS] Stop broadcast response: ${result.toString()}');
    return result;
  }
}

