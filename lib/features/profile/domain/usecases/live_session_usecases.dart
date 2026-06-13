import '../../../../core/services/network/response_model.dart';
import '../repositories/live_session_repository_interface.dart';

class GetLiveSessionsUseCase {
  final LiveSessionRepositoryInterface repository;
  GetLiveSessionsUseCase(this.repository);

  Future<ResponseModel> call({String filter = 'all', int perPage = 15}) async {
    return await repository.getLiveSessions(filter: filter, perPage: perPage);
  }
}

class CreateLiveSessionUseCase {
  final LiveSessionRepositoryInterface repository;
  CreateLiveSessionUseCase(this.repository);

  Future<ResponseModel> call(Map<String, dynamic> data) async {
    return await repository.createLiveSession(data);
  }
}

class DeleteLiveSessionUseCase {
  final LiveSessionRepositoryInterface repository;
  DeleteLiveSessionUseCase(this.repository);

  Future<ResponseModel> call(int id) async {
    return await repository.deleteLiveSession(id);
  }
}
