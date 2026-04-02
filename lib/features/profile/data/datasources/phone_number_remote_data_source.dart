import '../../../../core/services/network/api_client.dart';
import '../../../../core/services/network/response_model.dart';
import '../../../../core/constants/app_urls.dart';

class PhoneNumberRemoteDataSource {
  final ApiClient _apiClient;

  PhoneNumberRemoteDataSource(this._apiClient);

  Future<ResponseModel> getPhoneNumbers() async {
    print('[PHONE_DS] Getting phone numbers');
    final result = await _apiClient.get(AppUrls.phoneNumbers);
    print('[PHONE_DS] Get phone numbers response: ${result.toString()}');
    return result;
  }

  Future<ResponseModel> addPhoneNumber(String countryCode, String phone) async {
    print('[PHONE_DS] Adding phone number: $countryCode $phone');
    final data = {
      'country_code': countryCode,
      'phone': phone,
    };
    final result = await _apiClient.post(AppUrls.phoneNumbers, data: data);
    print('[PHONE_DS] Add phone number response: ${result.toString()}');
    return result;
  }

  Future<ResponseModel> verifyPhoneNumber(int id, String otp) async {
    print('[PHONE_DS] Verifying phone number: $id with OTP: $otp');
    final data = {'otp': otp};
    final result = await _apiClient.post('${AppUrls.phoneNumbers}/$id/verify', data: data);
    print('[PHONE_DS] Verify phone number response: ${result.toString()}');
    return result;
  }

  Future<ResponseModel> setDefaultPhoneNumber(int id) async {
    print('[PHONE_DS] Setting default phone number: $id');
    final result = await _apiClient.post('${AppUrls.phoneNumbers}/$id/set-default');
    print('[PHONE_DS] Set default response: ${result.toString()}');
    return result;
  }

  Future<ResponseModel> deletePhoneNumber(int id) async {
    print('[PHONE_DS] Deleting phone number: $id');
    final result = await _apiClient.delete('${AppUrls.phoneNumbers}/$id');
    print('[PHONE_DS] Delete phone number response: ${result.toString()}');
    return result;
  }
}
