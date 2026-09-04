import 'package:get/get.dart';
import '../../../../core/services/network/api_client.dart';
import 'package:astro_astrologer/features/notification/data/repositories/notification_repository.dart';
import 'package:astro_astrologer/features/notification/domain/usecases/get_notification_count_usecase.dart';
import 'package:astro_astrologer/features/notification/domain/usecases/get_notifications_usecase.dart';
import 'package:astro_astrologer/features/notification/domain/usecases/get_notification_detail_usecase.dart';
import 'package:astro_astrologer/features/notification/domain/usecases/mark_notification_read_usecase.dart';
import 'package:astro_astrologer/features/notification/domain/usecases/mark_all_notifications_read_usecase.dart';
import 'package:astro_astrologer/features/notification/domain/usecases/delete_notification_usecase.dart';
import 'package:astro_astrologer/features/notification/domain/usecases/delete_all_notifications_usecase.dart';
import 'package:astro_astrologer/features/notification/presentation/controllers/notification_controller.dart';

class NotificationBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => NotificationRepository(Get.find<ApiClient>()));
    Get.lazyPut(
      () => GetNotificationCountUseCase(Get.find<NotificationRepository>()),
    );
    Get.lazyPut(
      () => GetNotificationsUseCase(Get.find<NotificationRepository>()),
    );
    Get.lazyPut(
      () => GetNotificationDetailUseCase(Get.find<NotificationRepository>()),
    );
    Get.lazyPut(
      () => MarkNotificationReadUseCase(Get.find<NotificationRepository>()),
    );
    Get.lazyPut(
      () => MarkAllNotificationsReadUseCase(Get.find<NotificationRepository>()),
    );
    Get.lazyPut(
      () => DeleteNotificationUseCase(Get.find<NotificationRepository>()),
    );
    Get.lazyPut(
      () => DeleteAllNotificationsUseCase(Get.find<NotificationRepository>()),
    );
    Get.lazyPut(
      () => NotificationController(
        Get.find<GetNotificationCountUseCase>(),
        Get.find<GetNotificationsUseCase>(),
        Get.find<GetNotificationDetailUseCase>(),
        Get.find<MarkNotificationReadUseCase>(),
        Get.find<MarkAllNotificationsReadUseCase>(),
        Get.find<DeleteNotificationUseCase>(),
        Get.find<DeleteAllNotificationsUseCase>(),
      ),
    );
  }
}
