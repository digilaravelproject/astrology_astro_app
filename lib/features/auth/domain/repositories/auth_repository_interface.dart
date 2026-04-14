import 'dart:io';
import '../../../../core/services/network/response_model.dart';


abstract class AuthRepositoryInterface {
  Future<ResponseModel> signup(String name, String mobile);
  Future<ResponseModel> astrologerSignup(Map<String, dynamic> data);
  Future<ResponseModel> login(String mobile);
  Future<ResponseModel> verifyOtp(String mobile, String otp);
  Future<ResponseModel> sendOtp(String mobile, String otp);
  Future<ResponseModel> resendOtp(String mobile, String otp);
  Future<ResponseModel> updateProfilePhoto(File image);
  Future<ResponseModel> updateProfile(Map<String, dynamic> data);
  Future<ResponseModel> getProfile(int id);
  Future<ResponseModel> logout();
  Future<ResponseModel> deleteAccount();
  Future<ResponseModel> toggleOnline(int isOnline, String type);
}