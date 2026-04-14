import 'dart:io';
import '../../../../core/services/network/response_model.dart';
import '../models/user_model.dart';

abstract class AuthServiceInterface {
  Future<ResponseModel> signup(String name, String mobile);
  Future<ResponseModel> astrologerSignup(Map<String, dynamic> data);
  Future<ResponseModel> login(String mobile);
  Future<ResponseModel> verifyOtp(String mobile, String otp);
  Future<ResponseModel> sendOtp(String mobile, String otp);
  Future<ResponseModel> resendOtp(String mobile, String otp);
  Future<ResponseModel> updateProfilePhoto(File image);
  Future<ResponseModel> updateProfile(Map<String, dynamic> data);
  Future<void> saveUserToken(String userToken);
  Future<void> saveUserInfo(UserModel user);
  Future<void> clearUserInfo();
  Future<bool> isLoggedIn();
  Future<UserModel?> getUserInfo();
  Future<void> saveMobile(String mobile);
  String? getMobile();
  Future<ResponseModel> getProfile(int id);
  Future<ResponseModel> logout();
  Future<ResponseModel> deleteAccount();
  Future<ResponseModel> toggleOnline(int isOnline, String type);
}
