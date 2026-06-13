import '../../../../core/services/network/response_model.dart';
import '../../domain/repositories/live_session_repository_interface.dart';
import '../datasources/live_session_remote_data_source.dart';

class LiveSessionRepository implements LiveSessionRepositoryInterface {
  final LiveSessionRemoteDataSource dataSource;

  LiveSessionRepository(this.dataSource);

  @override
  Future<ResponseModel> getLiveSessions({String filter = 'all', int perPage = 15}) async {
    return await dataSource.getLiveSessions(filter: filter, perPage: perPage);
  }

  @override
  Future<ResponseModel> createLiveSession(Map<String, dynamic> data) async {
    return await dataSource.createLiveSession(data);
  }

  @override
  Future<ResponseModel> deleteLiveSession(int id) async {
    return await dataSource.deleteLiveSession(id);
  }
}
