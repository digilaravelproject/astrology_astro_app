import '../../../../core/services/network/response_model.dart';
import '../repositories/notification_repository_interface.dart';

class DeleteNotificationUseCase {
  final NotificationRepositoryInterface _repository;

  DeleteNotificationUseCase(this._repository);

  Future<ResponseModel> execute(int id, int userId) async {
    return await _repository.deleteNotification(id, userId);
  }
}
