import 'package:astro_astrologer/core/services/network/response_model.dart';
import 'package:astro_astrologer/features/profile/data/models/phone_number_model.dart';

abstract class PhoneNumberRepositoryInterface {
  Future<ResponseModel> getPhoneNumbers();
  Future<ResponseModel> addPhoneNumber(String countryCode, String phone);
  Future<ResponseModel> verifyPhoneNumber(int id, String otp);
  Future<ResponseModel> setDefaultPhoneNumber(int id);
  Future<ResponseModel> deletePhoneNumber(int id);
}
