import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../model/skill_model.dart';
import '../../../core/utils/custom_snackbar.dart';
import '../usecase/skill_usecase.dart';

/*
class AstrologerSkillsController extends GetxController {
  final UpdateAstrologerSkillsUseCase _updateUseCase;
  AstrologerSkillsController(this._updateUseCase);

  final isLoading = false.obs;

  Future<void> updateSkills(AstrologerSkillsModel skills) async {
    try {
      isLoading.value = true;
      final response = await _updateUseCase.execute(skills);

      if (response.isSuccess) {
        CustomSnackBar.showSuccess('Skills updated successfully');
      } else {
        CustomSnackBar.showError(response.message);
      }
    } catch (e) {
      CustomSnackBar.showError(e.toString());
    } finally {
      isLoading.value = false;
    }
  }
}*/





class AstrologerSkillsController extends GetxController {
  final UpdateAstrologerSkillsUseCase _updateUseCase;
  AstrologerSkillsController(this._updateUseCase);

  // Static lists for selection
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
  var experienceYears = ''.obs;
  var dailyContributionHours = ''.obs;
  var heardAbout = ''.obs;

  var isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    // TODO: Fetch API data if needed and fill observables
    fetchProfileSkills();
  }

  void fetchProfileSkills() async {
    isLoading.value = true;
    try {
      // For now, mock API response mapping
      // Replace with API fetch later
      selectedCategories.value = ['Finance & Business'];
      selectedPrimarySkills.value = ['Palmistry'];
      selectedAllSkills.value = ['Prashana'];
      selectedLanguages.value = ['Hindi'];
      experienceYears.value = '5';
      dailyContributionHours.value = '10';
      heardAbout.value = 'Youtube';
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> updateSkills() async {
    isLoading.value = true;
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
        CustomSnackBar.showSuccess('Skills updated successfully');
      } else {
        CustomSnackBar.showError(response.message);
      }
    } catch (e) {
      CustomSnackBar.showError(e.toString());
    } finally {
      isLoading.value = false;
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
                Text('Select $title', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w800)),
                const SizedBox(height: 16),
                Container(
                  height: 50,
                  decoration: BoxDecoration(color: Colors.grey.shade50, borderRadius: BorderRadius.circular(15), border: Border.all(color: Colors.grey.shade200)),
                  child: TextField(
                    onChanged: (val) => setModalState(() => searchQuery = val),
                    decoration: InputDecoration(
                      hintText: 'Search $title...',
                      prefixIcon: const Icon(Icons.search),
                      suffixIcon: searchQuery.isNotEmpty
                          ? IconButton(icon: const Icon(Icons.close), onPressed: () => setModalState(() => searchQuery = ''))
                          : null,
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                Expanded(
                  child: filteredOptions.isEmpty
                      ? const Center(child: Text('No results found'))
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
                              color: isSelected ? Colors.blue.withOpacity(0.1) : Colors.white,
                              borderRadius: BorderRadius.circular(100),
                              border: Border.all(color: isSelected ? Colors.blue : Colors.grey.shade300, width: 1.5),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(option, style: TextStyle(fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500)),
                                if (isSelected) const SizedBox(width: 8),
                                if (isSelected) const Icon(Icons.check_circle, size: 16, color: Colors.blue),
                              ],
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: () {
                    currentValues.value = tempSelected;
                    Get.back();
                  },
                  child: const Text('Save Selection'),
                ),
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
              Text('Edit $title', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w800)),
              const SizedBox(height: 20),
              TextField(
                controller: controller,
                keyboardType: keyboardType,
                autofocus: true,
                decoration: InputDecoration(
                  hintText: 'Enter $title',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 15),
                ),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () {
                  currentValue.value = controller.text;
                  Get.back();
                },
                child: const Text('Save Changes'),
              ),
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
            Text('Select $title', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w800)),
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
                    onTap: () {
                      currentValue.value = option;
                      Get.back();
                    },
                    borderRadius: BorderRadius.circular(12),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                      decoration: BoxDecoration(
                        color: isSelected ? Colors.blue.withOpacity(0.05) : Colors.grey.shade50,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: isSelected ? Colors.blue : Colors.grey.shade200),
                      ),
                      child: Row(
                        children: [
                          Expanded(child: Text(option, style: TextStyle(fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400))),
                          if (isSelected) const Icon(Icons.check_circle, color: Colors.blue, size: 20),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

}
