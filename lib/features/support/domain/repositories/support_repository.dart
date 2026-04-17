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

  Future<ResponseModel> getAboutUs() async {
    return await apiClient.get(AppUrls.aboutUs);
  }

  Future<ResponseModel> getCustomerSupport() async {
    return await apiClient.get(AppUrls.customerSupport);
  }

  Future<ResponseModel> submitFeedback(int rating, String comment) async {
    return await apiClient.post(AppUrls.feedback, data: {
      'rating': rating,
      'comment': comment,
    });
  }
}
