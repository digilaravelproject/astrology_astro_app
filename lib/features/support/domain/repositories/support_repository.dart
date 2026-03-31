import '../../../../core/services/network/api_client.dart';
import '../../../../core/services/network/response_model.dart';
import '../../../../core/constants/app_urls.dart';

class SupportRepository {
  final ApiClient apiClient;

  SupportRepository({required this.apiClient});

  Future<ResponseModel> getFAQs() async {
    return await apiClient.get(AppUrls.faqs);
  }

  Future<ResponseModel> getPrivacyPolicy() async {
    return await apiClient.get(AppUrls.privacyPolicy);
  }

  Future<ResponseModel> getPaymentPolicy() async {
    return await apiClient.get(AppUrls.paymentPolicy);
  }

  Future<ResponseModel> getTermsAndConditions() async {
    return await apiClient.get(AppUrls.termsAndConditions);
  }
}
