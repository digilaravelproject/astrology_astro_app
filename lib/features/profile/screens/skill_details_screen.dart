import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/app_text.dart';
import '../../../core/widgets/custom_button.dart';
import '../../../core/widgets/custom_app_bar.dart';
import '../controllers/skill_controller.dart';

class SkillDetailsScreen extends StatefulWidget {
  const SkillDetailsScreen({super.key});

  @override
  State<SkillDetailsScreen> createState() => _SkillDetailsScreenState();
}

class _SkillDetailsScreenState extends State<SkillDetailsScreen> {
  final controller = Get.find<AstrologerSkillsController>();

  @override
  void initState() {
    super.initState();
    controller.refreshData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9F9F9),
      appBar: CustomAppBar(
        title: 'Skill Details',
        actions: const [
          // Obx(() => controller.isLoading.value 
          //   ? const Center(child: Padding(padding: EdgeInsets.all(16), child: SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))))
          //   : IconButton(
          //       onPressed: () => controller.updateSkills(),
          //       icon: const Icon(Icons.check_circle_outline_rounded, color: AppColors.primaryColor),
          //     )
          // ),
        ],
      ),
      body: Obx(() => SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionTitle('Professional Skills'),
            const SizedBox(height: 16),
            _buildSkillCard(
              icon: Iconsax.category_copy,
              label: 'Astrologer category',
              value: controller.selectedCategories.join(', '),
              iconColor: const Color(0xFF9C27B0),
              backgroundColor: const Color(0xFFF3E5F5),
              onTap: () => controller.showMultiSelectBottomSheet(
                title: 'Category',
                currentValues: controller.selectedCategories,
                options: controller.categories,
              ),
            ),
            _buildSkillCard(
              icon: Iconsax.star_copy,
              label: 'Primary Skills',
              value: controller.selectedPrimarySkills.join(', '),
              iconColor: const Color(0xFFFFC107),
              backgroundColor: const Color(0xFFFFF8E1),
              onTap: () => controller.showMultiSelectBottomSheet(
                title: 'Primary Skills',
                currentValues: controller.selectedPrimarySkills,
                options: controller.primarySkillsOptions,
              ),
            ),
            _buildSkillCard(
              icon: Iconsax.cpu_copy,
              label: 'All Skills',
              value: controller.selectedAllSkills.join(', '),
              iconColor: const Color(0xFF4CAF50),
              backgroundColor: const Color(0xFFE8F5E9),
              onTap: () => controller.showMultiSelectBottomSheet(
                title: 'Skill',
                currentValues: controller.selectedAllSkills,
                options: controller.allSkillsOptions,
              ),
            ),
            _buildSkillCard(
              icon: Iconsax.global_copy,
              label: 'Language',
              value: controller.selectedLanguages.join(', '),
              iconColor: const Color(0xFF2196F3),
              backgroundColor: const Color(0xFFE3F2FD),
              onTap: () => controller.showMultiSelectBottomSheet(
                title: 'Language',
                currentValues: controller.selectedLanguages,
                options: controller.languagesOptions,
              ),
            ),
            _buildSkillCard(
              icon: Iconsax.briefcase_copy,
              label: 'Experience In Years',
              value: controller.experienceYears.value,
              iconColor: const Color(0xFFFF9800),
              backgroundColor: const Color(0xFFFFF3E0),
              onTap: () => controller.showTextInputBottomSheet(
                title: 'Experience',
                currentValue: controller.experienceYears,
                keyboardType: TextInputType.number,
              ),
            ),
            
            const SizedBox(height: 32),
            _buildSectionTitle('Additional Information'),
            const SizedBox(height: 16),
            _buildSkillCard(
              icon: Iconsax.clock_copy,
              label: 'Daily Contribution Hours',
              value: controller.dailyContributionHours.value,
              iconColor: const Color(0xFF009688),
              backgroundColor: const Color(0xFFE0F2F1),
              onTap: () => controller.showTextInputBottomSheet(
                title: 'Contribution Hours',
                currentValue: controller.dailyContributionHours,
                keyboardType: TextInputType.number,
              ),
            ),
            _buildSkillCard(
              icon: Iconsax.info_circle_copy,
              label: 'How did you hear about us?',
              value: controller.heardAbout.value,
              iconColor: const Color(0xFF3F51B5),
              backgroundColor: const Color(0xFFE8EAF6),
              onTap: () => controller.showEditBottomSheet(
                title: 'Source',
                currentValue: controller.heardAbout,
                options: controller.heardAboutOptions,
              ),
            ),
            const SizedBox(height: 40),
            // Obx(() => CustomButton(
            //   text: 'Save Details',
            //   onPressed: () => controller.updateSkills(),
            //   isLoading: controller.isLoading.value,
            //   backgroundColor: AppColors.primaryColor,
            //   borderRadius: 100,
            // )),
            const SizedBox(height: 40),
          ],
        ),
      )),
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