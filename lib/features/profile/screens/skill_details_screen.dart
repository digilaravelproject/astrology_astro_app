import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/app_text.dart';
import '../../../core/widgets/custom_button.dart';
import '../../../core/widgets/custom_app_bar.dart';

class SkillDetailsScreen extends StatefulWidget {
  const SkillDetailsScreen({super.key});

  @override
  State<SkillDetailsScreen> createState() => _SkillDetailsScreenState();
}

class _SkillDetailsScreenState extends State<SkillDetailsScreen> {
  // Mock state for editing
  List<String> _categories = ['Finance & Business'];
  List<String> _primarySkills = ['Palmistry'];
  List<String> _allSkillList = ['Prashana'];
  List<String> _languages = ['Hindi'];
  String _experience = '0';
  String _contributionHours = '10';
  String _heardFrom = 'Youtube';

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

  void _showMultiSelectBottomSheet({
    required String title,
    required List<String> currentValues,
    required List<String> options,
    required Function(List<String>) onSave,
  }) {
    List<String> tempSelected = List.from(currentValues);
    String searchQuery = '';
    
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) {
          final filteredOptions = options
              .where((opt) => opt.toLowerCase().contains(searchQuery.toLowerCase()))
              .toList();

          return Container(
            padding: const EdgeInsets.all(24),
            height: MediaQuery.of(context).size.height * 0.7,
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(30),
                topRight: Radius.circular(30),
              ),
            ),
            child: Column(
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
                const SizedBox(height: 16),
                Container(
                  height: 50,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade50,
                    borderRadius: BorderRadius.circular(15),
                    border: Border.all(color: Colors.grey.shade200),
                  ),
                  child: TextField(
                    onChanged: (val) => setModalState(() => searchQuery = val),
                    style: TextStyle(fontSize: 14, color: const Color(0xFF2E1A47)),
                    decoration: InputDecoration(
                      hintText: 'Search $title...',
                      prefixIcon: Icon(Iconsax.search_normal_copy, color: AppColors.primaryColor.withOpacity(0.5), size: 18),
                      suffixIcon: searchQuery.isNotEmpty 
                        ? IconButton(
                            icon: const Icon(Icons.close, size: 18),
                            onPressed: () => setModalState(() => searchQuery = ''),
                          ) 
                        : null,
                      border: InputBorder.none,
                      enabledBorder: InputBorder.none,
                      focusedBorder: InputBorder.none,
                      filled: true,
                      fillColor: Colors.transparent,
                      contentPadding: const EdgeInsets.symmetric(vertical: 14),
                      hintStyle: TextStyle(fontSize: 13, color: Colors.grey.shade400),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                Expanded(
                  child: filteredOptions.isEmpty 
                    ? Center(child: AppText('No results found', color: Colors.grey))
                    : SingleChildScrollView(
                        child: Wrap(
                          spacing: 12,
                          runSpacing: 12,
                          children: filteredOptions.map((option) {
                            final isSelected = tempSelected.contains(option);
                            return InkWell(
                              onTap: () {
                                setModalState(() {
                                  if (isSelected) {
                                    tempSelected.remove(option);
                                  } else {
                                    tempSelected.add(option);
                                  }
                                });
                              },
                              borderRadius: BorderRadius.circular(100),
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                                decoration: BoxDecoration(
                                  color: isSelected ? AppColors.primaryColor.withOpacity(0.1) : Colors.white,
                                  borderRadius: BorderRadius.circular(100),
                                  border: Border.all(
                                    color: isSelected ? AppColors.primaryColor : Colors.grey.shade300,
                                    width: 1.5,
                                  ),
                                  boxShadow: isSelected ? [
                                    BoxShadow(
                                      color: AppColors.primaryColor.withOpacity(0.1),
                                      blurRadius: 8,
                                      offset: const Offset(0, 4),
                                    )
                                  ] : null,
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    AppText(
                                      option,
                                      fontSize: 14,
                                      fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                                      color: isSelected ? AppColors.primaryColor : const Color(0xFF2E1A47),
                                    ),
                                    if (isSelected) ...[
                                      const SizedBox(width: 8),
                                      const Icon(Icons.check_circle, color: AppColors.primaryColor, size: 16),
                                    ],
                                  ],
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                      ),
                ),
                const SizedBox(height: 24),
                CustomButton(
                  text: 'Save Selection',
                  onPressed: () {
                    onSave(tempSelected);
                    Get.back();
                  },
                  backgroundColor: AppColors.primaryColor,
                  borderRadius: 100,
                ),
                const SizedBox(height: 10),
              ],
            ),
          );
        },
      ),
    );
  }

  void _showTextInputBottomSheet({
    required String title,
    required String currentValue,
    required String hint,
    required TextInputType keyboardType,
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
        title: 'Skill Details',
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionTitle('Professional Skills'),
            const SizedBox(height: 16),
            _buildSkillCard(
              icon: Iconsax.category_copy,
              label: 'Astrologer category',
              value: _categories.join(', '),
              iconColor: const Color(0xFF9C27B0),
              backgroundColor: const Color(0xFFF3E5F5),
              onTap: () => _showMultiSelectBottomSheet(
                title: 'Category',
                currentValues: _categories,
                options: ['Finance & Business', 'Relationships', 'Career', 'Health', 'Education'],
                onSave: (val) => setState(() => _categories = val),
              ),
            ),
            _buildSkillCard(
              icon: Iconsax.star_copy,
              label: 'Primary Skills',
              value: _primarySkills.join(', '),
              iconColor: const Color(0xFFFFC107),
              backgroundColor: const Color(0xFFFFF8E1),
              onTap: () => _showMultiSelectBottomSheet(
                title: 'Primary Skills',
                currentValues: _primarySkills,
                options: ['Palmistry', 'Vedic Astrology', 'Numerology', 'Tarot Reading', 'Vastu', 'Nadi', 'Psychology'],
                onSave: (val) => setState(() => _primarySkills = val),
              ),
            ),
            _buildSkillCard(
              icon: Iconsax.cpu_copy,
              label: 'All Skills',
              value: _allSkillList.join(', '),
              iconColor: const Color(0xFF4CAF50),
              backgroundColor: const Color(0xFFE8F5E9),
              onTap: () => _showMultiSelectBottomSheet(
                title: 'Skill',
                currentValues: _allSkillList,
                options: ['Prashana', 'Face Reading', 'KP Astrology', 'Horary'],
                onSave: (val) => setState(() => _allSkillList = val),
              ),
            ),
            _buildSkillCard(
              icon: Iconsax.global_copy,
              label: 'Language',
              value: _languages.join(', '),
              iconColor: const Color(0xFF2196F3),
              backgroundColor: const Color(0xFFE3F2FD),
              onTap: () => _showMultiSelectBottomSheet(
                title: 'Language',
                currentValues: _languages,
                options: ['Hindi', 'English', 'Marathi', 'Gujarati', 'Tamil', 'Telugu'],
                onSave: (val) => setState(() => _languages = val),
              ),
            ),
            _buildSkillCard(
              icon: Iconsax.briefcase_copy,
              label: 'Experience In Years',
              value: _experience,
              iconColor: const Color(0xFFFF9800),
              backgroundColor: const Color(0xFFFFF3E0),
              onTap: () => _showTextInputBottomSheet(
                title: 'Experience',
                currentValue: _experience,
                hint: 'Enter years of experience',
                keyboardType: TextInputType.number,
                onSave: (val) => setState(() => _experience = val),
              ),
            ),
            
            const SizedBox(height: 32),
            _buildSectionTitle('Additional Information'),
            const SizedBox(height: 16),
            _buildSkillCard(
              icon: Iconsax.clock_copy,
              label: 'Daily Contribution Hours',
              value: _contributionHours,
              iconColor: const Color(0xFF009688),
              backgroundColor: const Color(0xFFE0F2F1),
              onTap: () => _showTextInputBottomSheet(
                title: 'Contribution Hours',
                currentValue: _contributionHours,
                hint: 'Enter average daily hours',
                keyboardType: TextInputType.number,
                onSave: (val) => setState(() => _contributionHours = val),
              ),
            ),
            _buildSkillCard(
              icon: Iconsax.info_circle_copy,
              label: 'How did you hear about us?',
              value: _heardFrom,
              iconColor: const Color(0xFF3F51B5),
              backgroundColor: const Color(0xFFE8EAF6),
              onTap: () => _showEditBottomSheet(
                title: 'Source',
                currentValue: _heardFrom,
                options: ['Youtube', 'Facebook', 'Instagram', 'Friend Referral', 'Google Ad'],
                onSelect: (val) => setState(() => _heardFrom = val),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return AppText(
      title,
      fontSize: 18,
      fontWeight: FontWeight.w800,
      color: const Color(0xFF2E1A47),
    );
  }

  Widget _buildSkillCard({
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
                        maxLines: 2,
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
