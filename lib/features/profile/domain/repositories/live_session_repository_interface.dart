import '../../../../core/services/network/response_model.dart';

abstract class LiveSessionRepositoryInterface {
  Future<ResponseModel> getLiveSessions({String filter = 'all', int perPage = 15});
  Future<ResponseModel> createLiveSession(Map<String, dynamic> data);
  Future<ResponseModel> deleteLiveSession(int id);
  Future<ResponseModel> startLiveSession(int id);
  Future<ResponseModel> stopLiveSession(int id);
}
