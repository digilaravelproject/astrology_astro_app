import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/app_text.dart';
import '../../../core/widgets/custom_button.dart';
import '../../../core/widgets/custom_app_bar.dart';
import 'presentation/bindings/finance_binding.dart';
import 'presentation/controllers/finance_controller.dart';
import 'package:astro_astrologer/features/wallet/presentation/controllers/wallet_controller.dart';
import 'presentation/screens/bank_accounts_screen.dart';
import 'data/models/bank_account_model.dart';
import 'package:astro_astrologer/core/utils/custom_snackbar.dart';

class WithdrawalScreen extends StatefulWidget {
  const WithdrawalScreen({super.key});

  @override
  State<WithdrawalScreen> createState() => _WithdrawalScreenState();
}

class _WithdrawalScreenState extends State<WithdrawalScreen> {
  final TextEditingController _amountController = TextEditingController();
  late FinanceController _financeController;
  late WalletController _walletController;

  @override
  void initState() {
    super.initState();
    if (!Get.isRegistered<FinanceController>()) {
      FinanceBinding().dependencies();
    }
    _financeController = Get.find<FinanceController>();
    _walletController = Get.find<WalletController>();

    // Ensure we have latest bank accounts
    _financeController.getBankAccounts();
  }

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
      appBar: const CustomAppBar(title: 'Withdraw Money'),
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
                border: Border.all(
                  color: AppColors.primaryColor.withOpacity(0.1),
                ),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Iconsax.wallet_3_copy,
                      color: AppColors.primaryColor,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      AppText(
                        'Available Balance'.tr,
                        fontSize: 13,
                        color: Colors.grey.shade600,
                        fontWeight: FontWeight.w500,
                      ),
                      const SizedBox(height: 4),
                      Obx(() {
                        final val = _walletController.summary.value;
                        return AppText(
                          '₹${val?.totalBalance ?? 0.0}',
                          fontSize: 20,
                          fontWeight: FontWeight.w800,
                          color: const Color(0xFF2E1A47),
                        );
                      }),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 32),
            AppText(
              'Enter Amount'.tr,
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: const Color(0xFF2E1A47),
            ),
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
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 14,
                    ),
                    child: const AppText(
                      '₹',
                      fontSize: 24,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF2E1A47),
                    ),
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
            AppText(
              'Withdrawal To'.tr,
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: const Color(0xFF2E1A47),
            ),
            const SizedBox(height: 16),

            // Bank Card Preview
            Obx(() {
              final accounts = _financeController.bankAccounts;
              // Force register observable by accessing length
              final _ = accounts.length;
              final defaultBank = accounts.firstWhereOrNull((b) => b.isDefault);

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
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
                          child: Icon(
                            Iconsax.bank_copy,
                            color: Colors.blue.shade600,
                            size: 20,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              AppText(
                                defaultBank != null
                                    ? defaultBank.bankName
                                    : 'No Bank Set',
                                fontSize: 15,
                                fontWeight: FontWeight.w700,
                                color: const Color(0xFF2E1A47),
                              ),
                              const SizedBox(height: 2),
                              AppText(
                                defaultBank != null
                                    ? '**** ${defaultBank.accountNumber.substring(defaultBank.accountNumber.length - 4)}'
                                    : 'Tap to add an account',
                                fontSize: 12,
                                color: Colors.grey.shade500,
                                fontWeight: FontWeight.w500,
                              ),
                            ],
                          ),
                        ),
                        TextButton(
                          onPressed: () {
                            Get.to(() => BankAccountsScreen())?.then((_) {
                              _financeController.getBankAccounts();
                            });
                          },
                          child: AppText(
                            defaultBank != null ? 'Change' : 'Add',
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            color: AppColors.primaryColor,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 48),

                  CustomButton(
                    text: 'Confirm Withdrawal',
                    onPressed: () {
                      if (_amountController.text.isEmpty) {
                        CustomSnackBar.disabledSnackbar(
                          'Invalid Amount',
                          'Please enter a valid amount',
                          backgroundColor: Colors.red.shade100,
                          colorText: Colors.red.shade800,
                        );
                        return;
                      }
                      if (defaultBank == null) {
                        CustomSnackBar.disabledSnackbar(
                          'No Bank',
                          'Please select or add a bank account',
                          backgroundColor: Colors.red.shade100,
                          colorText: Colors.red.shade800,
                        );
                        return;
                      }

                      Get.defaultDialog(
                        title: 'Confirm',
                        middleText:
                            'Are you sure you want to withdraw ₹${_amountController.text} to ${defaultBank.bankName}?',
                        cancel: TextButton(
                          onPressed: () => Navigator.of(context).pop(),
                          child: const Text(
                            'Cancel',
                            style: TextStyle(color: AppColors.primaryColor),
                          ),
                        ),
                        confirm: TextButton(
                          style: TextButton.styleFrom(
                            backgroundColor: AppColors.primaryColor,
                          ),
                          onPressed: () async {
                            Navigator.of(
                              context,
                            ).pop(); // Close confirm dialog safely

                            // Show loading dialog natively
                            showDialog(
                              context: context,
                              barrierDismissible: false,
                              builder:
                                  (context) => const Center(
                                    child: CircularProgressIndicator(),
                                  ),
                            );

                            final amount =
                                double.tryParse(_amountController.text) ?? 0.0;
                            final result = await _walletController
                                .requestWithdrawal(amount, defaultBank.id);

                            // Close loading dialog safely BEFORE showing any snackbar
                            Navigator.of(context).pop();

                            if (result['success'] == true) {
                              Get.back(); // close withdrawal screen
                              Future.delayed(
                                const Duration(milliseconds: 300),
                                () {
                                  CustomSnackBar.disabledSnackbar(
                                    'Success',
                                    result['message'],
                                    backgroundColor: Colors.green.shade100,
                                    colorText: Colors.green.shade800,
                                  );
                                },
                              );
                            } else {
                              Future.delayed(
                                const Duration(milliseconds: 300),
                                () {
                                  CustomSnackBar.disabledSnackbar(
                                    'Error',
                                    result['message'],
                                    backgroundColor: Colors.red.shade100,
                                    colorText: Colors.red.shade800,
                                  );
                                },
                              );
                            }
                          },
                          child: const Text(
                            'Confirm',
                            style: TextStyle(color: Colors.white),
                          ),
                        ),
                      );
                    },
                    backgroundColor: AppColors.primaryColor,
                    borderRadius: 100,
                  ),
                ],
              );
            }),

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
