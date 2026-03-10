import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/app_text.dart';
import '../../../core/widgets/custom_app_bar.dart';

class NotificationDetailScreen extends StatelessWidget {
  final Map<String, dynamic> notification;

  const NotificationDetailScreen({super.key, required this.notification});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: const CustomAppBar(
        title: 'Notification Details',
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Icon and Date Row
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.lightPink.withOpacity(0.3),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    _getIconForType(notification['type']),
                    size: 24,
                    color: AppColors.deepPink,
                  ),
                ),
                const SizedBox(width: 12),
                AppText(
                  notification['time'],
                  fontSize: 14,
                  color: Colors.black54,
                  fontWeight: FontWeight.w500,
                ),
              ],
            ),
            
            const SizedBox(height: 20),
            
            // Title
            AppText(
              notification['title'],
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: Colors.black87,
              height: 1.3,
            ),
            
            const SizedBox(height: 16),
            const Divider(color: Color(0xFFEEEEEE)),
            const SizedBox(height: 16),
            
            // Message Body
            AppText(
              notification['message'],
              fontSize: 16,
              color: Colors.black87,
              height: 1.6,
            ),
          ],
        ),
      ),
    );
  }

  IconData _getIconForType(String type) {
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
}
