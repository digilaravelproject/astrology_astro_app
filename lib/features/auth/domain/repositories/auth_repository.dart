import 'dart:async';
import 'dart:io';
import 'package:dio/dio.dart' as dio;
import 'package:http_parser/http_parser.dart';

import 'package:astro_astrologer/core/constants/app_constants.dart';
import 'package:astro_astrologer/core/constants/app_urls.dart';
import 'package:astro_astrologer/core/services/network/api_client.dart';
import 'package:astro_astrologer/core/services/network/response_model.dart';
import 'package:astro_astrologer/features/auth/domain/repositories/auth_repository_interface.dart';

class AuthRepository implements AuthRepositoryInterface {
  final ApiClient _apiClient;

  AuthRepository(this._apiClient);

  @override
  Future<ResponseModel> signup(String name, String mobile) async {
    return const ResponseModel(isSuccess: true, message: 'Stub signup success');
  }

  @override
  Future<ResponseModel> astrologerSignup(Map<String, dynamic> data) async {
    // Format keys for arrays if they don't already have []
    final Map<String, dynamic> formattedData = {};
    data.forEach((key, value) {
      if ((key == 'areas_of_expertise' || key == 'languages') && value is List) {
        formattedData['$key[]'] = value;
      } else {
        formattedData[key] = value;
      }
    });

    final formData = dio.FormData.fromMap(formattedData);
    
    // Handle files separately if they are paths
    if (data.containsKey('profile_photo') && data['profile_photo'] != null) {
      formData.files.add(MapEntry(
        'profile_photo',
        await dio.MultipartFile.fromFile(data['profile_photo']),
      ));
    }
    if (data.containsKey('id_proof') && data['id_proof'] != null) {
      formData.files.add(MapEntry(
        'id_proof',
        await dio.MultipartFile.fromFile(data['id_proof']),
      ));
    }
    
    return await _apiClient.post(
      AppUrls.astrologerSignup, 
      data: formData,
      options: dio.Options(headers: {'no_auth': true}),
    );
  }

  @override
  Future<ResponseModel> login(String mobile) async {
    return const ResponseModel(isSuccess: true, message: 'Stub login success');
  }

  @override
  Future<ResponseModel> verifyOtp(String mobile, String otp) async {
    final data = dio.FormData.fromMap({
      'phone': mobile,
      'otp': otp,
    });
    return await _apiClient.post(AppUrls.verifyOtp, data: data);
  }

  @override
  Future<ResponseModel> sendOtp(String mobile, String otp) async {
    final data = dio.FormData.fromMap({
      'phone': mobile,
      'otp': otp,
    });
    return await _apiClient.post(AppUrls.sendOtp, data: data);
  }

  @override
  Future<ResponseModel> resendOtp(String mobile, String otp) async {
    final data = dio.FormData.fromMap({
      'phone': mobile,
      'otp': otp,
    });
    return await _apiClient.post(AppUrls.resendOtp, data: data);
  }

  @override
  Future<ResponseModel> updateProfilePhoto(File image) async {
    String fileName = image.path.split('/').last;
    final data = dio.FormData.fromMap({
      'profile_photo': await dio.MultipartFile.fromFile(
        image.path,
        filename: fileName,
        contentType: MediaType('image', 'jpeg'),
      ),
    });
    return await _apiClient.post(AppUrls.updateProfilePhoto, data: data);
  }

  @override
  Future<ResponseModel> updateProfile(Map<String, dynamic> data) async {
    final formData = dio.FormData.fromMap(data);

    // Handle potential files in the data map
    if (data.containsKey('profile_photo') && data['profile_photo'] is File) {
      File file = data['profile_photo'];
      formData.files.add(MapEntry(
        'profile_photo',
        await dio.MultipartFile.fromFile(file.path),
      ));
    }
    if (data.containsKey('id_proof') && data['id_proof'] is File) {
      File file = data['id_proof'];
      formData.files.add(MapEntry(
        'id_proof',
        await dio.MultipartFile.fromFile(file.path),
      ));
    }
    if (data.containsKey('certificate') && data['certificate'] is File) {
      File file = data['certificate'];
      formData.files.add(MapEntry(
        'certificate',
        await dio.MultipartFile.fromFile(file.path),
      ));
    }

    return await _apiClient.post(AppUrls.updateProfile, data: formData);
  }
}