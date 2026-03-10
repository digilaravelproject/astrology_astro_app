import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/app_text.dart';
import '../../../core/widgets/custom_button.dart';
import '../../../core/widgets/custom_app_bar.dart';
import 'price_increase_history_screen.dart';

class PriceSettingScreen extends StatefulWidget {
  const PriceSettingScreen({super.key});

  @override
  State<PriceSettingScreen> createState() => _PriceSettingScreenState();
}

class _PriceSettingScreenState extends State<PriceSettingScreen> {
  // Mock state for rates
  String _chatRate = '15';
  String _callRate = '20';
  String _videoRate = '30';

  void _showPriceEditBottomSheet({
    required String title,
    required String currentValue,
    required IconData icon,
    required Color iconColor,
    required Function(String) onSave,
  }) {
    final controller = TextEditingController(text: currentValue);
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(30),
              topRight: Radius.circular(30),
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 50,
                  height: 5,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade200,
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: iconColor.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(icon, color: iconColor, size: 20),
                  ),
                  const SizedBox(width: 12),
                  AppText(
                    'Set $title Rate',
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                    color: const Color(0xFF2E1A47),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              AppText(
                'Enter rate per minute (₹)',
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: Colors.grey.shade600,
              ),
              const SizedBox(height: 12),
              Container(
                decoration: BoxDecoration(
                  color: Colors.grey.shade50,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: Colors.grey.shade200),
                ),
                child: TextField(
                  controller: controller,
                  keyboardType: TextInputType.number,
                  autofocus: true,
                  style: TextStyle(
                    fontSize: 18, 
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF2E1A47),
                  ),
                  decoration: InputDecoration(
                    prefixIcon: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                      child: const AppText('₹', fontSize: 18, fontWeight: FontWeight.w700, color: Color(0xFF2E1A47)),
                    ),
                    suffixIcon: const Padding(
                      padding: EdgeInsets.only(right: 16, top: 15),
                      child: AppText('/ min', fontSize: 14, fontWeight: FontWeight.w500, color: Colors.grey),
                    ),
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(vertical: 15),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              AppText(
                '* Note: This rate will be applied for all new consultations.',
                fontSize: 12,
                color: Colors.grey.shade500,
                fontStyle: FontStyle.italic,
              ),
              const SizedBox(height: 32),
              CustomButton(
                text: 'Update Rate',
                onPressed: () {
                  onSave(controller.text);
                  Get.back();
                },
                backgroundColor: AppColors.primaryColor,
                borderRadius: 100,
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
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
      body: SingleChildScrollView(
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
            const SizedBox(height: 24),
            
            _buildPriceCard(
              icon: Iconsax.message_copy,
              title: 'Chat Rate',
              rate: _chatRate,
              iconColor: const Color(0xFF2196F3),
              backgroundColor: const Color(0xFFE3F2FD),
              onTap: () => _showPriceEditBottomSheet(
                title: 'Chat',
                currentValue: _chatRate,
                icon: Iconsax.message_copy,
                iconColor: const Color(0xFF2196F3),
                onSave: (val) => setState(() => _chatRate = val),
              ),
            ),
            
            _buildPriceCard(
              icon: Iconsax.call_copy,
              title: 'Call Rate',
              rate: _callRate,
              iconColor: const Color(0xFF4CAF50),
              backgroundColor: const Color(0xFFE8F5E9),
              onTap: () => _showPriceEditBottomSheet(
                title: 'Call',
                currentValue: _callRate,
                icon: Iconsax.call_copy,
                iconColor: const Color(0xFF4CAF50),
                onSave: (val) => setState(() => _callRate = val),
              ),
            ),
            
            _buildPriceCard(
              icon: Iconsax.video_copy,
              title: 'Video Rate',
              rate: _videoRate,
              iconColor: AppColors.primaryColor,
              backgroundColor: AppColors.primaryColor.withOpacity(0.1),
              onTap: () => _showPriceEditBottomSheet(
                title: 'Video',
                currentValue: _videoRate,
                icon: Iconsax.video_copy,
                iconColor: AppColors.primaryColor,
                onSave: (val) => setState(() => _videoRate = val),
              ),
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
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFF9F9),
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(20),
                        topRight: Radius.circular(20),
                      ),
                    ),
                    child: Row(
                      children: [
                        Expanded(child: Center(child: AppText('My Busy Time', fontSize: 13, fontWeight: FontWeight.w600, color: const Color(0xFF2E1A47)))),
                        Expanded(child: Center(child: AppText('Required Time', fontSize: 13, fontWeight: FontWeight.w600, color: const Color(0xFF2E1A47)))),
                        Expanded(child: Center(child: AppText('Price Increase', fontSize: 13, fontWeight: FontWeight.w600, color: const Color(0xFF2E1A47)))),
                      ],
                    ),
                  ),
                  const Divider(height: 1, color: Color(0xFFF0F0F0)),
                  // Table Data
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 20),
                    child: Row(
                      children: [
                        Expanded(child: Center(child: AppText('168 mins', fontSize: 15, fontWeight: FontWeight.w500, color: Colors.grey.shade700))),
                        Expanded(child: Center(child: AppText('300 mins', fontSize: 15, fontWeight: FontWeight.w500, color: Colors.grey.shade700))),
                        Expanded(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const AppText('₹1 ', fontSize: 15, fontWeight: FontWeight.w500, color: Color(0xFF2E1A47)),
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
                    decoration: const BoxDecoration(
                      color: Color(0xFFF1FDF5),
                      borderRadius: BorderRadius.only(
                        bottomLeft: Radius.circular(20),
                        bottomRight: Radius.circular(20),
                      ),
                    ),
                    child: Center(
                      child: AppText(
                        'Only 132 mins more to be eligible for price increase.',
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFF1B5E20),
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
                    text: 'You can increase your price by ₹1.0 in every 90 day, if your busy time for last 30 days is > 5 hours',
                  ),
                  const SizedBox(height: 20),
                  _buildTermItem(
                    icon: Iconsax.status_up_copy,
                    color: Colors.red.shade50.withOpacity(0.5),
                    text: 'Price increase offer will be applied on your profile for 30 days.',
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
          onTap: onTap,
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
