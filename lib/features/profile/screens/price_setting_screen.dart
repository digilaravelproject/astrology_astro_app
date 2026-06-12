import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/app_text.dart';
import '../../../core/widgets/custom_app_bar.dart';
import 'price_increase_history_screen.dart';
import '../../auth/controllers/auth_controller.dart';
import '../controllers/price_increase_controller.dart';

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

  void _showRequestConfirmation(String priceType, double currentRate, double maxIncrease) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: AppText("Request Price Increase", fontSize: 18, fontWeight: FontWeight.bold, color: const Color(0xFF2E1A47)),
        content: AppText(
          "Are you sure you want to submit a price increase request for ${priceType.toUpperCase()}? Your rate will increase from ₹${currentRate.toStringAsFixed(0)} to ₹${(currentRate + maxIncrease).toStringAsFixed(0)}.",
          fontSize: 14,
          color: Colors.grey.shade700,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text("Cancel"),
          ),
          Obx(() {
            return TextButton(
              onPressed: _controller.isSubmitting.value
                  ? null
                  : () async {
                      final success = await _controller.submitRequest(priceType);
                      if (success) {
                        Navigator.of(context).pop();
                      }
                    },
              child: _controller.isSubmitting.value
                  ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))
                  : const Text("Submit", style: TextStyle(color: AppColors.primaryColor)),
            );
          }),
        ],
      ),
    );
  }

  void _handlePriceCardTap(String priceType) {
    final totalBusy = _controller.totalBusyMinutes.value;
    final currentReq = _controller.currentLevel['required_busy_minutes'] != null
        ? double.tryParse(_controller.currentLevel['required_busy_minutes'].toString()) ?? 0.0
        : 0.0;
    final nextReq = _controller.nextLevel['required_busy_minutes'] != null
        ? double.tryParse(_controller.nextLevel['required_busy_minutes'].toString()) ?? 0.0
        : 0.0;
    final targetRequired = nextReq > 0 ? nextReq : currentReq;

    final isEligible = totalBusy >= targetRequired && _controller.pendingRequest.isEmpty;

    if (isEligible) {
      final double currentRate = double.tryParse(
          (priceType == 'chat'
              ? _controller.currentRates['chat_rate_per_minute']
              : _controller.currentRates['call_rate_per_minute'])?.toString() ?? '0'
      ) ?? 0.0;
      final double maxIncrease = double.tryParse(
          (_controller.currentLevel['max_increase_amount'] ?? _controller.nextLevel['max_increase_amount'])?.toString() ?? '1'
      ) ?? 1.0;
      _showRequestConfirmation(priceType, currentRate, maxIncrease);
    } else {
      if (_controller.pendingRequest.isNotEmpty) {
        Get.dialog(
          AlertDialog(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            title: const AppText("Request Pending", fontSize: 18, fontWeight: FontWeight.bold),
            content: AppText(
              "You already have a pending price increase request for ${_controller.pendingRequest['price_type']?.toString().toUpperCase()}.",
              fontSize: 14,
            ),
            actions: [
              TextButton(
                onPressed: () => Get.back(),
                child: const Text("OK"),
              )
            ],
          )
        );
      } else {
        Get.dialog(
          AlertDialog(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            title: const AppText("Not Eligible", fontSize: 18, fontWeight: FontWeight.bold),
            content: const AppText(
              "You are not eligible for a price increase yet. Please meet the busy time criteria first.",
              fontSize: 14,
            ),
            actions: [
              TextButton(
                onPressed: () => Get.back(),
                child: const Text("OK"),
              )
            ],
          )
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9F9F9),
      appBar: CustomAppBar(
        title: 'Price Increase Request',
        actions: [
          IconButton(
            onPressed: () => Get.to(() => const PriceIncreaseHistoryScreen()),
            icon: const Icon(Iconsax.clock_copy, color: Color(0xFF2E1A47), size: 22),
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
          chatRate = double.tryParse(_controller.currentRates['chat_rate_per_minute']?.toString() ?? '')?.toStringAsFixed(0) ?? '15';
          callRate = double.tryParse(_controller.currentRates['call_rate_per_minute']?.toString() ?? '')?.toStringAsFixed(0) ?? '20';
        } else {
          try {
            final authController = Get.find<AuthController>();
            final astrologer = authController.currentUser.value?.astrologer;
            if (astrologer != null) {
              chatRate = double.tryParse(astrologer.chatRate)?.toStringAsFixed(0) ?? astrologer.chatRate;
              callRate = double.tryParse(astrologer.callRate)?.toStringAsFixed(0) ?? astrologer.callRate;
              videoRate = double.tryParse(astrologer.videoCallRate)?.toStringAsFixed(0) ?? astrologer.videoCallRate;
            }
          } catch (_) {}
        }

        // Get level/criteria values
        final totalBusy = _controller.totalBusyMinutes.value;
        final currentReq = _controller.currentLevel['required_busy_minutes'] != null
            ? double.tryParse(_controller.currentLevel['required_busy_minutes'].toString()) ?? 0.0
            : 0.0;
        final nextReq = _controller.nextLevel['required_busy_minutes'] != null
            ? double.tryParse(_controller.nextLevel['required_busy_minutes'].toString()) ?? 0.0
            : 0.0;
        
        final maxIncrease = _controller.currentLevel['max_increase_amount'] != null
            ? double.tryParse(_controller.currentLevel['max_increase_amount'].toString()) ?? 1.0
            : 1.0;

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
                  'Consultation Rates',
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: const Color(0xFF2E1A47),
                ),
                const SizedBox(height: 8),
                AppText(
                  'Set your per-minute charges for different consultation modes.',
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
                        const Icon(Icons.info_rounded, color: Colors.amber, size: 22),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const AppText(
                                'Price Increase Request Pending',
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF855B00),
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
                  title: 'Chat Rate',
                  rate: chatRate,
                  iconColor: const Color(0xFF2196F3),
                  backgroundColor: const Color(0xFFE3F2FD),
                  onTap: () => _handlePriceCardTap('chat'),
                  showEditIcon: _controller.canRequestMap['chat'] == true,
                ),
                
                _buildPriceCard(
                  icon: Iconsax.call_copy,
                  title: 'Call Rate',
                  rate: callRate,
                  iconColor: const Color(0xFF4CAF50),
                  backgroundColor: const Color(0xFFE8F5E9),
                  onTap: () => _handlePriceCardTap('call'),
                  showEditIcon: _controller.canRequestMap['call'] == true,
                ),
                
                _buildPriceCard(
                  icon: Iconsax.video_copy,
                  title: 'Video Rate',
                  rate: videoRate,
                  iconColor: AppColors.primaryColor,
                  backgroundColor: AppColors.primaryColor.withOpacity(0.1),
                  onTap: () {
                    Get.snackbar("Video Rate Update", "Video price increase request is not supported yet.");
                  },
                  showEditIcon: false,
                ),
                
                const SizedBox(height: 32),
                
                // Price Increase Criteria Section
                AppText(
                  'Price Increase Criteria',
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
                        child: const Row(
                          children: [
                            Expanded(child: Center(child: AppText('My Busy Time', fontSize: 13, fontWeight: FontWeight.w600, color: Color(0xFF2E1A47)))),
                            Expanded(child: Center(child: AppText('Required Time', fontSize: 13, fontWeight: FontWeight.w600, color: Color(0xFF2E1A47)))),
                            Expanded(child: Center(child: AppText('Price Increase', fontSize: 13, fontWeight: FontWeight.w600, color: Color(0xFF2E1A47)))),
                          ],
                        ),
                      ),
                      const Divider(height: 1, color: Color(0xFFF0F0F0)),
                      // Table Data
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 20),
                        child: Row(
                          children: [
                            Expanded(child: Center(child: AppText('${totalBusy.toStringAsFixed(0)} mins', fontSize: 15, fontWeight: FontWeight.w500, color: Colors.grey.shade700))),
                            Expanded(child: Center(child: AppText('${targetRequired.toStringAsFixed(0)} mins', fontSize: 15, fontWeight: FontWeight.w500, color: Colors.grey.shade700))),
                            Expanded(
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  AppText('₹${maxIncrease.toStringAsFixed(0)} ', fontSize: 15, fontWeight: FontWeight.w500, color: const Color(0xFF2E1A47)),
                                  Container(
                                    decoration: const BoxDecoration(color: Colors.green, shape: BoxShape.circle),
                                    child: const Icon(Icons.arrow_upward_rounded, color: Colors.white, size: 14),
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
                        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                        decoration: BoxDecoration(
                          color: diff > 0 ? const Color(0xFFFFF9E6) : const Color(0xFFF1FDF5),
                          borderRadius: const BorderRadius.only(
                            bottomLeft: Radius.circular(20),
                            bottomRight: Radius.circular(20),
                          ),
                        ),
                        child: Center(
                          child: AppText(
                            diff > 0
                                ? 'Only ${diff.toStringAsFixed(0)} mins more to be eligible for price increase.'
                                : 'You are eligible for a price increase request!',
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: diff > 0 ? const Color(0xFF855B00) : const Color(0xFF1B5E20),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 32),
                
                // Terms & Conditions Section
                AppText(
                  'Terms & Conditions',
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
                        text: 'You can increase your price based on level thresholds and performance parameters.',
                      ),
                      const SizedBox(height: 20),
                      _buildTermItem(
                        icon: Iconsax.status_up_copy,
                        color: Colors.red.shade50.withOpacity(0.5),
                        text: 'Price increase offers will be applied on your profile after admin review.',
                      ),
                      const SizedBox(height: 20),
                      _buildTermItem(
                        icon: Iconsax.clock_copy,
                        color: Colors.red.shade50.withOpacity(0.5),
                        text: 'If you don’t want to increase your price now, you can do it later — once your profile meets the required parameters.',
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                const AppText(
                  '**Other normalised parameters are also considered.',
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

  Widget _buildTermItem({required IconData icon, required Color color, required String text}) {
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
                            '/ min',
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
                    child: Icon(Icons.edit_rounded, color: Colors.grey.shade400, size: 18),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
