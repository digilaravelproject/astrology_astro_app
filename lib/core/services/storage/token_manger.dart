import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:astro_astrologer/core/constants/app_constants.dart';

class TokenManager {
  static const _secureStorage = FlutterSecureStorage(
    aOptions: AndroidOptions(
      encryptedSharedPreferences: true,
      resetOnError: true,
    ),
    iOptions: IOSOptions(
      accessibility: KeychainAccessibility.first_unlock,
    ),
  );

  static Future<String> getToken() async {
    try {
      return await _secureStorage.read(key: AppConstants.token) ?? '';
    } catch (e) {
      try {
        await _secureStorage.deleteAll();
      } catch (_) {}
      return '';
    }
  }

  static Future<void> saveToken(String token) async {
    try {
      await _secureStorage.write(key: AppConstants.token, value: token);
    } catch (e) {
      try {
        await _secureStorage.deleteAll();
        await _secureStorage.write(key: AppConstants.token, value: token);
      } catch (_) {}
    }
  }

  static Future<void> clearToken() async {
    try {
      await _secureStorage.delete(key: AppConstants.token);
    } catch (_) {
      try {
        await _secureStorage.deleteAll();
      } catch (_) {}
    }
  }
}
