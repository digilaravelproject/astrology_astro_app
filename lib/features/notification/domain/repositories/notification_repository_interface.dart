import '../../../../core/services/network/response_model.dart';

abstract class NotificationRepositoryInterface {
  Future<ResponseModel> getNotificationCount(int userId);
  Future<ResponseModel> getNotifications(int userId, {int page = 1});
  Future<ResponseModel> getNotificationDetail(int id, int userId);
  Future<ResponseModel> markNotificationRead(int id, int userId);
  Future<ResponseModel> markAllNotificationsRead(int userId);
  Future<ResponseModel> deleteNotification(int id, int userId);
  Future<ResponseModel> deleteAllNotifications(int userId);
}
