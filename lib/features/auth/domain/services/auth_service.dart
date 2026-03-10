import 'package:astro_astrologer/core/services/storage/token_manger.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/services/storage/shared_prefs.dart';
import '../../../../core/services/network/response_model.dart';
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
  Future<ResponseModel> login(String mobile) async {
    return await _authRepository.login(mobile);
  }

  @override
  Future<ResponseModel> verifyOtp(String mobile, String otp) async {
    return await _authRepository.verifyOtp(mobile, otp);
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
}