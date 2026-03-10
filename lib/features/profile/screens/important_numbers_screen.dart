import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/app_text.dart';
import '../../../core/widgets/custom_app_bar.dart';

class ImportantNumbersScreen extends StatelessWidget {
  const ImportantNumbersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9F9F9),
      appBar: const CustomAppBar(
        title: 'Important Numbers',
      ),
      body: Column(
        children: [
          _buildHeaderBanner(),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(vertical: 8),
              children: [
                _buildContactSection(
                  title: 'AstroTalk Call',
                  numbers: [
                    '+91 11 4117 0131, +91 80 4899 5916, +91 11 4118 9042, +91 22 4896 4160, +91 80 4725 1716, +91 80 3542 5593, +91 80 3542 5594, +1 (254) 455-6027, +91 22 6971 9595, +91 12 0647 8546, +91 73 1459 9536, +1 779 901 1412, +91 86 4566 8574, +1 7866462472, +1 9713464924, +91 2269713740, +91 8041392473, +91 1204627014'
                  ],
                ),
                _buildContactSection(
                  title: 'AstroTalk Chat Alert',
                  numbers: [
                    '+911141202781, +911141187144, +918048892507, +918062358395, +912241484568, +1 7754737952'
                  ],
                ),
                _buildContactSection(
                  title: 'AstroTalk Admin Support',
                  numbers: [
                    '011-411-70134, +919606047081, +918035425595, +912248932703, +12027429462, +918645668560, +912269713774, +917316917263, +918062359119'
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeaderBanner() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      color: AppColors.lightPink,
      child: const AppText(
        'You will get call and chat alerts from these numbers. Save these numbers to avoid any confusion',
        fontSize: 12,
        color: Colors.black87,
        textAlign: TextAlign.center,
        height: 1.3,
      ),
    );
  }

  Widget _buildContactSection({required String title, required List<String> numbers}) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: AppText(title, fontSize: 16, fontWeight: FontWeight.bold, color: const Color(0xFF2E1A47), overflow: TextOverflow.ellipsis),
                  ),
                  const SizedBox(width: 8),
                  _buildAddContactButton(),
                ],
              ),
              const SizedBox(height: 8),
              AppText(
                numbers.join('\n'),
                fontSize: 13,
                color: Colors.black54,
                height: 1.5,
                letterSpacing: 0.2,
              ),
            ],
          ),
        ),
        const Divider(height: 1, thickness: 1, color: Color(0xFFF0F0F0)),
      ],
    );
  }

  Widget _buildAddContactButton() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.primaryColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.primaryColor.withOpacity(0.2)),
      ),
      child: const AppText(
        'Add Contact',
        fontSize: 11,
        fontWeight: FontWeight.bold,
        color: AppColors.primaryColor,
      ),
    );
  }
}
