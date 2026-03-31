import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import 'controllers/notification_controller.dart';
import '../../core/theme/app_colors.dart';
import '../../core/widgets/app_text.dart';
import '../../core/widgets/custom_app_bar.dart';

class NotificationDetailScreen extends StatefulWidget {
  final int notificationId;

  const NotificationDetailScreen({super.key, required this.notificationId});

  @override
  State<NotificationDetailScreen> createState() => _NotificationDetailScreenState();
}

class _NotificationDetailScreenState extends State<NotificationDetailScreen> {
  late final NotificationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = Get.find<NotificationController>();
    _controller.getNotificationDetail(widget.notificationId);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: const CustomAppBar(title: 'Notification Details'),
      body: Obx(() {
        if (_controller.isDetailLoading.value) {
          return const Center(
            child: CircularProgressIndicator(color: AppColors.primaryColor),
          );
        }

        final notification = _controller.selectedNotification.value;

        if (notification == null) {
          return const Center(
            child: AppText(
              'Notification not found.',
              fontSize: 16,
              color: Colors.black54,
            ),
          );
        }

        final String type = _getTypeFromTitle(notification.title);

        return SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Icon and Time Row
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.lightPink.withOpacity(0.3),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      _getIconForType(type),
                      size: 24,
                      color: AppColors.deepPink,
                    ),
                  ),
                  const SizedBox(width: 12),
                  AppText(
                    notification.timeAgo,
                    fontSize: 14,
                    color: Colors.black54,
                    fontWeight: FontWeight.w500,
                  ),
                  const Spacer(),
                  // Read status badge
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: notification.isRead
                          ? Colors.grey.shade100
                          : AppColors.lightPink.withOpacity(0.4),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: AppText(
                      notification.isRead ? 'Read' : 'Unread',
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: notification.isRead ? Colors.grey : AppColors.deepPink,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 20),

              // Title
              AppText(
                notification.title,
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: Colors.black87,
                height: 1.3,
              ),

              const SizedBox(height: 16),
              const Divider(color: Color(0xFFEEEEEE)),
              const SizedBox(height: 16),

              // Body
              AppText(
                notification.body,
                fontSize: 16,
                color: Colors.black87,
                height: 1.6,
              ),
            ],
          ),
        );
      }),
    );
  }

  String _getTypeFromTitle(String title) {
    final lower = title.toLowerCase();
    if (lower.contains('follow')) return 'follower';
    if (lower.contains('wallet') || lower.contains('earning') || lower.contains('credit')) return 'wallet';
    if (lower.contains('review') || lower.contains('rating') || lower.contains('star')) return 'review';
    if (lower.contains('like') || lower.contains('liked')) return 'like';
    if (lower.contains('block')) return 'block';
    if (lower.contains('report')) return 'report';
    if (lower.contains('photo') || lower.contains('profile')) return 'profile';
    if (lower.contains('otp') || lower.contains('login') || lower.contains('verif')) return 'auth';
    return 'system';
  }

  IconData _getIconForType(String type) {
    switch (type) {
      case 'follower':
        return Iconsax.user_add_copy;
      case 'wallet':
        return Iconsax.wallet_3_copy;
      case 'review':
        return Iconsax.star_1_copy;
      case 'like':
        return Iconsax.heart_copy;
      case 'block':
      case 'report':
        return Iconsax.shield_cross_copy;
      case 'profile':
        return Iconsax.user_edit_copy;
      case 'auth':
        return Iconsax.shield_tick_copy;
      default:
        return Iconsax.notification_bing_copy;
    }
  }
}
