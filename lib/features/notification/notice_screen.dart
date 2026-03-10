import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/app_text.dart';
import '../../../core/widgets/custom_app_bar.dart';

class NoticeScreen extends StatefulWidget {
  const NoticeScreen({super.key});

  @override
  State<NoticeScreen> createState() => _NoticeScreenState();
}

class _NoticeScreenState extends State<NoticeScreen> {
  // Mock data for admin notices
  final List<Map<String, dynamic>> _notices = [
    {
      'id': '1',
      'title': 'System Maintenance',
      'message': 'The system will be under maintenance on 22nd Feb from 2:00 AM to 4:00 AM. Services might be disrupted during this period.',
      'date': '20 Feb 2026',
      'isHighPriority': true,
      'type': 'Technical',
    },
    {
      'id': '2',
      'title': 'New Payout Cycle',
      'message': 'Good news! We have updated our payout cycle. Now you will receive your earnings every Monday instead of every 15 days.',
      'date': '19 Feb 2026',
      'isHighPriority': false,
      'type': 'Account',
    },
    {
      'id': '3',
      'title': 'Policy Update',
      'message': 'Please review our updated terms and conditions regarding consultation rates. Effective from 1st March.',
      'date': '18 Feb 2026',
      'isHighPriority': false,
      'type': 'Policy',
    },
    {
      'id': '4',
      'title': 'Top Performer Award',
      'message': 'Congratulations to all astrologers for achieving 95% user satisfaction last week. Keep up the great work!',
      'date': '15 Feb 2026',
      'isHighPriority': false,
      'type': 'Community',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),
      appBar: const CustomAppBar(
        title: 'Notice Board',
        showLeading: false,
        centerTitle: true,
      ),
      body: _notices.isEmpty
          ? _buildEmptyState()
          : ListView.separated(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 100),
              itemCount: _notices.length,
              separatorBuilder: (context, index) => const SizedBox(height: 16),
              itemBuilder: (context, index) {
                return _buildNoticeCard(_notices[index]);
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

  Widget _buildNoticeCard(Map<String, dynamic> notice) {
    final bool isHighPriority = notice['isHighPriority'] ?? false;
    
    return Container(
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
                        color: _getTypeColor(notice['type']).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        _getTypeIcon(notice['type']),
                        size: 20,
                        color: _getTypeColor(notice['type']),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          AppText(
                            notice['title'],
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            color: const Color(0xFF2E1A47),
                          ),
                          AppText(
                            notice['date'],
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
                  notice['message'],
                  fontSize: 12,
                  color: Colors.grey.shade700,
                  height: 1.5,
                ),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade50,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: AppText(
                    '# ${notice['type']}',
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
    );
  }

  Color _getTypeColor(String type) {
    switch (type) {
      case 'Technical': return Colors.blue;
      case 'Account': return Colors.green;
      case 'Policy': return Colors.orange;
      case 'Community': return Colors.purple;
      default: return Colors.grey;
    }
  }

  IconData _getTypeIcon(String type) {
    switch (type) {
      case 'Technical': return Iconsax.setting_2;
      case 'Account': return Iconsax.wallet_2;
      case 'Policy': return Iconsax.document_text;
      case 'Community': return Iconsax.people;
      default: return Iconsax.notification;
    }
  }
}
