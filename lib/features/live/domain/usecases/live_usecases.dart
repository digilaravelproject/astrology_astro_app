import '../../../../core/services/network/response_model.dart';
import '../repositories/live_repository.dart';

class GetLiveSessionsUseCase {
  final LiveRepository repository;
  GetLiveSessionsUseCase(this.repository);

  Future<ResponseModel> call({String filter = 'all', int perPage = 15}) async {
    return await repository.getLiveSessions(filter: filter, perPage: perPage);
  }
}

class GetCurrentLiveSessionUseCase {
  final LiveRepository repository;
  GetCurrentLiveSessionUseCase(this.repository);

  Future<ResponseModel> call() async {
    return await repository.getCurrentLiveSession();
  }
}

class CreateLiveSessionUseCase {
  final LiveRepository repository;
  CreateLiveSessionUseCase(this.repository);

  Future<ResponseModel> call(Map<String, dynamic> data) async {
    return await repository.createLiveSession(data);
  }
}

class DeleteLiveSessionUseCase {
  final LiveRepository repository;
  DeleteLiveSessionUseCase(this.repository);

  Future<ResponseModel> call(int id) async {
    return await repository.deleteLiveSession(id);
  }
}

class StartLiveSessionUseCase {
  final LiveRepository repository;
  StartLiveSessionUseCase(this.repository);

  Future<ResponseModel> call(int id) async {
    return await repository.startLiveSession(id);
  }
}

class StopLiveSessionUseCase {
  final LiveRepository repository;
  StopLiveSessionUseCase(this.repository);

  Future<ResponseModel> call(int id) async {
    return await repository.stopLiveSession(id);
  }
}

class UpdateLiveSessionUseCase {
  final LiveRepository repository;
  UpdateLiveSessionUseCase(this.repository);

  Future<ResponseModel> call(int id, Map<String, dynamic> data) async {
    return await repository.updateLiveSession(id, data);
  }
}

class StartBroadcastUseCase {
  final LiveRepository repository;
  StartBroadcastUseCase(this.repository);

  Future<ResponseModel> call(int id) async {
    return await repository.startBroadcast(id);
  }
}

class StopBroadcastUseCase {
  final LiveRepository repository;
  StopBroadcastUseCase(this.repository);

  Future<ResponseModel> call(int id) async {
    return await repository.stopBroadcast(id);
  }
}

class GetLiveCommentsUseCase {
  final LiveRepository repository;
  GetLiveCommentsUseCase(this.repository);

  Future<ResponseModel> call(int id) async {
    return await repository.getLiveComments(id);
  }
}

