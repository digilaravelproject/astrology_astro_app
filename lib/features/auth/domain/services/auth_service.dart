import 'package:astro_astrologer/core/services/storage/token_manger.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/services/storage/shared_prefs.dart';
import '../../../../core/services/network/response_model.dart';
import 'dart:io';
import '../models/user_model.dart';
import '../repositories/auth_repository.dart';
import 'auth_service_interface.dart';

class AuthService implements AuthServiceInterface {
  final AuthRepository _authRepository;

  AuthService(this._authRepository);

  @override
  Future<ResponseModel> signup(String name, String mobile) async {
    return await _authRepository.signup(name, mobile);
  }

  @override
  Future<ResponseModel> astrologerSignup(Map<String, dynamic> data) async {
    final response = await _authRepository.astrologerSignup(data);
    if (response.isSuccess && response.body != null) {
      final userData = response.body['user'];
      if (userData != null) {
        final user = UserModel.fromJson(userData);
        await saveUserInfo(user);
        await SharedPrefs.setBool(AppConstants.isLoggedIn, true);
      }
      if (response.token != null) {
        await saveUserToken(response.token!);
      }
    }
    return response;
  }

  @override
  Future<ResponseModel> login(String mobile) async {
    return await _authRepository.login(mobile);
  }

  @override
  Future<ResponseModel> verifyOtp(String mobile, String otp) async {
    final response = await _authRepository.verifyOtp(mobile, otp);
    if (response.isSuccess && response.body != null) {
      final userData = response.body['user'];
      if (userData != null) {
        final user = UserModel.fromJson(userData);
        await saveUserInfo(user);
        await SharedPrefs.setBool(AppConstants.isLoggedIn, true);
      }
      if (response.token != null) {
        await saveUserToken(response.token!);
      }
    }
    return response;
  }

  @override
  Future<ResponseModel> sendOtp(String mobile, String otp) async {
    return await _authRepository.sendOtp(mobile, otp);
  }

  @override
  Future<ResponseModel> resendOtp(String mobile, String otp) async {
    return await _authRepository.resendOtp(mobile, otp);
  }

  @override
  Future<ResponseModel> updateProfilePhoto(File image) async {
    final response = await _authRepository.updateProfilePhoto(image);
    if (response.isSuccess && response.body != null) {
      final user = UserModel.fromJson(response.body['user']);
      await saveUserInfo(user);
    }
    return response;
  }

  @override
  Future<ResponseModel> updateProfile(Map<String, dynamic> data) async {
    final response = await _authRepository.updateProfile(data);
    if (response.isSuccess && response.body != null) {
      final user = UserModel.fromJson(response.body['user']);
      await saveUserInfo(user);
    }
    return response;
  }

  @override
  Future<void> saveUserInfo(UserModel user) async {
    await SharedPrefs.setString(AppConstants.userData, user.toJsonString());
  }

  @override
  Future<void> saveUserToken(String userToken) async {
    await TokenManager.saveToken(userToken);
  }

  @override
  Future<void> clearUserInfo() async {
    await SharedPrefs.remove(AppConstants.userData);
    await TokenManager.clearToken();
    await SharedPrefs.setBool(AppConstants.isLoggedIn, false);
  }

  @override
  Future<bool> isLoggedIn() async {
    return SharedPrefs.getBool(AppConstants.isLoggedIn) ?? false;
  }

  @override
  Future<UserModel?> getUserInfo() async {
    final userJsonString = SharedPrefs.getString(AppConstants.userData);
    if (userJsonString == null || userJsonString.isEmpty) {
      return null;
    }
    return UserModel.fromJsonString(userJsonString);
  }

  @override
  Future<void> saveMobile(String mobile) async {
    await SharedPrefs.setString('last_mobile', mobile);
  }

  @override
  String? getMobile() {
    return SharedPrefs.getString('last_mobile');
  }

  @override
  Future<ResponseModel> getProfile(int id) async {
    final response = await _authRepository.getProfile(id);
    if (response.isSuccess && response.body != null) {
      final userData = response.body['user'];
      if (userData != null) {
        final user = UserModel.fromJson(userData);
        await saveUserInfo(user);
      }
    }
    return response;
  }

  @override
  Future<ResponseModel> logout() async {
    final response = await _authRepository.logout();
    if (response.isSuccess) {
      await clearUserInfo();
    }
    return response;
  }

  @override
  Future<ResponseModel> deleteAccount() async {
    final response = await _authRepository.deleteAccount();
    if (response.isSuccess) {
      await clearUserInfo();
    }
    return response;
  }
}