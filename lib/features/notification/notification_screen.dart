import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/app_text.dart';
import '../../../core/widgets/custom_app_bar.dart';
import 'notification_detail_screen.dart';
import '../../../core/utils/custom_snackbar.dart';

class NotificationScreen extends StatelessWidget {
  const NotificationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Mock notifications matching astrologer context but user app style
    final List<Map<String, dynamic>> notifications = [
      {
        'title': 'New Follower alert! 👤',
        'message': 'Amit Kumar just started following you. Check out their profile now.',
        'time': '5 min ago',
        'isRead': false,
        'type': 'follower',
      },
      {
        'title': 'Earning Credit! 💰',
        'message': 'Success! ₹500 has been credited to your wallet for the last session.',
        'time': '2 hours ago',
        'isRead': false,
        'type': 'wallet',
      },
      {
        'title': 'Positive Review Received ⭐',
        'message': 'Congratulations! You received a 5-star rating from Suman Roy.',
        'time': '1 day ago',
        'isRead': true,
        'type': 'review',
      },
      {
        'title': 'System Update ⚙️',
        'message': 'We have updated our terms and conditions. Please review them at your convenience.',
        'time': '3 days ago',
        'isRead': true,
        'type': 'system',
      },
    ];

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: CustomAppBar(
        title: 'Notifications',
        actions: [
          IconButton(
            icon: const Icon(Iconsax.tick_circle, color: AppColors.deepPink),
            tooltip: "Mark all as read",
            onPressed: () {
             // CustomSnackBar.showSuccess('This is a test success message');
            },
          ),
        ],
      ),
      body: notifications.isEmpty
          ? _buildEmptyState()
          : ListView.separated(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
              itemCount: notifications.length,
              separatorBuilder: (context, index) => const Divider(height: 1, color: Color(0xFFEEEEEE)),
              itemBuilder: (context, index) {
                final notification = notifications[index];
                return GestureDetector(
                  onTap: () => Get.to(() => NotificationDetailScreen(notification: notification)),
                  child: _buildNotificationItem(notification),
                );
              },
            ),
    );
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
              'You dont have any notification yet. When you get one, it will appear here.',
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

  Widget _buildNotificationItem(Map<String, dynamic> notification) {
    bool isRead = notification['isRead'];
    
    IconData getIconForType(String type) {
      switch (type) {
        case 'follower':
          return Iconsax.user_add_copy;
        case 'wallet':
          return Iconsax.wallet_3_copy;
        case 'review':
          return Iconsax.star_1_copy;
        case 'system':
          return Iconsax.info_circle_copy;
        default:
          return Iconsax.notification_bing_copy;
      }
    }

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
                color: isRead ? Colors.transparent : AppColors.deepPink.withOpacity(0.2),
              ),
            ),
            child: Icon(
              getIconForType(notification['type']),
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
                        notification['title'],
                        fontSize: 15,
                        fontWeight: isRead ? FontWeight.w500 : FontWeight.w700,
                        color: Colors.black87,
                      ),
                    ),
                    AppText(
                      notification['time'],
                      fontSize: 11,
                      color: Colors.black45,
                      fontWeight: FontWeight.w500,
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                AppText(
                  notification['message'],
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
