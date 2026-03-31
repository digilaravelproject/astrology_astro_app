import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/services/network/response_model.dart';
import '../../../core/utils/custom_snackbar.dart';
import '../../../core/widgets/app_text.dart';
import '../domain/models/user_model.dart';
import '../../../routes/route_helper.dart';
import '../../../core/utils/logger.dart';
import '../domain/services/auth_service.dart';

class AuthController extends GetxController {
  final LoginUseCase _loginUseCase;
  final RegisterUseCase _registerUseCase;
  final VerifyOtpUseCase _verifyOtpUseCase;
  final SendOtpUseCase _sendOtpUseCase;
  final LogoutUseCase _logoutUseCase;
  final CheckLoginStatusUseCase _checkLoginStatusUseCase;
  final GetUserInfoUseCase _getUserInfoUseCase;
  final AstrologerSignupUseCase _astrologerSignupUseCase;
  final ResendOtpUseCase _resendOtpUseCase;
  final UpdateProfilePhotoUseCase _updateProfilePhotoUseCase;
  final UpdateProfileUseCase _updateProfileUseCase;
  final GetProfileUseCase _getProfileUseCase;
  final DeleteAccountUseCase _deleteAccountUseCase;

  AuthController({
    required LoginUseCase loginUseCase,
    required RegisterUseCase registerUseCase,
    required VerifyOtpUseCase verifyOtpUseCase,
    required SendOtpUseCase sendOtpUseCase,
    required LogoutUseCase logoutUseCase,
    required CheckLoginStatusUseCase checkLoginStatusUseCase,
    required GetUserInfoUseCase getUserInfoUseCase,
    required AstrologerSignupUseCase astrologerSignupUseCase,
    required ResendOtpUseCase resendOtpUseCase,
    required UpdateProfilePhotoUseCase updateProfilePhotoUseCase,
    required UpdateProfileUseCase updateProfileUseCase,
    required GetProfileUseCase getProfileUseCase,
    required DeleteAccountUseCase deleteAccountUseCase,
  })  : _loginUseCase = loginUseCase,
        _registerUseCase = registerUseCase,
        _verifyOtpUseCase = verifyOtpUseCase,
        _sendOtpUseCase = sendOtpUseCase,
        _logoutUseCase = logoutUseCase,
        _checkLoginStatusUseCase = checkLoginStatusUseCase,
        _getUserInfoUseCase = getUserInfoUseCase,
        _astrologerSignupUseCase = astrologerSignupUseCase,
        _resendOtpUseCase = resendOtpUseCase,
        _updateProfilePhotoUseCase = updateProfilePhotoUseCase,
        _getProfileUseCase = getProfileUseCase,
        _updateProfileUseCase = updateProfileUseCase,
        _deleteAccountUseCase = deleteAccountUseCase;


  final isLoading = false.obs;
  final currentMobile = ''.obs;
  Rx<UserModel?> currentUser = Rx<UserModel?>(null);

  final formKey = GlobalKey<FormState>();
  final nameController = TextEditingController();
  final mobileController = TextEditingController();
  final otpController = TextEditingController();
  final emailController = TextEditingController();
  final cityController = TextEditingController();
  final countryController = TextEditingController();

  @override
  void onInit() {
    super.onInit();
    checkLoginStatus();
    // Load last used mobile number for OTP screen
    final lastMobile = Get.find<AuthService>().getMobile();
    if (lastMobile != null && lastMobile.isNotEmpty) {
      currentMobile.value = lastMobile;
    }
  }

  @override
  void onClose() {
    super.onClose();
  }

  Future<void> checkLoginStatus() async {
    final isLoggedIn = await _checkLoginStatusUseCase.execute();
    if (isLoggedIn) {
      final user = await _getUserInfoUseCase.execute();
      if (user != null) currentUser.value = user;
    }
  }

  Future<void> signup() async {
    if (!formKey.currentState!.validate()) return;

    try {
      isLoading.value = true;
      final user = await _registerUseCase.execute(
        nameController.text.trim(),
        mobileController.text.trim(),
      );

      if (user != null) {
        currentUser.value = user;
        currentMobile.value = mobileController.text.trim();
        CustomSnackBar.showSuccess('OTP sent to your mobile number');
        Get.toNamed(RouteHelper.getOtpRoute());
      } else {
        CustomSnackBar.showError('Signup failed. Please try again.');
      }
    } catch (e) {
      CustomSnackBar.showError(e.toString());
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> astrologerSignup(Map<String, dynamic> data) async {
    try {
      isLoading.value = true;
      final response = await _astrologerSignupUseCase.execute(data);

      if (response.isSuccess) {
        CustomSnackBar.showSuccess(response.message);
        Get.offAllNamed(RouteHelper.getLoginRoute());
        Get.back();
      } else {
        CustomSnackBar.showError(response.message);
      }
    } catch (e) {
      Logger.e('AuthController: astrologerSignup error: $e');
      CustomSnackBar.showError(e.toString());
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> login() async {
    if (!formKey.currentState!.validate()) return;

    try {
      isLoading.value = true;
      final user = await _loginUseCase.execute(mobileController.text.trim());

      if (user != null) {
        currentUser.value = user;
        final mobile = mobileController.text.trim();
        currentMobile.value = mobile;
        await Get.find<AuthService>().saveMobile(mobile);
        Get.toNamed(RouteHelper.getOtpRoute());
      }
    } catch (e) {
      CustomSnackBar.showError(e.toString());
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> sendOtp() async {
    try {
      isLoading.value = true;
      final response = await _sendOtpUseCase.execute(
        mobileController.text.trim(),
        '1234',
      );
      
      if (response.isSuccess) {
        final mobile = mobileController.text.trim();
        currentMobile.value = mobile;
        await Get.find<AuthService>().saveMobile(mobile);
        CustomSnackBar.showSuccess(response.message);
        Get.toNamed(RouteHelper.getOtpRoute());
      } else {
        CustomSnackBar.showError(response.message);
      }
    } catch (e) {
      Logger.e('AuthController: sendOtp caught exception: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> resendOtp() async {
    try {
      isLoading.value = true;
      final response = await _resendOtpUseCase.execute(
        currentMobile.value,
        '1234',
      );

      if (response.isSuccess) {
        CustomSnackBar.showSuccess(response.message);
      } else {
        CustomSnackBar.showError(response.message);
      }
    } catch (e) {
      Logger.e('AuthController: resendOtp error: $e');
      CustomSnackBar.showError(e.toString());
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> updateProfilePhoto(File image) async {
    try {
      isLoading.value = true;
      final response = await _updateProfilePhotoUseCase.execute(image);

      if (response.isSuccess && response.body != null) {
        final userData = response.body['user'];
        if (userData != null) {
          currentUser.value = UserModel.fromJson(userData);
        }
        CustomSnackBar.showSuccess(response.message);
      } else {
        CustomSnackBar.showError(response.message);
      }
    } catch (e) {
      Logger.e('AuthController: updateProfilePhoto error: $e');
      CustomSnackBar.showError(e.toString());
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> updateProfile(Map<String, dynamic> data) async {
    try {
      isLoading.value = true;
      final response = await _updateProfileUseCase.execute(data);

      if (response.isSuccess && response.body != null) {
        final userData = response.body['user'];
        if (userData != null) {
          currentUser.value = UserModel.fromJson(userData);
          Get.back();
        }
        CustomSnackBar.showSuccess(response.message);
      } else {
        CustomSnackBar.showError(response.message);
      }
    } catch (e) {
      Logger.e('AuthController: updateProfile error: $e');
      CustomSnackBar.showError(e.toString());
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> getProfile(int id) async {
    try {
      isLoading.value = true;
      final response = await _getProfileUseCase.execute(id);
      if (response.isSuccess && response.body != null) {
        final userData = response.body['user'];
        if (userData != null) {
          currentUser.value = UserModel.fromJson(userData);
        }
      } else {
        CustomSnackBar.showError(response.message);
      }
    } catch (e) {
      Logger.e('AuthController: getProfile error: $e');
      CustomSnackBar.showError(e.toString());
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> verifyOtp() async {
    if (otpController.text.isEmpty) {
      CustomSnackBar.showError('Please enter OTP');
      return;
    }

    try {
      isLoading.value = true;
      final response = await _verifyOtpUseCase.execute(
        currentMobile.value,
        otpController.text.trim(),
      );

      if (response.isSuccess && response.body != null) {
        final userData = response.body['user'];
        if (userData != null) {
          currentUser.value = UserModel.fromJson(userData);
        }
        otpController.clear();
        CustomSnackBar.showSuccess('OTP verified successfully');
        Get.offAllNamed(RouteHelper.getDashboardRoute());
      } else {
        CustomSnackBar.showError(response.message);
      }
    } catch (e) {
      Logger.e('AuthController: verifyOtp error: $e');
      CustomSnackBar.showError(e.toString());
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> logout() async {
    try {
      isLoading.value = true;
      final response = await _logoutUseCase.execute();
      
      if (response.isSuccess) {
        currentUser.value = null;
        CustomSnackBar.showSuccess(response.message);
        Get.offAllNamed(RouteHelper.getLoginRoute());
      } else {
        CustomSnackBar.showError(response.message);
      }
    } catch (e) {
      CustomSnackBar.showError(e.toString());
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> deleteAccount() async {
    Get.dialog(
      Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.red.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.delete_forever_rounded, color: Colors.red, size: 32),
              ),
              const SizedBox(height: 20),
              const AppText(
                'Delete Account',
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: Color(0xFF2E1A47),
              ),
              const SizedBox(height: 12),
              AppText(
                'Are you sure you want to delete your account? This action cannot be undone and all your data will be permanently removed.',
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: Colors.grey[600],
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 30),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Get.back(),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        side: BorderSide(color: Colors.grey[300]!),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      child: AppText('Cancel', fontSize: 14, fontWeight: FontWeight.w600, color: Colors.grey[600]),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () async {
                        Get.back(); // Close dialog
                        try {
                          isLoading.value = true;
                          final response = await _deleteAccountUseCase.execute();

                          if (response.isSuccess) {
                            currentUser.value = null;
                            currentMobile.value = '';
                            mobileController.clear();
                            otpController.clear();
                            nameController.clear();
                            Get.offAllNamed(RouteHelper.getLoginRoute());

                            Future.delayed(const Duration(milliseconds: 300), () {
                              CustomSnackBar.showSuccess(response.message ?? 'Account deleted successfully');
                            });
                          } else {
                            CustomSnackBar.showError(response.message ?? 'Failed to delete account');
                          }
                        } catch (e) {
                          print('Delete account error: $e');
                          CustomSnackBar.showError('An error occurred during account deletion');
                        } finally {
                          isLoading.value = false;
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        backgroundColor: Colors.red,
                        elevation: 0,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      child: const AppText('Delete', fontSize: 14, fontWeight: FontWeight.w600, color: Colors.white),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }


  String? validateName(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter your name';
    }
    return null;
  }

  String? validateMobile(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter your mobile number';
    }
    if (value.length != 10 || !RegExp(r'^[0-9]+$').hasMatch(value)) {
      return 'Please enter a valid 10-digit mobile number';
    }
    return null;
  }
}

class LoginUseCase {
  final AuthService _authService;
  LoginUseCase(this._authService);
  Future<UserModel?> execute(String mobile) async {
    final response = await _authService.login(mobile);
    if (response.isSuccess && response.body != null) {
      return UserModel.fromJson(response.body);
    }
    return null;
  }
}

class VerifyOtpUseCase {
  final AuthService _authService;
  VerifyOtpUseCase(this._authService);
  Future<ResponseModel> execute(String mobile, String otp) async {
    return await _authService.verifyOtp(mobile, otp);
  }
}

class LogoutUseCase {
  final AuthService _authService;
  LogoutUseCase(this._authService);
  Future<ResponseModel> execute() async {
    return await _authService.logout();
  }
}

class CheckLoginStatusUseCase {
  final AuthService _authService;
  CheckLoginStatusUseCase(this._authService);
  Future<bool> execute() async {
    return await _authService.isLoggedIn();
  }
}

class GetUserInfoUseCase {
  final AuthService _authService;
  GetUserInfoUseCase(this._authService);
  Future<UserModel?> execute() async {
    return await _authService.getUserInfo();
  }
}

class RegisterUseCase {
  final AuthService _authService;
  RegisterUseCase(this._authService);
  Future<UserModel?> execute(String name, String mobile) async {
    final response = await _authService.signup(name, mobile);
    if (response.isSuccess && response.body != null) {
      try {
        return UserModel.fromJson(response.body);
      } catch (e) {
        Logger.e('Error parsing user data: $e');
      }
    }
    return null;
  }
}

class SendOtpUseCase {
  final AuthService _authService;
  SendOtpUseCase(this._authService);
  Future<ResponseModel> execute(String mobile, String otp) async {
    return await _authService.sendOtp(mobile, otp);
  }
}

class AstrologerSignupUseCase {
  final AuthService _authService;
  AstrologerSignupUseCase(this._authService);
  Future<ResponseModel> execute(Map<String, dynamic> data) async {
    return await _authService.astrologerSignup(data);
  }
}

class ResendOtpUseCase {
  final AuthService _authService;
  ResendOtpUseCase(this._authService);
  Future<ResponseModel> execute(String mobile, String otp) async {
    return await _authService.resendOtp(mobile, otp);
  }
}

class UpdateProfilePhotoUseCase {
  final AuthService _authService;
  UpdateProfilePhotoUseCase(this._authService);
  Future<ResponseModel> execute(File image) async {
    return await _authService.updateProfilePhoto(image);
  }
}

class UpdateProfileUseCase {
  final AuthService _authService;
  UpdateProfileUseCase(this._authService);
  Future<ResponseModel> execute(Map<String, dynamic> data) async {
    return await _authService.updateProfile(data);
  }
}

class GetProfileUseCase {
  final AuthService _authService;
  GetProfileUseCase(this._authService);
  Future<ResponseModel> execute(int id) async {
    return await _authService.getProfile(id);
  }
}


class DeleteAccountUseCase {
  final AuthService _authService;

  DeleteAccountUseCase(this._authService);

  Future<ResponseModel> execute() async {
    return await _authService.deleteAccount();
  }
}