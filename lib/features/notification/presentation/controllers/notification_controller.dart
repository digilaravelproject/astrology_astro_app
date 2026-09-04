import 'package:get/get.dart';
import 'package:astro_astrologer/features/notification/domain/usecases/get_notification_count_usecase.dart';
import 'package:astro_astrologer/features/notification/domain/usecases/get_notifications_usecase.dart';
import 'package:astro_astrologer/features/notification/domain/usecases/get_notification_detail_usecase.dart';
import 'package:astro_astrologer/features/notification/domain/usecases/mark_notification_read_usecase.dart';
import 'package:astro_astrologer/features/notification/domain/usecases/mark_all_notifications_read_usecase.dart';
import 'package:astro_astrologer/features/notification/domain/usecases/delete_notification_usecase.dart';
import 'package:astro_astrologer/features/notification/domain/usecases/delete_all_notifications_usecase.dart';
import 'package:astro_astrologer/features/notification/data/models/notification_count_model.dart';
import 'package:astro_astrologer/features/notification/data/models/notification_item_model.dart';
import 'package:astro_astrologer/features/auth/presentation/controllers/auth_controller.dart';
import '../../../../core/utils/logger.dart';

class NotificationController extends GetxController {
  final GetNotificationCountUseCase _getNotificationCountUseCase;
  final GetNotificationsUseCase _getNotificationsUseCase;
  final GetNotificationDetailUseCase _getNotificationDetailUseCase;
  final MarkNotificationReadUseCase _markNotificationReadUseCase;
  final MarkAllNotificationsReadUseCase _markAllNotificationsReadUseCase;
  final DeleteNotificationUseCase _deleteNotificationUseCase;
  final DeleteAllNotificationsUseCase _deleteAllNotificationsUseCase;

  NotificationController(
    this._getNotificationCountUseCase,
    this._getNotificationsUseCase,
    this._getNotificationDetailUseCase,
    this._markNotificationReadUseCase,
    this._markAllNotificationsReadUseCase,
    this._deleteNotificationUseCase,
    this._deleteAllNotificationsUseCase,
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
      Logger.d(
        'NotificationController: ever listener triggered, user id: ${user?.id}',
      );
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

      Logger.d(
        'NotificationController: API Response success: ${response.isSuccess}',
      );

      if (response.isSuccess && response.body != null) {
        Logger.d('NotificationController: API Body: ${response.body}');
        final countModel = NotificationCountModel.fromJson(response.body);
        unreadCount.value = countModel.unread;
        Logger.d(
          'NotificationController: New unreadCount: ${unreadCount.value}',
        );
      } else {
        Logger.e(
          'NotificationController: API Fetch failed: ${response.message}',
        );
      }
    } catch (e) {
      Logger.e('NotificationController: getNotificationCount error: $e');
    } finally {
      isLoading.value = false;
    }
  }

  // Pagination state
  int _currentPage = 1;
  bool _hasMore = true;
  final isFetchingMore = false.obs;

  Future<void> getNotifications({bool refresh = false}) async {
    try {
      if (!Get.isRegistered<AuthController>()) return;

      final authController = Get.find<AuthController>();
      final userId = authController.currentUser.value?.id;

      if (userId == null) {
        Logger.e(
          'NotificationController: userId is null, cannot fetch notifications',
        );
        return;
      }

      if (refresh) {
        _currentPage = 1;
        _hasMore = true;
        isNotificationsLoading.value = true;
      } else {
        if (!_hasMore || isFetchingMore.value) return;
        isFetchingMore.value = true;
      }

      final response = await _getNotificationsUseCase.execute(
        userId,
        page: _currentPage,
      );

      Logger.d(
        'NotificationController: getNotifications response: ${response.isSuccess}',
      );

      if (response.isSuccess && response.body != null) {
        final rawList = response.body['notifications'] as List?;
        if (rawList != null) {
          final newItems =
              rawList
                  .map((item) => NotificationItemModel.fromJson(item))
                  .toList();
          if (refresh) {
            notifications.assignAll(newItems);
          } else {
            notifications.addAll(newItems);
          }
          Logger.d(
            'NotificationController: Loaded ${notifications.length} notifications',
          );
        }

        final pagination = response.body['pagination'];
        if (pagination != null) {
          _hasMore = pagination['has_more'] ?? false;
          if (_hasMore) {
            _currentPage++;
          }
        } else {
          _hasMore = false;
        }
      } else {
        Logger.e(
          'NotificationController: fetch notifications failed: ${response.message}',
        );
      }
    } catch (e) {
      Logger.e('NotificationController: getNotifications error: $e');
    } finally {
      isNotificationsLoading.value = false;
      isFetchingMore.value = false;
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

      Logger.d(
        'NotificationController: getNotificationDetail response: ${response.isSuccess}',
      );

      if (response.isSuccess && response.body != null) {
        final raw = response.body['notification'] as Map<String, dynamic>?;
        if (raw != null) {
          final item = NotificationItemModel.fromJson(raw);
          selectedNotification.value = item;

          // Mark as read if it's currently unread
          if (!item.isRead) {
            markAsRead(id);
          }
        }
      } else {
        Logger.e(
          'NotificationController: detail fetch failed: ${response.message}',
        );
      }
    } catch (e) {
      Logger.e('NotificationController: getNotificationDetail error: $e');
    } finally {
      isDetailLoading.value = false;
    }
  }

  Future<void> markAsRead(int id) async {
    try {
      if (!Get.isRegistered<AuthController>()) return;
      final authController = Get.find<AuthController>();
      final userId = authController.currentUser.value?.id;
      if (userId == null) return;

      final response = await _markNotificationReadUseCase.execute(id, userId);

      if (response.isSuccess) {
        Logger.d('NotificationController: Notification $id marked as read');

        // Update local list state
        final index = notifications.indexWhere((n) => n.id == id);
        if (index != -1) {
          final n = notifications[index];
          if (!n.isRead) {
            notifications[index] = n.copyWith(isRead: true);
            // Decrease unread count locally
            if (unreadCount.value > 0) {
              unreadCount.value--;
            }
          }
        }

        // Also update selected notification if it's the one
        if (selectedNotification.value?.id == id) {
          selectedNotification.value = selectedNotification.value?.copyWith(
            isRead: true,
          );
        }
      }
    } catch (e) {
      Logger.e('NotificationController: markAsRead error: $e');
    }
  }

  Future<void> markAllAsRead() async {
    try {
      if (!Get.isRegistered<AuthController>()) return;
      final authController = Get.find<AuthController>();
      final userId = authController.currentUser.value?.id;
      if (userId == null) return;

      final response = await _markAllNotificationsReadUseCase.execute(userId);

      if (response.isSuccess) {
        Logger.d('NotificationController: All notifications marked as read');
        // Update local list
        for (var i = 0; i < notifications.length; i++) {
          if (!notifications[i].isRead) {
            notifications[i] = notifications[i].copyWith(isRead: true);
          }
        }
        unreadCount.value = 0;
      }
    } catch (e) {
      Logger.e('NotificationController: markAllAsRead error: $e');
    }
  }

  Future<void> deleteNotification(int id) async {
    try {
      if (!Get.isRegistered<AuthController>()) return;
      final authController = Get.find<AuthController>();
      final userId = authController.currentUser.value?.id;
      if (userId == null) return;

      final response = await _deleteNotificationUseCase.execute(id, userId);

      if (response.isSuccess) {
        Logger.d('NotificationController: Notification $id deleted');

        // Remove locally
        final index = notifications.indexWhere((n) => n.id == id);
        if (index != -1) {
          final n = notifications[index];
          notifications.removeAt(index);
          if (!n.isRead && unreadCount.value > 0) {
            unreadCount.value--;
          }
        }
      }
    } catch (e) {
      Logger.e('NotificationController: deleteNotification error: $e');
    }
  }

  Future<void> deleteAllNotifications() async {
    try {
      if (!Get.isRegistered<AuthController>()) return;
      final authController = Get.find<AuthController>();
      final userId = authController.currentUser.value?.id;
      if (userId == null) return;

      final response = await _deleteAllNotificationsUseCase.execute(userId);

      if (response.isSuccess) {
        Logger.d('NotificationController: All notifications deleted');
        notifications.clear();
        unreadCount.value = 0;
      }
    } catch (e) {
      Logger.e('NotificationController: deleteAllNotifications error: $e');
    }
  }
}
