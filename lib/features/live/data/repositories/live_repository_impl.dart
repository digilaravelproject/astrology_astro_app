import '../../../../core/services/network/response_model.dart';
import '../../domain/repositories/live_repository.dart';
import '../datasources/live_remote_data_source.dart';

class LiveRepositoryImpl implements LiveRepository {
  final LiveRemoteDataSource dataSource;

  LiveRepositoryImpl(this.dataSource);

  @override
  Future<ResponseModel> getLiveSessions({String filter = 'all', int perPage = 15}) async {
    return await dataSource.getLiveSessions(filter: filter, perPage: perPage);
  }

  @override
  Future<ResponseModel> getCurrentLiveSession() async {
    return await dataSource.getCurrentLiveSession();
  }

  @override
  Future<ResponseModel> createLiveSession(Map<String, dynamic> data) async {
    return await dataSource.createLiveSession(data);
  }

  @override
  Future<ResponseModel> deleteLiveSession(int id) async {
    return await dataSource.deleteLiveSession(id);
  }

  @override
  Future<ResponseModel> startLiveSession(int id) async {
    return await dataSource.startLiveSession(id);
  }

  @override
  Future<ResponseModel> stopLiveSession(int id) async {
    return await dataSource.stopLiveSession(id);
  }

  @override
  Future<ResponseModel> updateLiveSession(int id, Map<String, dynamic> data) async {
    return await dataSource.updateLiveSession(id, data);
  }

  @override
  Future<ResponseModel> startBroadcast(int id) async {
    return await dataSource.startBroadcast(id);
  }

  @override
  Future<ResponseModel> stopBroadcast(int id) async {
    return await dataSource.stopBroadcast(id);
  }

  @override
  Future<ResponseModel> getLiveComments(int id) async {
    return await dataSource.getLiveComments(id);
  }
}

