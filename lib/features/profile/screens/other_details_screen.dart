import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/app_text.dart';
import '../../../core/widgets/custom_button.dart';
import '../../../core/widgets/custom_app_bar.dart';

class OtherDetailsScreen extends StatefulWidget {
  const OtherDetailsScreen({super.key});

  @override
  State<OtherDetailsScreen> createState() => _OtherDetailsScreenState();
}

class _OtherDetailsScreenState extends State<OtherDetailsScreen> {
  // Mock state for editing
  String _dob = '15 May 1990';
  String _gender = 'Male';
  String _address = '123 Astrology Lane, Cosmic City';
  String _bio = 'Passionate astrologer with over 10 years of experience in Vedic and Palmistry. Helping people find their path through celestial guidance.';
  String _website = 'www.starguide.com';
  String _instagram = '@starguide_official';

  void _showEditBottomSheet({
    required String title,
    required String currentValue,
    required List<String> options,
    required Function(String) onSelect,
  }) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => Container(
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
            AppText(
              'Select $title',
              fontSize: 20,
              fontWeight: FontWeight.w800,
              color: const Color(0xFF2E1A47),
            ),
            const SizedBox(height: 20),
            Flexible(
              child: ListView.separated(
                shrinkWrap: true,
                itemCount: options.length,
                separatorBuilder: (context, index) => const SizedBox(height: 8),
                itemBuilder: (context, index) {
                  final option = options[index];
                  final isSelected = option == currentValue;
                  return InkWell(
                    onTap: () {
                      onSelect(option);
                      Get.back();
                    },
                    borderRadius: BorderRadius.circular(12),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                      decoration: BoxDecoration(
                        color: isSelected ? AppColors.primaryColor.withOpacity(0.05) : Colors.grey.shade50,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: isSelected ? AppColors.primaryColor : Colors.grey.shade200,
                        ),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: AppText(
                              option,
                              fontSize: 14,
                              fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                              color: isSelected ? AppColors.primaryColor : const Color(0xFF2E1A47),
                            ),
                          ),
                          if (isSelected)
                            const Icon(Icons.check_circle, color: AppColors.primaryColor, size: 20),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  void _showTextInputBottomSheet({
    required String title,
    required String currentValue,
    required String hint,
    required TextInputType keyboardType,
    int maxLines = 1,
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
              AppText(
                'Edit $title',
                fontSize: 20,
                fontWeight: FontWeight.w800,
                color: const Color(0xFF2E1A47),
              ),
              const SizedBox(height: 20),
              Container(
                decoration: BoxDecoration(
                  color: Colors.grey.shade50,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: Colors.grey.shade200),
                ),
                child: TextField(
                  controller: controller,
                  keyboardType: keyboardType,
                  maxLines: maxLines,
                  autofocus: true,
                  style: TextStyle(fontSize: 14, color: const Color(0xFF2E1A47)),
                  decoration: InputDecoration(
                    hintText: hint,
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 15),
                    hintStyle: TextStyle(fontSize: 13, color: Colors.grey.shade400),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              CustomButton(
                text: 'Save Changes',
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
      appBar: const CustomAppBar(
        title: 'Other Details',
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionTitle('Personal Information'),
            const SizedBox(height: 16),
            _buildDetailCard(
              icon: Iconsax.calendar_1_copy,
              label: 'Date of Birth',
              value: _dob,
              iconColor: const Color(0xFF2196F3),
              backgroundColor: const Color(0xFFE3F2FD),
              onTap: () async {
                final date = await showDatePicker(
                  context: context,
                  initialDate: DateTime.now(),
                  firstDate: DateTime(1950),
                  lastDate: DateTime.now(),
                );
                if (date != null) {
                  setState(() => _dob = "${date.day} ${_getMonthName(date.month)} ${date.year}");
                }
              },
            ),
            _buildDetailCard(
              icon: Iconsax.user_copy,
              label: 'Gender',
              value: _gender,
              iconColor: AppColors.primaryColor,
              backgroundColor: AppColors.primaryColor.withOpacity(0.1),
              onTap: () => _showEditBottomSheet(
                title: 'Gender',
                currentValue: _gender,
                options: ['Male', 'Female', 'Other'],
                onSelect: (val) => setState(() => _gender = val),
              ),
            ),
            _buildDetailCard(
              icon: Iconsax.location_copy,
              label: 'Current Address',
              value: _address,
              iconColor: const Color(0xFF4CAF50),
              backgroundColor: const Color(0xFFE8F5E9),
              onTap: () => _showTextInputBottomSheet(
                title: 'Address',
                currentValue: _address,
                hint: 'Enter your current address',
                keyboardType: TextInputType.streetAddress,
                onSave: (val) => setState(() => _address = val),
              ),
            ),

            const SizedBox(height: 32),
            _buildSectionTitle('Professional Bio'),
            const SizedBox(height: 16),
            _buildDetailCard(
              icon: Iconsax.document_text_copy,
              label: 'Biography',
              value: _bio,
              iconColor: const Color(0xFF9C27B0),
              backgroundColor: const Color(0xFFF3E5F5),
              onTap: () => _showTextInputBottomSheet(
                title: 'Bio',
                currentValue: _bio,
                hint: 'Write a brief biography...',
                keyboardType: TextInputType.multiline,
                maxLines: 5,
                onSave: (val) => setState(() => _bio = val),
              ),
            ),

            const SizedBox(height: 32),
            _buildSectionTitle('Social Presence'),
            const SizedBox(height: 16),
            _buildDetailCard(
              icon: Iconsax.global_copy,
              label: 'Website Link',
              value: _website,
              iconColor: const Color(0xFFFF9800),
              backgroundColor: const Color(0xFFFFF3E0),
              onTap: () => _showTextInputBottomSheet(
                title: 'Website',
                currentValue: _website,
                hint: 'Enter website URL',
                keyboardType: TextInputType.url,
                onSave: (val) => setState(() => _website = val),
              ),
            ),
            _buildDetailCard(
              icon: Iconsax.instagram_copy,
              label: 'Instagram Username',
              value: _instagram,
              iconColor: const Color(0xFF673AB7),
              backgroundColor: const Color(0xFFEDE7F6),
              onTap: () => _showTextInputBottomSheet(
                title: 'Instagram',
                currentValue: _instagram,
                hint: 'Enter Instagram handle',
                keyboardType: TextInputType.text,
                onSave: (val) => setState(() => _instagram = val),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _getMonthName(int month) {
    const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    return months[month - 1];
  }

  Widget _buildSectionTitle(String title) {
    return AppText(
      title,
      fontSize: 18,
      fontWeight: FontWeight.w800,
      color: const Color(0xFF2E1A47),
    );
  }

  Widget _buildDetailCard({
    required IconData icon,
    required String label,
    required String value,
    required Color iconColor,
    required Color backgroundColor,
    required VoidCallback onTap,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(20),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    color: backgroundColor,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(icon, color: iconColor, size: 24),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      AppText(
                        label,
                        fontSize: 12,
                        color: Colors.grey.shade500,
                        fontWeight: FontWeight.w500,
                      ),
                      const SizedBox(height: 4),
                      AppText(
                        value,
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFF2E1A47),
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                Icon(Icons.chevron_right_rounded, color: Colors.grey.shade400, size: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
