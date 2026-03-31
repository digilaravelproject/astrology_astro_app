import 'package:get/get.dart';
import '../domain/usecases/get_notification_count_usecase.dart';
import '../domain/usecases/get_notifications_usecase.dart';
import '../domain/usecases/get_notification_detail_usecase.dart';
import '../domain/models/notification_count_model.dart';
import '../domain/models/notification_item_model.dart';
import '../../auth/controllers/auth_controller.dart';
import '../../../../core/utils/logger.dart';

class NotificationController extends GetxController {
  final GetNotificationCountUseCase _getNotificationCountUseCase;
  final GetNotificationsUseCase _getNotificationsUseCase;
  final GetNotificationDetailUseCase _getNotificationDetailUseCase;

  NotificationController(
    this._getNotificationCountUseCase,
    this._getNotificationsUseCase,
    this._getNotificationDetailUseCase,
  );

  final unreadCount = 0.obs;
  final isLoading = false.obs;
  final isNotificationsLoading = false.obs;
  final notifications = <NotificationItemModel>[].obs;
  final selectedNotification = Rx<NotificationItemModel?>(null);
  final isDetailLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    Logger.d('NotificationController: onInit started');

    // Listen for user changes to refetch count
    final authController = Get.find<AuthController>();
    ever(authController.currentUser, (user) {
      Logger.d('NotificationController: ever listener triggered, user id: ${user?.id}');
      if (user != null) {
        getNotificationCount();
      }
    });
  }

  @override
  void onReady() {
    super.onReady();
    Logger.d('NotificationController: onReady called');
    // Initial fetch when controller is ready
    getNotificationCount();
  }

  Future<void> getNotificationCount() async {
    try {
      if (!Get.isRegistered<AuthController>()) {
        Logger.e('NotificationController: AuthController not registered');
        return;
      }

      final authController = Get.find<AuthController>();
      final userId = authController.currentUser.value?.id;

      Logger.d('NotificationController: Fetching count for userId: $userId');

      if (userId == null) {
        Logger.e('NotificationController: userId is null, skipping fetch');
        return;
      }

      isLoading.value = true;
      final response = await _getNotificationCountUseCase.execute(userId);

      Logger.d('NotificationController: API Response success: ${response.isSuccess}');

      if (response.isSuccess && response.body != null) {
        Logger.d('NotificationController: API Body: ${response.body}');
        final countModel = NotificationCountModel.fromJson(response.body);
        unreadCount.value = countModel.unread;
        Logger.d('NotificationController: New unreadCount: ${unreadCount.value}');
      } else {
        Logger.e('NotificationController: API Fetch failed: ${response.message}');
      }
    } catch (e) {
      Logger.e('NotificationController: getNotificationCount error: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> getNotifications() async {
    try {
      if (!Get.isRegistered<AuthController>()) return;

      final authController = Get.find<AuthController>();
      final userId = authController.currentUser.value?.id;

      if (userId == null) {
        Logger.e('NotificationController: userId is null, cannot fetch notifications');
        return;
      }

      isNotificationsLoading.value = true;
      final response = await _getNotificationsUseCase.execute(userId);

      Logger.d('NotificationController: getNotifications response: ${response.isSuccess}');

      if (response.isSuccess && response.body != null) {
        final rawList = response.body['notifications'] as List?;
        if (rawList != null) {
          notifications.assignAll(
            rawList.map((item) => NotificationItemModel.fromJson(item)).toList(),
          );
          Logger.d('NotificationController: Loaded ${notifications.length} notifications');
        }
      } else {
        Logger.e('NotificationController: fetch notifications failed: ${response.message}');
      }
    } catch (e) {
      Logger.e('NotificationController: getNotifications error: $e');
    } finally {
      isNotificationsLoading.value = false;
    }
  }

  void resetUnreadCount() {
    unreadCount.value = 0;
  }

  Future<void> getNotificationDetail(int id) async {
    try {
      if (!Get.isRegistered<AuthController>()) return;
      final authController = Get.find<AuthController>();
      final userId = authController.currentUser.value?.id;
      if (userId == null) return;

      isDetailLoading.value = true;
      selectedNotification.value = null;
      final response = await _getNotificationDetailUseCase.execute(id, userId);

      Logger.d('NotificationController: getNotificationDetail response: ${response.isSuccess}');

      if (response.isSuccess && response.body != null) {
        final raw = response.body['notification'] as Map<String, dynamic>?;
        if (raw != null) {
          selectedNotification.value = NotificationItemModel.fromJson(raw);
        }
      } else {
        Logger.e('NotificationController: detail fetch failed: ${response.message}');
      }
    } catch (e) {
      Logger.e('NotificationController: getNotificationDetail error: $e');
    } finally {
      isDetailLoading.value = false;
    }
  }
}
