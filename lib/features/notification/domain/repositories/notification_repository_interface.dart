import '../../../../core/services/network/response_model.dart';

abstract class NotificationRepositoryInterface {
  Future<ResponseModel> getNotificationCount(int userId);
  Future<ResponseModel> getNotifications(int userId);
  Future<ResponseModel> getNotificationDetail(int id, int userId);
  Future<ResponseModel> markNotificationRead(int id, int userId);
}
