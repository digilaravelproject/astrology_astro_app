import 'package:get/get.dart';
import '../../../../core/services/network/api_client.dart';
import '../data/repositories/notification_repository.dart';
import '../domain/usecases/get_notification_count_usecase.dart';
import '../domain/usecases/get_notifications_usecase.dart';
import '../domain/usecases/get_notification_detail_usecase.dart';
import '../controllers/notification_controller.dart';

class NotificationBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => NotificationRepository(Get.find<ApiClient>()));
    Get.lazyPut(() => GetNotificationCountUseCase(Get.find<NotificationRepository>()));
    Get.lazyPut(() => GetNotificationsUseCase(Get.find<NotificationRepository>()));
    Get.lazyPut(() => GetNotificationDetailUseCase(Get.find<NotificationRepository>()));
    Get.lazyPut(() => NotificationController(
      Get.find<GetNotificationCountUseCase>(),
      Get.find<GetNotificationsUseCase>(),
      Get.find<GetNotificationDetailUseCase>(),
    ));
  }
}
