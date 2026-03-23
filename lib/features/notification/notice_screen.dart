import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/app_text.dart';
import '../../../core/widgets/custom_app_bar.dart';
import '../../../core/utils/date_formatter.dart';
import 'controllers/notice_controller.dart';
import 'domain/models/notice_model.dart';
import 'notice_detail_screen.dart';

class NoticeScreen extends GetView<NoticeController> {
  const NoticeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),
      appBar: const CustomAppBar(
        title: 'Notice Board',
        showLeading: false,
        centerTitle: true,
      ),
      body: Obx(() {
        if (controller.isLoading.value && controller.notices.isEmpty) {
          return const Center(child: CircularProgressIndicator());
        }

        if (controller.notices.isEmpty) {
          return _buildEmptyState();
        }

        return RefreshIndicator(
          onRefresh: () => controller.getNotices(),
          child: ListView.separated(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 100),
            itemCount: controller.notices.length,
            separatorBuilder: (context, index) => const SizedBox(height: 16),
            itemBuilder: (context, index) {
              return _buildNoticeCard(controller.notices[index]);
            },
          ),
        );
      }),
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
              color: Color(0xFFF3E5F5),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Iconsax.notification_bing,
              size: 50,
              color: AppColors.primaryColor,
            ),
          ),
          const SizedBox(height: 20),
          const AppText(
            'No Notices Yet',
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: Color(0xFF2E1A47),
          ),
          const SizedBox(height: 8),
          const AppText(
            'Important announcements from admin\nwill appear here.',
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: Colors.grey,
            textAlign: TextAlign.center,
            height: 1.5,
          ),
        ],
      ),
    );
  }

  Widget _buildNoticeCard(NoticeData notice) {
    final bool isHighPriority = notice.isUrgent;
    
    return GestureDetector(
      onTap: () => Get.to(() => NoticeDetailScreen(notice: notice)),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 15,
              offset: const Offset(0, 5),
            ),
          ],
          border: Border.all(
            color: isHighPriority ? Colors.red.withOpacity(0.1) : Colors.grey.shade100,
            width: isHighPriority ? 2 : 1,
          ),
        ),
        child: Stack(
          children: [
            if (isHighPriority)
              Positioned(
                top: 0,
                right: 0,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  decoration: const BoxDecoration(
                    color: Colors.red,
                    borderRadius: BorderRadius.only(
                      topRight: Radius.circular(18),
                      bottomLeft: Radius.circular(12),
                    ),
                  ),
                  child: const AppText(
                    'URGENT',
                    fontSize: 10,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: _getTypeColor(notice.tag).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(
                          _getTypeIcon(notice.tag),
                          size: 20,
                          color: _getTypeColor(notice.tag),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            AppText(
                              notice.title,
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                              color: const Color(0xFF2E1A47),
                            ),
                            AppText(
                              DateFormatter.timeAgo(notice.createdAt),
                              fontSize: 12,
                              color: Colors.grey,
                              fontWeight: FontWeight.w500,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  AppText(
                    notice.body,
                    fontSize: 12,
                    color: Colors.grey.shade700,
                    height: 1.5,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade50,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: AppText(
                      '# ${notice.tag}',
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: Colors.grey.shade500,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _getTypeColor(String type) {
    switch (type.toLowerCase()) {
      case 'maintenance': return Colors.blue;
      case 'account': return Colors.green;
      case 'policy': return Colors.orange;
      case 'community': return Colors.purple;
      default: return Colors.grey;
    }
  }

  IconData _getTypeIcon(String type) {
    switch (type.toLowerCase()) {
      case 'maintenance': return Iconsax.setting_2;
      case 'account': return Iconsax.wallet_2;
      case 'policy': return Iconsax.document_text;
      case 'community': return Iconsax.people;
      default: return Iconsax.notification;
    }
  }
}
