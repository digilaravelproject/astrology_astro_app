import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import 'package:astro_astrologer/core/theme/app_colors.dart';
import 'package:astro_astrologer/core/widgets/app_text.dart';
import 'package:astro_astrologer/core/widgets/custom_app_bar.dart';
import 'price_increase_history_screen.dart';
import 'package:astro_astrologer/features/auth/presentation/controllers/auth_controller.dart';
import 'package:astro_astrologer/features/profile/presentation/controllers/price_increase_controller.dart';
import 'package:astro_astrologer/core/utils/custom_snackbar.dart';

class PriceSettingScreen extends StatefulWidget {
  const PriceSettingScreen({super.key});

  @override
  State<PriceSettingScreen> createState() => _PriceSettingScreenState();
}

class _PriceSettingScreenState extends State<PriceSettingScreen> {
  late final PriceIncreaseController _controller;

  @override
  void initState() {
    super.initState();
    _controller = Get.put(PriceIncreaseController());
  }

  void _showRequestConfirmation(
    String priceType,
    double currentRate,
    double maxIncrease,
  ) {
    final amountController = TextEditingController();
    String? errorText;

    showDialog(
      context: context,
      builder:
          (context) => StatefulBuilder(
            builder: (context, setStateDialog) {
              final text = amountController.text.trim();
              final amount = double.tryParse(text);
              final isValid =
                  amount != null && amount > 0 && amount <= maxIncrease;

              void validate() {
                if (text.isEmpty) {
                  errorText = null;
                } else if (amount == null) {
                  errorText = 'Enter a valid number';
                } else if (amount <= 0) {
                  errorText = 'Amount must be greater than 0';
                } else if (amount > maxIncrease) {
                  errorText =
                      'Maximum limit is ₹${maxIncrease.toStringAsFixed(0)}';
                } else {
                  errorText = null;
                }
              }

              return AlertDialog(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                title: AppText(
                  "Request Price Increase".tr,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF2E1A47),
                ),
                content: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    AppText(
                      priceType.toLowerCase() == 'chat'
                          ? "Submit price increase request for CHAT rate.".tr
                          : "Submit price increase request for CALL rate.".tr,
                      fontSize: 14,
                      color: Colors.grey.shade700,
                    ),
                    const SizedBox(height: 12),
                    AppText(
                      "${"Current Rate:".tr} ₹${currentRate.toStringAsFixed(0)}/${"min".tr}",
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: Colors.grey.shade600,
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: amountController,
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                      decoration: InputDecoration(
                        labelText: "Desired Increase Amount (₹)".tr,
                        helperText:
                            "${"Max limit:".tr} ₹${maxIncrease.toStringAsFixed(0)}",
                        errorText: errorText,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 12,
                        ),
                      ),
                      onChanged: (val) {
                        final double? valDouble = double.tryParse(val);
                        if (valDouble != null && valDouble > maxIncrease) {
                          final maxStr = maxIncrease.toStringAsFixed(0);
                          amountController.text = maxStr;
                          amountController
                              .selection = TextSelection.fromPosition(
                            TextPosition(offset: maxStr.length),
                          );
                        }
                        setStateDialog(() {
                          validate();
                        });
                      },
                    ),
                  ],
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: Text("Cancel".tr),
                  ),
                  Obx(() {
                    return TextButton(
                      onPressed:
                          (!isValid || _controller.isSubmitting.value)
                              ? null
                              : () async {
                                final success = await _controller.submitRequest(
                                  priceType,
                                  amount,
                                );
                                if (success) {
                                  Navigator.of(context).pop();
                                }
                              },
                      child:
                          _controller.isSubmitting.value
                              ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                ),
                              )
                              : Text(
                                "Submit".tr,
                                style: const TextStyle(
                                  color: AppColors.primaryColor,
                                ),
                              ),
                    );
                  }),
                ],
              );
            },
          ),
    );
  }

  /// Format a rate value: show decimals only if non-zero (e.g. 21.6, not 21.00 or 21)
  String _formatRate(dynamic rawRate) {
    final double? val = double.tryParse(rawRate?.toString() ?? '');
    if (val == null) return rawRate?.toString() ?? '0';
    // If value has no fractional part, show as integer
    if (val == val.truncateToDouble()) return val.toStringAsFixed(0);
    // Otherwise strip trailing zeros (e.g. 21.60 → 21.6)
    return val
        .toStringAsFixed(2)
        .replaceAll(RegExp(r'0+$'), '')
        .replaceAll(RegExp(r'\.$'), '');
  }

  void _handlePriceCardTap(String priceType) {
    // Use canRequestMap directly from API response
    final canRequest = _controller.canRequestMap[priceType] == true;

    if (canRequest) {
      final double currentRate =
          double.tryParse(
            (priceType == 'chat'
                        ? _controller.currentRates['chat_rate_per_minute']
                        : _controller.currentRates['call_rate_per_minute'])
                    ?.toString() ??
                '0',
          ) ??
          0.0;
      final double maxIncrease =
          double.tryParse(
            _controller.currentLevel['max_increase_amount']?.toString() ?? '1',
          ) ??
          1.0;
      _showRequestConfirmation(priceType, currentRate, maxIncrease);
    } else {
      if (_controller.pendingRequest.isNotEmpty) {
        Get.dialog(
          AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            title: const AppText("Request Pending".tr,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
            content: AppText(
              "You already have a pending price increase request for ${_controller.pendingRequest['price_type']?.toString().toUpperCase()}.",
              fontSize: 14,
            ),
            actions: [
              TextButton(onPressed: () => Get.back(), child: const Text("OK".tr)),
            ],
          ),
        );
      } else {
        Get.dialog(
          AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            title: const AppText("Not Eligible".tr,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
            content: const AppText("You are not eligible for a price increase yet. Please meet the busy time criteria first.".tr,
              fontSize: 14,
            ),
            actions: [
              TextButton(onPressed: () => Get.back(), child: const Text("OK".tr)),
            ],
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9F9F9),
      appBar: CustomAppBar(
        title: 'Price Increase Request'.tr,
        actions: [
          IconButton(
            onPressed: () => Get.to(() => const PriceIncreaseHistoryScreen()),
            icon: const Icon(
              Iconsax.clock_copy,
              color: Color(0xFF2E1A47),
              size: 22,
            ),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Obx(() {
        if (_controller.isLoadingStatus.value) {
          return const Center(child: CircularProgressIndicator());
        }

        // Get rates from API or fallback to AuthController's astrologer rates
        String chatRate = '15';
        String callRate = '20';
        String videoRate = '30';

        if (_controller.currentRates.isNotEmpty) {
          chatRate = _formatRate(
            _controller.currentRates['chat_rate_per_minute'],
          );
          callRate = _formatRate(
            _controller.currentRates['call_rate_per_minute'],
          );
        } else {
          try {
            final authController = Get.find<AuthController>();
            final astrologer = authController.currentUser.value?.astrologer;
            if (astrologer != null) {
              chatRate = _formatRate(astrologer.chatRate);
              callRate = _formatRate(astrologer.callRate);
              videoRate = _formatRate(astrologer.videoCallRate);
            }
          } catch (_) {}
        }

        // Get level/criteria values
        final totalBusy = _controller.totalBusyMinutes.value;
        final currentReq =
            _controller.currentLevel['required_busy_minutes'] != null
                ? double.tryParse(
                      _controller.currentLevel['required_busy_minutes']
                          .toString(),
                    ) ??
                    0.0
                : 0.0;
        final nextReq =
            _controller.nextLevel['required_busy_minutes'] != null
                ? double.tryParse(
                      _controller.nextLevel['required_busy_minutes'].toString(),
                    ) ??
                    0.0
                : 0.0;

        // Show next_level's max increase in the criteria table (aligns with next_level's required time)
        // Fall back to current_level if next_level is not available
        final maxIncrease =
            _controller.nextLevel.isNotEmpty
                ? double.tryParse(
                      _controller.nextLevel['max_increase_amount']
                              ?.toString() ??
                          '1',
                    ) ??
                    1.0
                : double.tryParse(
                      _controller.currentLevel['max_increase_amount']
                              ?.toString() ??
                          '1',
                    ) ??
                    1.0;

        final targetRequired = nextReq > 0 ? nextReq : currentReq;
        final diff = (targetRequired - totalBusy).clamp(0.0, double.infinity);

        return RefreshIndicator(
          onRefresh: () => _controller.fetchStatus(),
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AppText(
                  'Consultation Rates'.tr,
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: const Color(0xFF2E1A47),
                ),
                const SizedBox(height: 8),
                AppText(
                  'Set your per-minute charges for different consultation modes.'
                      .tr,
                  fontSize: 13,
                  color: Colors.grey.shade600,
                  fontWeight: FontWeight.w400,
                ),
                if (_controller.pendingRequest.isNotEmpty) ...[
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFF9E6),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: Colors.amber.shade200),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(
                          Icons.info_rounded,
                          color: Colors.amber,
                          size: 22,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              AppText(
                                'Price Increase Request Pending'.tr,
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: const Color(0xFF855B00),
                              ),
                              const SizedBox(height: 4),
                              AppText(
                                'Request submitted for ${_controller.pendingRequest['price_type']?.toString().toUpperCase()} rate. Old Rate: ₹${double.tryParse(_controller.pendingRequest['old_price']?.toString() ?? '')?.toStringAsFixed(0) ?? ''}, New Rate: ₹${double.tryParse(_controller.pendingRequest['new_price']?.toString() ?? '')?.toStringAsFixed(0) ?? ''}.',
                                fontSize: 12,
                                color: const Color(0xFF855B00),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
                const SizedBox(height: 24),

                _buildPriceCard(
                  icon: Iconsax.message_copy,
                  title: 'Chat Rate'.tr,
                  rate: chatRate,
                  iconColor: const Color(0xFF2196F3),
                  backgroundColor: const Color(0xFFE3F2FD),
                  onTap: () => _handlePriceCardTap('chat'),
                  showEditIcon: _controller.canRequestMap['chat'] == true,
                ),

                _buildPriceCard(
                  icon: Iconsax.call_copy,
                  title: 'Call Rate'.tr,
                  rate: callRate,
                  iconColor: const Color(0xFF4CAF50),
                  backgroundColor: const Color(0xFFE8F5E9),
                  onTap: () => _handlePriceCardTap('call'),
                  showEditIcon: _controller.canRequestMap['call'] == true,
                ),

                _buildPriceCard(
                  icon: Iconsax.video_copy,
                  title: 'Video Rate'.tr,
                  rate: videoRate,
                  iconColor: AppColors.primaryColor,
                  backgroundColor: AppColors.primaryColor.withOpacity(0.1),
                  onTap: () {
                    CustomSnackBar.disabledSnackbar(
                      "Video Rate Update",
                      "Video price increase request is not supported yet.",
                    );
                  },
                  showEditIcon: false,
                ),

                const SizedBox(height: 32),

                // Price Increase Criteria Section
                AppText(
                  'Price Increase Criteria'.tr,
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: const Color(0xFF2E1A47),
                ),
                const SizedBox(height: 16),
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: Colors.grey.shade200),
                  ),
                  child: Column(
                    children: [
                      // Table Header
                      Container(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        decoration: const BoxDecoration(
                          color: Color(0xFFFFF9F9),
                          borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(20),
                            topRight: Radius.circular(20),
                          ),
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: Center(
                                child: AppText(
                                  'My Busy Time'.tr,
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                  color: const Color(0xFF2E1A47),
                                ),
                              ),
                            ),
                            Expanded(
                              child: Center(
                                child: AppText(
                                  'Required Time'.tr,
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                  color: const Color(0xFF2E1A47),
                                ),
                              ),
                            ),
                            Expanded(
                              child: Center(
                                child: AppText(
                                  'Price Increase'.tr,
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                  color: const Color(0xFF2E1A47),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const Divider(height: 1, color: Color(0xFFF0F0F0)),
                      // Table Data
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 20),
                        child: Row(
                          children: [
                            Expanded(
                              child: Center(
                                child: AppText(
                                  '${totalBusy.toStringAsFixed(0)} ${"mins".tr}',
                                  fontSize: 15,
                                  fontWeight: FontWeight.w500,
                                  color: Colors.grey.shade700,
                                ),
                              ),
                            ),
                            Expanded(
                              child: Center(
                                child: AppText(
                                  '${targetRequired.toStringAsFixed(0)} ${"mins".tr}',
                                  fontSize: 15,
                                  fontWeight: FontWeight.w500,
                                  color: Colors.grey.shade700,
                                ),
                              ),
                            ),
                            Expanded(
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  AppText(
                                    '₹${maxIncrease.toStringAsFixed(0)} ',
                                    fontSize: 15,
                                    fontWeight: FontWeight.w500,
                                    color: const Color(0xFF2E1A47),
                                  ),
                                  Container(
                                    decoration: const BoxDecoration(
                                      color: Colors.green,
                                      shape: BoxShape.circle,
                                    ),
                                    child: const Icon(
                                      Icons.arrow_upward_rounded,
                                      color: Colors.white,
                                      size: 14,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      // Eligibility Banner
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(
                          vertical: 12,
                          horizontal: 16,
                        ),
                        decoration: BoxDecoration(
                          color:
                              diff > 0
                                  ? const Color(0xFFFFF9E6)
                                  : const Color(0xFFF1FDF5),
                          borderRadius: const BorderRadius.only(
                            bottomLeft: Radius.circular(20),
                            bottomRight: Radius.circular(20),
                          ),
                        ),
                        child: Center(
                          child: AppText(
                            diff > 0
                                ? '${"Only".tr} ${diff.toStringAsFixed(0)} ${"mins more to be eligible for price increase.".tr}'
                                : 'You are eligible for a price increase request!'
                                    .tr,
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color:
                                diff > 0
                                    ? const Color(0xFF855B00)
                                    : const Color(0xFF1B5E20),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 32),

                // Terms & Conditions Section
                AppText(
                  'Terms & Conditions'.tr,
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: const Color(0xFF2E1A47),
                ),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(color: Colors.grey.shade100),
                  ),
                  child: Column(
                    children: [
                      _buildTermItem(
                        icon: Iconsax.repeat_copy,
                        color: Colors.red.shade100,
                        text:
                            'You can increase your price based on level thresholds and performance parameters.'
                                .tr,
                      ),
                      const SizedBox(height: 20),
                      _buildTermItem(
                        icon: Iconsax.status_up_copy,
                        color: Colors.red.shade50.withOpacity(0.5),
                        text:
                            'Price increase offers will be applied on your profile after admin review.'
                                .tr,
                      ),
                      const SizedBox(height: 20),
                      _buildTermItem(
                        icon: Iconsax.clock_copy,
                        color: Colors.red.shade50.withOpacity(0.5),
                        text:
                            'If you don’t want to increase your price now, you can do it later — once your profile meets the required parameters.'
                                .tr,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                AppText(
                  '**Other normalised parameters are also considered.'.tr,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: AppColors.primaryColor,
                ),
                const SizedBox(height: 40),
              ],
            ),
          ),
        );
      }),
    );
  }

  Widget _buildTermItem({
    required IconData icon,
    required Color color,
    required String text,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          child: Icon(icon, color: Colors.red.shade300, size: 18),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: AppText(
            text,
            fontSize: 13,
            color: Colors.grey.shade700,
            fontWeight: FontWeight.w500,
            height: 1.4,
          ),
        ),
      ],
    );
  }

  Widget _buildPriceCard({
    required IconData icon,
    required String title,
    required String rate,
    required Color iconColor,
    required Color backgroundColor,
    required VoidCallback onTap,
    bool showEditIcon = true,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: showEditIcon ? onTap : null,
          borderRadius: BorderRadius.circular(24),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    color: backgroundColor,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(icon, color: iconColor, size: 28),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      AppText(
                        title,
                        fontSize: 12,
                        color: Colors.grey.shade500,
                        fontWeight: FontWeight.w600,
                      ),
                      const SizedBox(height: 4),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.baseline,
                        textBaseline: TextBaseline.alphabetic,
                        children: [
                          AppText(
                            '₹$rate',
                            fontSize: 20,
                            fontWeight: FontWeight.w800,
                            color: const Color(0xFF2E1A47),
                          ),
                          const SizedBox(width: 4),
                          AppText(
                            '/ min'.tr,
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            color: Colors.grey.shade400,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                if (showEditIcon)
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade50,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.edit_rounded,
                      color: Colors.grey.shade400,
                      size: 18,
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
