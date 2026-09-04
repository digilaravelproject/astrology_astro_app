import 'package:astro_astrologer/core/services/network/response_model.dart';
import 'package:astro_astrologer/features/notification/domain/repositories/notification_repository_interface.dart';

class GetNotificationsUseCase {
  final NotificationRepositoryInterface _repository;

  GetNotificationsUseCase(this._repository);

  Future<ResponseModel> execute(int userId, {int page = 1}) async {
    return await _repository.getNotifications(userId, page: page);
  }
}
