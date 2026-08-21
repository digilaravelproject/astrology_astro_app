import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/app_text.dart';
import '../../../core/widgets/custom_app_bar.dart';
import '../controllers/price_increase_controller.dart';
import 'package:intl/intl.dart';

class PriceIncreaseHistoryScreen extends StatefulWidget {
  const PriceIncreaseHistoryScreen({super.key});

  @override
  State<PriceIncreaseHistoryScreen> createState() => _PriceIncreaseHistoryScreenState();
}

class _PriceIncreaseHistoryScreenState extends State<PriceIncreaseHistoryScreen> {
  late final PriceIncreaseController _controller;

  @override
  void initState() {
    super.initState();
    _controller = Get.find<PriceIncreaseController>();
    _controller.fetchHistory();
  }

  String _formatDate(String? dateStr) {
    if (dateStr == null) return '';
    try {
      final dateTime = DateTime.parse(dateStr);
      return DateFormat('dd MMM yyyy, hh:mm a').format(dateTime);
    } catch (_) {
      return dateStr;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9F9F9),
      appBar: CustomAppBar(
        title: 'Increase History'.tr,
      ),
      body: Obx(() {
        if (_controller.isLoadingHistory.value) {
          return const Center(child: CircularProgressIndicator());
        }

        if (_controller.historyList.isEmpty) {
          return Center(
            child: AppText(
              "No price increase history found.".tr,
              fontSize: 14,
              color: Colors.grey,
            ),
          );
        }

        return RefreshIndicator(
          onRefresh: () => _controller.fetchHistory(),
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: _controller.historyList.length,
            itemBuilder: (context, index) {
              return _buildHistoryCard(_controller.historyList[index]);
            },
          ),
        );
      }),
    );
  }

  Widget _buildHistoryCard(dynamic item) {
    final status = (item['status']?.toString() ?? 'pending').toLowerCase();
    Color statusColor;
    IconData statusIcon;

    switch (status) {
      case 'approved':
        statusColor = Colors.green;
        statusIcon = Icons.check_circle_rounded;
        break;
      case 'pending':
        statusColor = Colors.orange;
        statusIcon = Icons.info_rounded;
        break;
      case 'rejected':
        statusColor = Colors.red;
        statusIcon = Icons.cancel_rounded;
        break;
      default:
        statusColor = Colors.grey;
        statusIcon = Icons.help_rounded;
    }

    final oldPrice = double.tryParse(item['old_price']?.toString() ?? '0')?.toStringAsFixed(0) ?? '0';
    final newPrice = double.tryParse(item['new_price']?.toString() ?? '0')?.toStringAsFixed(0) ?? '0';
    final type = (item['price_type']?.toString() ?? 'chat').toUpperCase();
    final date = _formatDate(item['created_at']?.toString());
    final adminRemark = item['admin_remark']?.toString();

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
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          AppText(
                            '₹$oldPrice',
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: Colors.grey.shade500,
                          ),
                          const SizedBox(width: 8),
                          Icon(Icons.arrow_forward_rounded, size: 16, color: Colors.grey.shade300),
                          const SizedBox(width: 8),
                          AppText(
                            '₹$newPrice',
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
                            '$type Rate • ',
                            fontSize: 13,
                            color: AppColors.primaryColor,
                            fontWeight: FontWeight.w600,
                          ),
                          Expanded(
                            child: AppText(
                              date,
                              fontSize: 12,
                              color: Colors.grey.shade500,
                              fontWeight: FontWeight.w500,
                              overflow: TextOverflow.ellipsis,
                            ),
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
                        status.capitalizeFirst ?? status,
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: statusColor,
                      ),
                    ],
                  ),
                ),
              ],
            ),
            if (adminRemark != null && adminRemark.trim().isNotEmpty) ...[
              const SizedBox(height: 12),
              const Divider(height: 1, color: Color(0xFFF5F5F5)),
              const SizedBox(height: 8),
              AppText(
                "Remark: $adminRemark",
                fontSize: 12,
                color: Colors.grey.shade600,
                fontStyle: FontStyle.italic,
              ),
            ],
          ],
        ),
      ),
    );
  }
}
