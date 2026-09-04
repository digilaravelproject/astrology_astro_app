import 'package:astro_astrologer/core/services/network/api_client.dart';
import 'package:astro_astrologer/core/services/network/response_model.dart';
import 'package:astro_astrologer/core/constants/app_urls.dart';
import 'package:astro_astrologer/core/utils/logger.dart';
import 'package:astro_astrologer/features/notification/domain/repositories/notification_repository_interface.dart';

class NotificationRepository implements NotificationRepositoryInterface {
  final ApiClient _apiClient;

  NotificationRepository(this._apiClient);

  @override
  Future<ResponseModel> getNotificationCount(int userId) async {
    Logger.d('NotificationRepository: Calling API for userId: $userId');
    return await _apiClient.get(AppUrls.getNotificationCount(userId));
  }

  @override
  Future<ResponseModel> getNotifications(int userId, {int page = 1}) async {
    Logger.d(
      'NotificationRepository: Fetching notifications for userId: $userId, page: $page',
    );
    return await _apiClient.get(AppUrls.getNotifications(userId, page: page));
  }

  @override
  Future<ResponseModel> getNotificationDetail(int id, int userId) async {
    Logger.d(
      'NotificationRepository: Fetching detail for notificationId: $id, userId: $userId',
    );
    return await _apiClient.get(AppUrls.getNotificationDetail(id, userId));
  }

  @override
  Future<ResponseModel> markNotificationRead(int id, int userId) async {
    Logger.d(
      'NotificationRepository: Marking as read notificationId: $id, userId: $userId',
    );
    return await _apiClient.put(AppUrls.markNotificationRead(id, userId));
  }

  @override
  Future<ResponseModel> markAllNotificationsRead(int userId) async {
    Logger.d('NotificationRepository: Marking all as read for userId: $userId');
    return await _apiClient.post(AppUrls.markAllNotificationsRead(userId));
  }

  @override
  Future<ResponseModel> deleteNotification(int id, int userId) async {
    Logger.d(
      'NotificationRepository: Deleting notificationId: $id, userId: $userId',
    );
    return await _apiClient.delete(AppUrls.deleteNotification(id, userId));
  }

  @override
  Future<ResponseModel> deleteAllNotifications(int userId) async {
    Logger.d('NotificationRepository: Deleting all notifications for userId: $userId');
    return await _apiClient.post(AppUrls.deleteAllNotifications(userId));
  }
}
