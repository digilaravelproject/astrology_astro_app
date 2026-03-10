import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/app_text.dart';
import '../../../core/widgets/custom_button.dart';
import '../../../core/widgets/custom_app_bar.dart';

class WithdrawalScreen extends StatefulWidget {
  const WithdrawalScreen({super.key});

  @override
  State<WithdrawalScreen> createState() => _WithdrawalScreenState();
}

class _WithdrawalScreenState extends State<WithdrawalScreen> {
  final TextEditingController _amountController = TextEditingController();
  final double _availableBalance = 12450.00;

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  void _addAmount(int amount) {
    setState(() {
      _amountController.text = amount.toString();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9F9F9),
      appBar: const CustomAppBar(
        title: 'Withdraw Money',
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Balance Card
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppColors.primaryColor.withOpacity(0.05),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: AppColors.primaryColor.withOpacity(0.1)),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Iconsax.wallet_3_copy, color: AppColors.primaryColor, size: 24),
                  ),
                  const SizedBox(width: 16),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      AppText('Available Balance', fontSize: 13, color: Colors.grey.shade600, fontWeight: FontWeight.w500),
                      const SizedBox(height: 4),
                      AppText('₹$_availableBalance', fontSize: 20, fontWeight: FontWeight.w800, color: const Color(0xFF2E1A47)),
                    ],
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 32),
            AppText('Enter Amount', fontSize: 15, fontWeight: FontWeight.w700, color: const Color(0xFF2E1A47)),
            const SizedBox(height: 16),
            
            // Amount Input
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.grey.shade200),
              ),
              child: TextField(
                controller: _amountController,
                keyboardType: TextInputType.number,
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF2E1A47),
                ),
                decoration: InputDecoration(
                  prefixIcon: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                    child: const AppText('₹', fontSize: 24, fontWeight: FontWeight.w700, color: Color(0xFF2E1A47)),
                  ),
                  hintText: '0.00',
                  hintStyle: TextStyle(color: Colors.grey.shade300),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(vertical: 18),
                ),
              ),
            ),
            
            const SizedBox(height: 16),
            
            // Quick Select Chips
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              physics: const BouncingScrollPhysics(),
              child: Row(
                children: [
                  _buildQuickChip(500),
                  const SizedBox(width: 12),
                  _buildQuickChip(1000),
                  const SizedBox(width: 12),
                  _buildQuickChip(2000),
                  const SizedBox(width: 12),
                  _buildQuickChip(5000),
                ],
              ),
            ),
            
            const SizedBox(height: 40),
            AppText('Withdrawal To', fontSize: 15, fontWeight: FontWeight.w700, color: const Color(0xFF2E1A47)),
            const SizedBox(height: 16),
            
            // Bank Card Preview
            Container(
              padding: const EdgeInsets.all(20),
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
              child: Row(
                children: [
                   Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.blue.shade50,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(Iconsax.bank_copy, color: Colors.blue.shade600, size: 20),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        AppText('HDFC Bank', fontSize: 15, fontWeight: FontWeight.w700, color: const Color(0xFF2E1A47)),
                        const SizedBox(height: 2),
                        AppText('**** 4512', fontSize: 12, color: Colors.grey.shade500, fontWeight: FontWeight.w500),
                      ],
                    ),
                  ),
                  TextButton(
                    onPressed: () {},
                    child: const AppText('Change', fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.primaryColor),
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 48),
            
            CustomButton(
              text: 'Confirm Withdrawal',
              onPressed: () {
                if (_amountController.text.isNotEmpty) {
                   Get.defaultDialog(
                    title: 'Confirm',
                    middleText: 'Are you sure you want to withdraw ₹${_amountController.text}?',
                    textConfirm: 'Confirm',
                    textCancel: 'Cancel',
                    confirmTextColor: Colors.white,
                    buttonColor: AppColors.primaryColor,
                    onConfirm: () {
                      Get.back();
                      Get.back();
                      Get.snackbar(
                        'Request Sent',
                        'Your withdrawal request has been submitted!',
                        backgroundColor: Colors.green,
                        colorText: Colors.white,
                      );
                    }
                  );
                }
              },
              backgroundColor: AppColors.primaryColor,
              borderRadius: 100,
            ),
            
            const SizedBox(height: 20),
            Center(
              child: AppText(
                'Funds will be credited within 24-48 hours',
                fontSize: 12,
                color: Colors.grey.shade400,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickChip(int amount) {
    return GestureDetector(
      onTap: () => _addAmount(amount),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: Colors.grey.shade200),
        ),
        child: AppText(
          '+₹$amount',
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: Colors.grey.shade700,
        ),
      ),
    );
  }
}
