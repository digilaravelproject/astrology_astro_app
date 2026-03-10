import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/app_text.dart';
import '../../../core/widgets/custom_app_bar.dart';
import 'add_bank_screen.dart';

class BankDetailsScreen extends StatefulWidget {
  const BankDetailsScreen({super.key});

  @override
  State<BankDetailsScreen> createState() => _BankDetailsScreenState();
}

class _BankDetailsScreenState extends State<BankDetailsScreen> {
  // Mock data for saved bank accounts
  final List<Map<String, dynamic>> _savedBanks = [
    {
      'bankName': 'HDFC Bank',
      'accountNumber': 'XXXX XXXX 1234',
      'holderName': 'John Doe',
      'isDefault': true,
    },
    {
      'bankName': 'State Bank of India',
      'accountNumber': 'XXXX XXXX 5678',
      'holderName': 'John Doe',
      'isDefault': false,
    },
  ];

  void _setAsDefault(int index) {
    setState(() {
      for (var i = 0; i < _savedBanks.length; i++) {
        _savedBanks[i]['isDefault'] = (i == index);
      }
    });
    Get.snackbar(
      'Success',
      'Default bank account updated!',
      backgroundColor: Colors.green.withOpacity(0.1),
      colorText: Colors.green,
      snackPosition: SnackPosition.BOTTOM,
      margin: const EdgeInsets.all(20),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9F9F9),
      appBar: const CustomAppBar(
        title: 'Bank Details',
      ),
      body: _savedBanks.isEmpty
          ? _buildEmptyState()
          : ListView.builder(
              padding: const EdgeInsets.all(20),
              itemCount: _savedBanks.length,
              itemBuilder: (context, index) {
                return _buildBankCard(_savedBanks[index], index);
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final result = await Get.to(() => const AddBankScreen());
          if (result == true) {
            // In a real app, we would refresh from API
          }
        },
        backgroundColor: AppColors.primaryColor,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: const Icon(Icons.add_rounded, color: Colors.white, size: 32),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: AppColors.primaryColor.withOpacity(0.05),
              shape: BoxShape.circle,
            ),
            child: Icon(Iconsax.bank_copy, color: AppColors.primaryColor.withOpacity(0.2), size: 64),
          ),
          const SizedBox(height: 24),
          const AppText(
            'No Bank Accounts Found',
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: Color(0xFF2E1A47),
          ),
          const SizedBox(height: 8),
          AppText(
            'Add an account to receive your payouts.',
            fontSize: 14,
            color: Colors.grey.shade500,
          ),
        ],
      ),
    );
  }

  Widget _buildBankCard(Map<String, dynamic> bank, int index) {
    final bool isDefault = bank['isDefault'];

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isDefault ? AppColors.primaryColor.withOpacity(0.2) : Colors.grey.shade200,
          width: isDefault ? 1.5 : 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: AppColors.primaryColor.withOpacity(0.08),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Iconsax.bank_copy, color: AppColors.primaryColor, size: 20),
                    ),
                    const SizedBox(width: 12),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        AppText(
                          bank['bankName'],
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: const Color(0xFF2E1A47),
                        ),
                        const SizedBox(height: 2),
                        AppText(
                          bank['accountNumber'],
                          fontSize: 13,
                          color: Colors.grey.shade500,
                          fontWeight: FontWeight.w500,
                        ),
                      ],
                    ),
                  ],
                ),
                if (isDefault)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.primaryColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(100),
                    ),
                    child: const AppText(
                      'Default',
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: AppColors.primaryColor,
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 16),
            const Divider(height: 1),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    AppText(
                      'Account Holder',
                      fontSize: 11,
                      color: Colors.grey.shade400,
                      fontWeight: FontWeight.w500,
                    ),
                    AppText(
                      bank['holderName'],
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF2E1A47),
                    ),
                  ],
                ),
                if (!isDefault)
                  TextButton(
                    onPressed: () => _setAsDefault(index),
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                    child: const AppText(
                      'Set as Default',
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: AppColors.primaryColor,
                    ),
                  )
                else
                  const Row(
                    children: [
                      Icon(Icons.check_circle_rounded, color: Colors.green, size: 16),
                      SizedBox(width: 4),
                      AppText(
                        'Active',
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: Colors.green,
                      ),
                    ],
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
