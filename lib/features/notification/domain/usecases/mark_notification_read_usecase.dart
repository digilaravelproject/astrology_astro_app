import '../../../../core/services/network/response_model.dart';
import '../repositories/notification_repository_interface.dart';

class MarkNotificationReadUseCase {
  final NotificationRepositoryInterface _repository;

  MarkNotificationReadUseCase(this._repository);

  Future<ResponseModel> execute(int id, int userId) async {
    return await _repository.markNotificationRead(id, userId);
  }
}
