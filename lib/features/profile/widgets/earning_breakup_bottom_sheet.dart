import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/app_text.dart';

class EarningBreakupBottomSheet extends StatelessWidget {
  const EarningBreakupBottomSheet({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const AppText('Earning Breakup', fontSize: 20, fontWeight: FontWeight.bold),
              IconButton(
                onPressed: () => Navigator.pop(context),
                icon: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.close, size: 20, color: Colors.black87),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          _buildBreakupRow('Available Balance', '₹129', isTitle: true),
          const SizedBox(height: 8),
          _buildBreakupRow('PG Charge:', '- ₹3', isNegative: true),
          _buildDescription('2.5% charge deducted by Payment Gateways for accepting online payments'),
          const SizedBox(height: 16),
          const Divider(height: 1),
          const SizedBox(height: 16),
          _buildBreakupRow('Sub Total :', '₹126', isTitle: true),
          const SizedBox(height: 8),
          _buildBreakupRow('TDS:', '- ₹13', isNegative: true),
          _buildDescription('10% of subtotal. Tax deducted as per government regulations'),
          const SizedBox(height: 12),
          _buildBreakupRow('GST:', '₹0'),
          _buildDescription('GST certificate mandatory for astrologers who earn more than INR 20 lacs per year'),
          const SizedBox(height: 24),
          const Divider(height: 1),
          const SizedBox(height: 24),
          _buildBreakupRow(
            'Payable Amount',
            '₹113',
            isTitle: true,
            isGreen: true,
            fontSize: 22,
          ),
          const SizedBox(height: 16),
          SafeArea(child: const SizedBox(height: 16)),
        ],
      ),
    );
  }

  Widget _buildBreakupRow(String title, String value, {bool isTitle = false, bool isNegative = false, bool isGreen = false, double fontSize = 16}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        AppText(
          title,
          fontSize: fontSize,
          fontWeight: isTitle ? FontWeight.bold : FontWeight.w500,
          color: isGreen ? AppColors.successColor : Colors.black87,
        ),
        AppText(
          value,
          fontSize: fontSize,
          fontWeight: FontWeight.bold,
          color: isGreen ? AppColors.successColor : (isNegative ? AppColors.errorColor : AppColors.successColor),
        ),
      ],
    );
  }

  Widget _buildDescription(String text) {
    return Padding(
      padding: const EdgeInsets.only(top: 4, right: 40),
      child: AppText(
        text,
        fontSize: 11,
        color: Colors.grey.shade500,
        height: 1.4,
      ),
    );
  }
}
