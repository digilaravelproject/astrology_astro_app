import '../../../../core/services/network/response_model.dart';

abstract class LiveRepository {
  Future<ResponseModel> getLiveSessions({
    String filter = 'all',
    int perPage = 15,
  });
  Future<ResponseModel> getCurrentLiveSession();
  Future<ResponseModel> createLiveSession(Map<String, dynamic> data);
  Future<ResponseModel> deleteLiveSession(int id);
  Future<ResponseModel> startLiveSession(int id);
  Future<ResponseModel> stopLiveSession(int id);
  Future<ResponseModel> updateLiveSession(int id, Map<String, dynamic> data);
  Future<ResponseModel> startBroadcast(int id);
  Future<ResponseModel> stopBroadcast(int id);
  Future<ResponseModel> getLiveComments(int id);
}
