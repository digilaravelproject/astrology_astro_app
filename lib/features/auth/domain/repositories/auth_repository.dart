import 'dart:async';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/services/network/api_client.dart';
import '../../../../core/services/network/response_model.dart';
import 'auth_repository_interface.dart';

class AuthRepository implements AuthRepositoryInterface {
  final ApiClient _apiClient;

  AuthRepository(this._apiClient);

  @override
  Future<ResponseModel> signup(String name, String mobile) async {
    return const ResponseModel(isSuccess: true, message: 'Stub signup success');
  }

  @override
  Future<ResponseModel> login(String mobile) async {
    return const ResponseModel(isSuccess: true, message: 'Stub login success');
  }

  @override
  Future<ResponseModel> verifyOtp(String mobile, String otp) async {
    return const ResponseModel(isSuccess: true, message: 'Stub OTP verified');
  }
}