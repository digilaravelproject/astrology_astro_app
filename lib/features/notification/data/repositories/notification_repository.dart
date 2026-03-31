import '../../../../core/services/network/api_client.dart';
import '../../../../core/services/network/response_model.dart';
import '../../../../core/constants/app_urls.dart';
import '../../../../core/utils/logger.dart';
import '../../domain/repositories/notification_repository_interface.dart';

class NotificationRepository implements NotificationRepositoryInterface {
  final ApiClient _apiClient;

  NotificationRepository(this._apiClient);

  @override
  Future<ResponseModel> getNotificationCount(int userId) async {
    Logger.d('NotificationRepository: Calling API for userId: $userId');
    return await _apiClient.get(
      AppUrls.getNotificationCount,
      queryParameters: {'user_id': userId.toString()},
    );
  }

  @override
  Future<ResponseModel> getNotifications(int userId) async {
    Logger.d('NotificationRepository: Fetching notifications for userId: $userId');
    return await _apiClient.get(
      AppUrls.getNotifications,
      queryParameters: {'user_id': userId.toString()},
    );
  }

  @override
  Future<ResponseModel> getNotificationDetail(int id, int userId) async {
    Logger.d('NotificationRepository: Fetching detail for notificationId: $id, userId: $userId');
    return await _apiClient.get(
      AppUrls.getNotificationDetail(id),
      queryParameters: {'user_id': userId.toString()},
    );
  }
}
