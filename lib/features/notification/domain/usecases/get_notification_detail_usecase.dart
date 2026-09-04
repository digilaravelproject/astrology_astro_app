import 'package:astro_astrologer/core/services/network/response_model.dart';
import 'package:astro_astrologer/features/notification/domain/repositories/notification_repository_interface.dart';

class GetNotificationDetailUseCase {
  final NotificationRepositoryInterface _repository;

  GetNotificationDetailUseCase(this._repository);

  Future<ResponseModel> execute(int id, int userId) async {
    return await _repository.getNotificationDetail(id, userId);
  }
}
