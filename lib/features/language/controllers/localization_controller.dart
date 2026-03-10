import 'package:astro_astrologer/core/constants/image_constants.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/services/storage/shared_prefs.dart';
import '../domain/models/language_model.dart';
import '../widget/language_bottom_sheet.dart';

class LocalizationController extends GetxController {
  final _selectedIndex = 0.obs;
  final _languages = <LanguageModel>[].obs;

  int get selectedIndex => _selectedIndex.value;
  List<LanguageModel> get languages => _languages;

  @override
  void onInit() {
    super.onInit();
    _languages.addAll([
      LanguageModel(
        imageUrl: ImageConstants.english,
        languageName: 'English',
        languageCode: 'en',
        countryCode: 'US',
      ),
      LanguageModel(
        imageUrl: ImageConstants.hindi,
        languageName: 'हिन्दी',
        languageCode: 'hi',
        countryCode: 'IN',
      ),
      LanguageModel(
        imageUrl: ImageConstants.tamil,
        languageName: 'தமிழ்',
        languageCode: 'ta',
        countryCode: 'IN',
      ),
      LanguageModel(
        imageUrl: ImageConstants.bengali,
        languageName: 'বাংলা',
        languageCode: 'bn',
        countryCode: 'IN',
      ),
      LanguageModel(
        imageUrl: ImageConstants.telugu,
        languageName: 'తెలుగు',
        languageCode: 'te',
        countryCode: 'IN',
      ),
      LanguageModel(
        imageUrl: ImageConstants.marathi,
        languageName: 'मराठी',
        languageCode: 'mr',
        countryCode: 'IN',
      ),
      LanguageModel(
        imageUrl: ImageConstants.kannada,
        languageName: 'ಕನ್ನಡ',
        languageCode: 'kn',
        countryCode: 'IN',
      ),
      LanguageModel(
        imageUrl: ImageConstants.gujarati,
        languageName: 'ગુજરાતી',
        languageCode: 'gu',
        countryCode: 'IN',
      ),
      LanguageModel(
        imageUrl: ImageConstants.malayalam,
        languageName: 'മലയാളം',
        languageCode: 'ml',
        countryCode: 'IN',
      ),
    ]);
  }

  Future<void> initLanguage() async {
    final languageCode = SharedPrefs.getString(AppConstants.language) ?? 'en';
    final index = _languages.indexWhere((element) => element.languageCode == languageCode);

    if (index != -1) {
      _selectedIndex.value = index;
      setLanguage(_languages[index]);
    }
  }

  void setLanguage(LanguageModel language) {
    final index = _languages.indexWhere((element) => element.languageCode == language.languageCode);

    if (index != -1) {
      _selectedIndex.value = index;

      Get.updateLocale(Locale(
        language.languageCode,
        language.countryCode,
      ));

      SharedPrefs.setString(AppConstants.language, language.languageCode);
    }
  }


  void showLanguageBottomSheet(BuildContext context) {
    Get.bottomSheet(
      LanguageBottomSheet(controller: this),
      isScrollControlled: true,
    );
  }
}
