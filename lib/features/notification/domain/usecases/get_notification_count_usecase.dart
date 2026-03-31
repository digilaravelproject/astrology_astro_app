import '../../../../core/services/network/response_model.dart';
import '../repositories/notification_repository_interface.dart';

class GetNotificationCountUseCase {
  final NotificationRepositoryInterface _repository;

  GetNotificationCountUseCase(this._repository);

  Future<ResponseModel> execute(int userId) async {
    return await _repository.getNotificationCount(userId);
  }
}
