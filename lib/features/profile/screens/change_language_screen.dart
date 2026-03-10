import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/app_text.dart';
import '../../../core/widgets/custom_button.dart';
import '../../../core/widgets/custom_app_bar.dart';
import '../../language/controllers/localization_controller.dart';
import '../../language/domain/models/language_model.dart';

class ChangeLanguageScreen extends StatefulWidget {
  const ChangeLanguageScreen({super.key});

  @override
  State<ChangeLanguageScreen> createState() => _ChangeLanguageScreenState();
}

class _ChangeLanguageScreenState extends State<ChangeLanguageScreen> {
  final LocalizationController _localizationController = Get.find<LocalizationController>();
  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    _selectedIndex = _localizationController.selectedIndex;
  }

  @override
  Widget build(BuildContext context) {
    final languages = _localizationController.languages;
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: const CustomAppBar(
        title: 'Change Language',
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.separated(
              padding: const EdgeInsets.all(24),
              itemCount: languages.length,
              separatorBuilder: (context, index) => const SizedBox(height: 16),
              itemBuilder: (context, index) {
                final lang = languages[index];
                final isSelected = _selectedIndex == index;
                
                return GestureDetector(
                  onTap: () {
                    setState(() {
                      _selectedIndex = index;
                    });
                  },
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: isSelected ? AppColors.primaryColor.withOpacity(0.05) : Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: isSelected ? AppColors.primaryColor : Colors.grey.shade200,
                        width: isSelected ? 1.5 : 1,
                      ),
                    ),
                    child: Row(
                      children: [
                        CircleAvatar(
                          radius: 20,
                          backgroundColor: isSelected ? AppColors.primaryColor : Colors.grey.shade50,
                          child: AppText(
                            lang.languageName.substring(0, 1),
                            fontSize: 16,
                            color: isSelected ? Colors.white : Colors.black54,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            AppText(
                              lang.languageName,
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                              color: const Color(0xFF2E1A47),
                            ),
                            AppText(
                              '${lang.languageCode.toUpperCase()}_${lang.countryCode}',
                              fontSize: 11,
                              fontWeight: FontWeight.w500,
                              color: Colors.grey.shade400,
                            ),
                          ],
                        ),
                        const Spacer(),
                        if (isSelected)
                          Icon(Icons.check_circle_rounded, color: AppColors.primaryColor, size: 24)
                        else
                          Icon(Icons.radio_button_off_rounded, color: Colors.grey.shade300, size: 24),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(24),
            child: CustomButton(
              text: 'Save Changes',
              onPressed: () {
                _localizationController.setLanguage(languages[_selectedIndex]);
                
                Get.snackbar(
                  'Success', 
                  "Language changed to ${languages[_selectedIndex].languageName}", 
                  backgroundColor: Colors.green.withOpacity(0.1),
                  colorText: Colors.green,
                  snackPosition: SnackPosition.BOTTOM,
                  margin: const EdgeInsets.all(20),
                  duration: const Duration(seconds: 2),
                );
                
                Get.back();
              },
            ),
          ),
          const SizedBox(height: 12),
        ],
      ),
    );
  }
}
