import '../../../../core/services/network/response_model.dart';
import '../repositories/notification_repository_interface.dart';

class DeleteAllNotificationsUseCase {
  final NotificationRepositoryInterface _repository;

  DeleteAllNotificationsUseCase(this._repository);

  Future<ResponseModel> execute(int userId) async {
    return await _repository.deleteAllNotifications(userId);
  }
}
