import 'package:astro_astrologer/core/services/network/response_model.dart';
import 'package:astro_astrologer/features/notification/domain/repositories/notification_repository_interface.dart';

class MarkAllNotificationsReadUseCase {
  final NotificationRepositoryInterface _repository;

  MarkAllNotificationsReadUseCase(this._repository);

  Future<ResponseModel> execute(int userId) async {
    return await _repository.markAllNotificationsRead(userId);
  }
}
