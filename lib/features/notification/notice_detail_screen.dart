import 'package:flutter/material.dart';
import 'domain/models/notice_model.dart';
import '../../../core/utils/date_formatter.dart';
import '../../../core/widgets/app_text.dart';
import '../../../core/widgets/custom_app_bar.dart';

class NoticeDetailScreen extends StatelessWidget {
  final NoticeData notice;

  const NoticeDetailScreen({super.key, required this.notice});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: const CustomAppBar(
        title: 'Notice Details',
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
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.blue.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(100),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.access_time_filled,
                        size: 14,
                        color: Colors.blue,
                      ),
                      const SizedBox(width: 6),
                      AppText(
                        DateFormatter.timeAgo(notice.createdAt),
                        fontSize: 12,
                        color: Colors.blue,
                        fontWeight: FontWeight.w600,
                      ),
                    ],
                  ),
                ),
                const Spacer(),
                AppText(
                  DateFormatter.formatDateTime(notice.createdAt),
                  fontSize: 12,
                  color: Colors.grey,
                  fontWeight: FontWeight.w500,
                ),
              ],
            ),
            
            const SizedBox(height: 24),
            
            // Title
            AppText(
              notice.title,
              fontSize: 22,
              fontWeight: FontWeight.w800,
              color: const Color(0xFF2E1A47),
              height: 1.3,
            ),
            
            const SizedBox(height: 12),
            
            // Tag
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(8),
              ),
              child: AppText(
                '# ${notice.tag}',
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: Colors.grey.shade600,
              ),
            ),
            
            const SizedBox(height: 24),
            const Divider(color: Color(0xFFEEEEEE)),
            const SizedBox(height: 24),
            
            // Message Body
            AppText(
              notice.body,
              fontSize: 15,
              color: Colors.grey.shade800,
              height: 1.7,
            ),
          ],
        ),
      ),
    );
  }
}
