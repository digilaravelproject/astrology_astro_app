import 'package:flutter/material.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/app_text.dart';
import '../../../core/widgets/custom_app_bar.dart';

class PriceIncreaseHistoryScreen extends StatelessWidget {
  const PriceIncreaseHistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Mock history data
    final List<Map<String, dynamic>> historyItems = [
      {
        'type': 'Chat Rate',
        'oldPrice': '₹31',
        'newPrice': '₹30',
        'date': '09 Aug 2025',
        'status': 'Approved',
      },
      {
        'type': 'Call Rate',
        'oldPrice': '₹31',
        'newPrice': '₹30',
        'date': '09 Aug 2025',
        'status': 'Approved',
      },
      {
        'type': 'Chat Rate',
        'oldPrice': '₹30',
        'newPrice': '₹31',
        'date': '06 Aug 2025',
        'status': 'Approved',
      },
      {
        'type': 'Call Rate',
        'oldPrice': '₹30',
        'newPrice': '₹31',
        'date': '06 Aug 2025',
        'status': 'Approved',
      },
      {
        'type': 'Chat Rate',
        'oldPrice': '₹34',
        'newPrice': '₹30',
        'date': '03 Dec 2024',
        'status': 'Rejected',
      },
      {
        'type': 'Call Rate',
        'oldPrice': '₹29',
        'newPrice': '₹34',
        'date': '18 Nov 2024',
        'status': 'Pending',
      },
    ];

    return Scaffold(
      backgroundColor: const Color(0xFFF9F9F9),
      appBar: const CustomAppBar(
        title: 'Increase History',
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: historyItems.length,
        itemBuilder: (context, index) {
          return _buildHistoryCard(historyItems[index]);
        },
      ),
    );
  }

  Widget _buildHistoryCard(Map<String, dynamic> item) {
    final status = item['status'];
    Color statusColor;
    IconData statusIcon;

    switch (status) {
      case 'Approved':
        statusColor = Colors.green;
        statusIcon = Icons.check_circle_rounded;
        break;
      case 'Pending':
        statusColor = Colors.orange;
        statusIcon = Icons.info_rounded;
        break;
      case 'Rejected':
        statusColor = Colors.red;
        statusIcon = Icons.cancel_rounded;
        break;
      default:
        statusColor = Colors.grey;
        statusIcon = Icons.help_rounded;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.grey.shade100),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      AppText(
                        item['oldPrice'],
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: Colors.grey.shade500,
                      ),
                      const SizedBox(width: 8),
                      Icon(Icons.arrow_forward_rounded, size: 16, color: Colors.grey.shade300),
                      const SizedBox(width: 8),
                      AppText(
                        item['newPrice'],
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                        color: const Color(0xFF2E1A47),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      AppText(
                        '${item['date']} • ',
                        fontSize: 13,
                        color: Colors.grey.shade500,
                        fontWeight: FontWeight.w500,
                      ),
                      AppText(
                        item['type'],
                        fontSize: 13,
                        color: AppColors.primaryColor,
                        fontWeight: FontWeight.w600,
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: statusColor.withOpacity(0.05),
                borderRadius: BorderRadius.circular(100),
              ),
              child: Row(
                children: [
                  Icon(statusIcon, color: statusColor, size: 16),
                  const SizedBox(width: 6),
                  AppText(
                    status,
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: statusColor,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
