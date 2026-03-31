import '../../../../core/services/network/response_model.dart';
import '../repositories/notification_repository_interface.dart';

class GetNotificationsUseCase {
  final NotificationRepositoryInterface _repository;

  GetNotificationsUseCase(this._repository);

  Future<ResponseModel> execute(int userId) async {
    return await _repository.getNotifications(userId);
  }
}
