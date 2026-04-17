import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/app_text.dart';
import '../../../core/widgets/custom_button.dart';
import '../model/skill_model.dart';
import '../../../core/utils/custom_snackbar.dart';
import '../usecase/skill_usecase.dart';
import '../../auth/controllers/auth_controller.dart';
import '../../auth/domain/services/auth_service.dart';
import '../../../core/utils/logger.dart';

class AstrologerSkillsController extends GetxController {
  final UpdateAstrologerSkillsUseCase _updateUseCase;
  AstrologerSkillsController(this._updateUseCase);

  // Static lists for selection (can be moved to constants or fetched from API)
  final categories = ['Finance & Business', 'Relationships', 'Career', 'Health', 'Education'];
  final primarySkillsOptions = ['Palmistry', 'Vedic Astrology', 'Numerology', 'Tarot Reading', 'Vastu', 'Nadi', 'Psychology'];
  final allSkillsOptions = ['Prashana', 'Face Reading', 'KP Astrology', 'Horary'];
  final languagesOptions = ['Hindi', 'English', 'Marathi', 'Gujarati', 'Tamil', 'Telugu'];
  final heardAboutOptions = ['Youtube', 'Facebook', 'Instagram', 'Friend Referral', 'Google Ad'];

  // Observable form fields
  var selectedCategories = <String>[].obs;
  var selectedPrimarySkills = <String>[].obs;
  var selectedAllSkills = <String>[].obs;
  var selectedLanguages = <String>[].obs;
  var experienceYears = '0'.obs;
  var dailyContributionHours = '0'.obs;
  var heardAbout = ''.obs;

  var isLoading = false.obs;
  var isLoadingSheet = false.obs;

  @override
  void onInit() {
    super.onInit();
    refreshData();
  }

  void refreshData() {
    final authController = Get.find<AuthController>();
    final user = authController.currentUser.value;
    
    if (user != null && user.astrologer != null) {
      final ast = user.astrologer!;
      // Map existing data from AuthController
      selectedCategories.value = ast.skill?.category != null ? [ast.skill!.category] : (ast.areasOfExpertise.take(1).toList());
      selectedPrimarySkills.value = ast.skill?.primarySkills ?? ast.areasOfExpertise; 
      selectedLanguages.value = ast.skill?.languages ?? ast.languages;
      experienceYears.value = (ast.skill?.experienceYears ?? ast.yearsOfExperience).toString();
      
      // These fields now come from the nested skill object
      selectedAllSkills.value = ast.skill?.allSkills ?? ['Prashana']; 
      dailyContributionHours.value = (ast.skill?.dailyContributionHours ?? 10).toString();
      heardAbout.value = ast.skill?.heardAbout ?? 'Youtube';
      
      Logger.d('AstrologerSkillsController: Data loaded from AuthController (nested skill object)');
      Logger.d('Skills: ${selectedPrimarySkills.value}');
      Logger.d('Languages: ${selectedLanguages.value}');
      Logger.d('Experience: ${experienceYears.value}');
    }
  }

  Future<bool> updateSkills({bool isSilent = false}) async {
    Logger.d('AstrologerSkillsController: updateSkills called');
    if (!isSilent) isLoading.value = true;
    try {
      final model = AstrologerSkillsModel(
        category: selectedCategories.isNotEmpty ? selectedCategories[0] : '',
        primarySkills: selectedPrimarySkills,
        allSkills: selectedAllSkills,
        languages: selectedLanguages,
        experienceYears: int.tryParse(experienceYears.value) ?? 0,
        dailyContributionHours: int.tryParse(dailyContributionHours.value) ?? 0,
        heardAbout: heardAbout.value,
      );

      final response = await _updateUseCase.execute(model);

      if (response.isSuccess) {
        CustomSnackBar.showSuccess('Updated successfully');
        
        // Refresh profile to get updated data
        final authController = Get.find<AuthController>();
        if (authController.currentUser.value != null) {
          await authController.getProfile(authController.currentUser.value!.id);
          
          // Save updated user data to SharedPreferences
          await Get.find<AuthService>().saveUserInfo(authController.currentUser.value!);
          Logger.d('AstrologerSkillsController: Updated data saved to SharedPreferences');
        }
        return true;
      } else {
        CustomSnackBar.showError(response.message);
        return false;
      }
    } catch (e) {
      Logger.e('AstrologerSkillsController: updateSkills error: $e');
      CustomSnackBar.showError('Update failed: $e');
      return false;
    } finally {
      if (!isSilent) isLoading.value = false;
    }
  }


  void showMultiSelectBottomSheet({
    required String title,
    required RxList<String> currentValues,
    required List<String> options,
  }) {
    List<String> tempSelected = List.from(currentValues);
    String searchQuery = '';

    showModalBottomSheet(
      context: Get.context!,
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
              borderRadius: BorderRadius.only(topLeft: Radius.circular(30), topRight: Radius.circular(30)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(width: 50, height: 5, decoration: BoxDecoration(color: Colors.grey.shade200, borderRadius: BorderRadius.circular(10))),
                ),
                const SizedBox(height: 24),
                AppText('Select $title', fontSize: 20, fontWeight: FontWeight.w800, color: const Color(0xFF2E1A47)),
                const SizedBox(height: 16),
                Container(
                  height: 50,
                  decoration: BoxDecoration(color: Colors.grey.shade50, borderRadius: BorderRadius.circular(15), border: Border.all(color: Colors.grey.shade200)),
                  child: TextField(
                    onChanged: (val) => setModalState(() => searchQuery = val),
                    style: const TextStyle(fontSize: 14, color: Color(0xFF2E1A47)),
                    decoration: InputDecoration(
                      hintText: 'Search $title...',
                      prefixIcon: const Icon(Iconsax.search_normal_copy, size: 20),
                      suffixIcon: searchQuery.isNotEmpty
                          ? IconButton(icon: const Icon(Icons.close, size: 18), onPressed: () => setModalState(() => searchQuery = ''))
                          : null,
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                Expanded(
                  child: filteredOptions.isEmpty
                      ? const Center(child: AppText('No results found', color: Colors.grey))
                      : SingleChildScrollView(
                    child: Wrap(
                      spacing: 12,
                      runSpacing: 12,
                      children: filteredOptions.map((option) {
                        final isSelected = tempSelected.contains(option);
                        return InkWell(
                          onTap: () => setModalState(() => isSelected ? tempSelected.remove(option) : tempSelected.add(option)),
                          borderRadius: BorderRadius.circular(100),
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                            decoration: BoxDecoration(
                              color: isSelected ? AppColors.primaryColor.withOpacity(0.1) : Colors.white,
                              borderRadius: BorderRadius.circular(100),
                              border: Border.all(color: isSelected ? AppColors.primaryColor : Colors.grey.shade300, width: 1.5),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                AppText(option, fontSize: 14, fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500, color: isSelected ? AppColors.primaryColor : const Color(0xFF2E1A47)),
                                if (isSelected) ...[
                                  const SizedBox(width: 8),
                                  const Icon(Icons.check_circle, size: 16, color: AppColors.primaryColor),
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
                Obx(() => CustomButton(
                  text: 'Save Selection',
                  onPressed: () async {
                    isLoadingSheet.value = true;
                    // Update the value temporarily to send to API
                    final oldValues = List<String>.from(currentValues);
                    currentValues.value = tempSelected;
                    
                    final success = await updateSkills(isSilent: true);
                    
                    isLoadingSheet.value = false;
                    if (success) {
                      Navigator.pop(Get.context!);
                    } else {
                      // Revert if failed
                      currentValues.value = oldValues;
                    }
                  },
                  isLoading: isLoadingSheet.value,
                  backgroundColor: AppColors.primaryColor,
                  borderRadius: 100,
                )),
                const SizedBox(height: 10),
              ],
            ),
          );
        },
      ),
    );
  }


  void showTextInputBottomSheet({
    required String title,
    required RxString currentValue,
    required TextInputType keyboardType,
  }) {
    final controller = TextEditingController(text: currentValue.value);

    showModalBottomSheet(
      context: Get.context!,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: const BoxDecoration(color: Colors.white, borderRadius: BorderRadius.only(topLeft: Radius.circular(30), topRight: Radius.circular(30))),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(width: 50, height: 5, decoration: BoxDecoration(color: Colors.grey.shade200, borderRadius: BorderRadius.circular(10))),
              ),
              const SizedBox(height: 24),
              AppText('Edit $title', fontSize: 20, fontWeight: FontWeight.w800, color: const Color(0xFF2E1A47)),
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
                  style: const TextStyle(fontSize: 14, color: Color(0xFF2E1A47)),
                  decoration: InputDecoration(
                    hintText: 'Enter $title',
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 15),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              Obx(() => CustomButton(
                text: 'Save Changes',
                onPressed: () async {
                  isLoadingSheet.value = true;
                  final oldValue = currentValue.value;
                  currentValue.value = controller.text;
                  
                  final success = await updateSkills(isSilent: true);
                  
                  isLoadingSheet.value = false;
                  if (success) {
                    Navigator.pop(Get.context!);
                  } else {
                    currentValue.value = oldValue;
                  }
                },
                isLoading: isLoadingSheet.value,
                backgroundColor: AppColors.primaryColor,
                borderRadius: 100,
              )),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }


  void showEditBottomSheet({
    required String title,
    required RxString currentValue,
    required List<String> options,
  }) {
    showModalBottomSheet(
      context: Get.context!,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => Container(
        padding: const EdgeInsets.all(24),
        decoration: const BoxDecoration(color: Colors.white, borderRadius: BorderRadius.only(topLeft: Radius.circular(30), topRight: Radius.circular(30))),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(child: Container(width: 50, height: 5, decoration: BoxDecoration(color: Colors.grey.shade200, borderRadius: BorderRadius.circular(10)))),
            const SizedBox(height: 24),
            AppText('Select $title', fontSize: 20, fontWeight: FontWeight.w800, color: const Color(0xFF2E1A47)),
            const SizedBox(height: 20),
            Flexible(
              child: ListView.separated(
                shrinkWrap: true,
                itemCount: options.length,
                separatorBuilder: (_, __) => const SizedBox(height: 8),
                itemBuilder: (context, index) {
                  final option = options[index];
                  final isSelected = option == currentValue.value;
                  return InkWell(
                    onTap: () async {
                      isLoadingSheet.value = true;
                      final oldValue = currentValue.value;
                      currentValue.value = option;
                      
                      final success = await updateSkills(isSilent: true);
                      
                      isLoadingSheet.value = false;
                      if (success) {
                        Navigator.pop(Get.context!);
                      } else {
                        currentValue.value = oldValue;
                      }
                    },
                    borderRadius: BorderRadius.circular(12),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                      decoration: BoxDecoration(
                        color: isSelected ? AppColors.primaryColor.withOpacity(0.05) : Colors.grey.shade50,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: isSelected ? AppColors.primaryColor : Colors.grey.shade200),
                      ),
                      child: Row(
                        children: [
                          Expanded(child: AppText(option, fontSize: 14, fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400, color: isSelected ? AppColors.primaryColor : const Color(0xFF2E1A47))),
                          if (isSelected) const Icon(Icons.check_circle, color: AppColors.primaryColor, size: 20),
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

}
