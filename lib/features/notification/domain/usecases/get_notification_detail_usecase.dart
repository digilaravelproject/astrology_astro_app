import '../../../../core/services/network/response_model.dart';
import '../repositories/notification_repository_interface.dart';

class GetNotificationDetailUseCase {
  final NotificationRepositoryInterface _repository;

  GetNotificationDetailUseCase(this._repository);

  Future<ResponseModel> execute(int id, int userId) async {
    return await _repository.getNotificationDetail(id, userId);
  }
}
