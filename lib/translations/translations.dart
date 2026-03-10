// lib/translations/translations.dart
import 'package:get/get.dart';
import '../core/services/translations/translation_loader.dart';

class AppTranslations extends Translations {
  // Internal data store
  final Map<String, Map<String, String>> _translations = {};

  // Override the keys getter to return our loaded translations
  @override
  Map<String, Map<String, String>> get keys => _translations;

  // Load translations dynamically
  static Future<AppTranslations> load() async {
    final instance = AppTranslations();

    // Load translations for each supported locale
    final enUS = await TranslationLoader.load('en_US');
    final hiIN = await TranslationLoader.load('hi_IN');
    final taIN = await TranslationLoader.load('ta_IN');
    final bnIN = await TranslationLoader.load('bn_IN');
    final teIN = await TranslationLoader.load('te_IN');
    final mrIN = await TranslationLoader.load('mr_IN');
    final knIN = await TranslationLoader.load('kn_IN');
    final guIN = await TranslationLoader.load('gu_IN');
    final mlIN = await TranslationLoader.load('ml_IN');

    // Add translations to our internal map
    instance._translations.addAll({
      'en_US': enUS,
      'hi_IN': hiIN,
      'ta_IN': taIN,
      'bn_IN': bnIN,
      'te_IN': teIN,
      'mr_IN': mrIN,
      'kn_IN': knIN,
      'gu_IN': guIN,
      'ml_IN': mlIN,
    });

    return instance;
  }
}

