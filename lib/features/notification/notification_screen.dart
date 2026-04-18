import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/app_text.dart';
import '../../../core/widgets/custom_app_bar.dart';
import 'controllers/notification_controller.dart';
import 'domain/models/notification_item_model.dart';
import 'notification_detail_screen.dart';

class NotificationScreen extends StatefulWidget {
  const NotificationScreen({super.key});

  @override
  State<NotificationScreen> createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen> {
  late final NotificationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = Get.find<NotificationController>();
    _controller.getNotifications();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: const CustomAppBar(
        title: 'Notifications',
      ),
      body: Obx(() {
        if (_controller.isNotificationsLoading.value) {
          return const Center(
            child: CircularProgressIndicator(color: AppColors.primaryColor),
          );
        }

        final notifications = _controller.notifications;

        if (notifications.isEmpty) {
          return _buildEmptyState();
        }

        return RefreshIndicator(
          color: AppColors.primaryColor,
          onRefresh: () async => _controller.getNotifications(),
          child: ListView.separated(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
            itemCount: notifications.length,
            separatorBuilder: (_, __) =>
                const Divider(height: 1, color: Color(0xFFEEEEEE)),
            itemBuilder: (context, index) {
              final notification = notifications[index];
              return GestureDetector(
                onTap: () => Get.to(() => NotificationDetailScreen(
                      notificationId: notification.id,
                    )),
                child: _buildNotificationItem(notification),
              );
            },
          ),
        );
      }),
    );
  }

  /// Derive an icon type from the notification title keywords
  String _getTypeFromTitle(String title) {
    final lower = title.toLowerCase();
    if (lower.contains('follow')) return 'follower';
    if (lower.contains('wallet') || lower.contains('earning') || lower.contains('credit')) return 'wallet';
    if (lower.contains('review') || lower.contains('rating') || lower.contains('star')) return 'review';
    if (lower.contains('like') || lower.contains('liked')) return 'like';
    if (lower.contains('block')) return 'block';
    if (lower.contains('report')) return 'report';
    if (lower.contains('photo') || lower.contains('profile')) return 'profile';
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
      default:
        return Iconsax.notification_bing_copy;
    }
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(25),
            decoration: const BoxDecoration(
              color: AppColors.lightPink,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Iconsax.notification_bing,
              size: 50,
              color: AppColors.deepPink,
            ),
          ),
          const SizedBox(height: 20),
          const AppText(
            'No Notifications',
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
          const SizedBox(height: 8),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 40),
            child: AppText(
              'You don\'t have any notifications yet. When you get one, it will appear here.',
              fontSize: 14,
              color: Colors.black54,
              textAlign: TextAlign.center,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNotificationItem(NotificationItemModel notification) {
    final bool isRead = notification.isRead;
    final String type = _getTypeFromTitle(notification.title);

    return Container(
      color: isRead ? Colors.white : AppColors.lightPink.withOpacity(0.3),
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Icon based on type
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: isRead ? const Color(0xFFF5F5F5) : AppColors.white,
              shape: BoxShape.circle,
              border: Border.all(
                color: isRead
                    ? Colors.transparent
                    : AppColors.deepPink.withOpacity(0.2),
              ),
            ),
            child: Icon(
              _getIconForType(type),
              size: 20,
              color: isRead ? Colors.grey : AppColors.deepPink,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: AppText(
                        notification.title,
                        fontSize: 15,
                        fontWeight:
                            isRead ? FontWeight.w500 : FontWeight.w700,
                        color: Colors.black87,
                      ),
                    ),
                    AppText(
                      notification.timeAgo,
                      fontSize: 11,
                      color: Colors.black45,
                      fontWeight: FontWeight.w500,
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                AppText(
                  notification.body,
                  fontSize: 13,
                  color: Colors.black54,
                  height: 1.4,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          if (!isRead)
            Padding(
              padding: const EdgeInsets.only(left: 8, top: 20),
              child: Container(
                width: 8,
                height: 8,
                decoration: const BoxDecoration(
                  color: AppColors.deepPink,
                  shape: BoxShape.circle,
                ),
              ),
            ),
        ],
      ),
    );
  }
}
