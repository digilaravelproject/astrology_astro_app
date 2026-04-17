import 'package:get/get.dart';
import '../../domain/models/faq_model.dart';
import '../../domain/usecases/get_faq_usecase.dart';
import '../../domain/usecases/get_payment_policy_usecase.dart';
import '../../domain/usecases/get_privacy_policy_usecase.dart';
import '../../domain/usecases/get_terms_and_conditions_usecase.dart';
import '../../domain/usecases/get_about_us_usecase.dart';
import '../../domain/usecases/get_customer_support_usecase.dart';
import '../../domain/usecases/submit_feedback_usecase.dart';

class SupportController extends GetxController {
  final GetFAQUseCase _getFAQUseCase;
  final GetPrivacyPolicyUseCase _getPrivacyPolicyUseCase;
  final GetPaymentPolicyUseCase _getPaymentPolicyUseCase;
  final GetTermsAndConditionsUseCase _getTermsAndConditionsUseCase;
  final GetAboutUsUseCase _getAboutUsUseCase;
  final GetCustomerSupportUseCase _getCustomerSupportUseCase;
  final SubmitFeedbackUseCase _submitFeedbackUseCase;

  SupportController({
    required GetFAQUseCase getFAQUseCase,
    required GetPrivacyPolicyUseCase getPrivacyPolicyUseCase,
    required GetPaymentPolicyUseCase getPaymentPolicyUseCase,
    required GetTermsAndConditionsUseCase getTermsAndConditionsUseCase,
    required GetAboutUsUseCase getAboutUsUseCase,
    required GetCustomerSupportUseCase getCustomerSupportUseCase,
    required SubmitFeedbackUseCase submitFeedbackUseCase,
  })  : _getFAQUseCase = getFAQUseCase,
        _getPrivacyPolicyUseCase = getPrivacyPolicyUseCase,
        _getPaymentPolicyUseCase = getPaymentPolicyUseCase,
        _getTermsAndConditionsUseCase = getTermsAndConditionsUseCase,
        _getAboutUsUseCase = getAboutUsUseCase,
        _getCustomerSupportUseCase = getCustomerSupportUseCase,
        _submitFeedbackUseCase = submitFeedbackUseCase;

  final Rx<FAQModel?> faqData = Rx<FAQModel?>(null);
  final Rx<FAQModel?> privacyPolicyData = Rx<FAQModel?>(null);
  final Rx<FAQModel?> termsAndConditionsData = Rx<FAQModel?>(null);
  final Rx<FAQModel?> paymentPolicyData = Rx<FAQModel?>(null);
  final Rx<FAQModel?> aboutUsData = Rx<FAQModel?>(null);
  final Rx<FAQModel?> customerSupportData = Rx<FAQModel?>(null);
  
  final RxBool isLoading = false.obs;
  final RxBool isPrivacyLoading = false.obs;
  final RxBool isPaymentLoading = false.obs;
  final RxBool isTermsLoading = false.obs;
  final RxBool isAboutUsLoading = false.obs;
  final RxBool isCustomerSupportLoading = false.obs;
  final RxBool isFeedbackSubmitting = false.obs;

  @override
  void onInit() {
    super.onInit();
    fetchFAQs();
  }

  Future<void> fetchAboutUs() async {
    try {
      isAboutUsLoading.value = true;
      final result = await _getAboutUsUseCase.execute();
      aboutUsData.value = result;
    } catch (e) {
      print('Error fetching About Us: $e');
    } finally {
      isAboutUsLoading.value = false;
    }
  }

  Future<void> fetchCustomerSupport() async {
    try {
      isCustomerSupportLoading.value = true;
      final result = await _getCustomerSupportUseCase.execute();
      customerSupportData.value = result;
    } catch (e) {
      print('Error fetching Customer Support: $e');
    } finally {
      isCustomerSupportLoading.value = false;
    }
  }

  Future<bool> submitFeedback(int rating, String comment) async {
    try {
      isFeedbackSubmitting.value = true;
      final response = await _submitFeedbackUseCase.execute(rating, comment);
      return response.isSuccess;
    } catch (e) {
      print('Error submitting feedback: $e');
      return false;
    } finally {
      isFeedbackSubmitting.value = false;
    }
  }

  Future<void> fetchFAQs() async {
    try {
      isLoading.value = true;
      final result = await _getFAQUseCase.execute();
      faqData.value = result;
    } catch (e) {
      print('Error fetching FAQs: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> fetchPrivacyPolicy() async {
    try {
      isPrivacyLoading.value = true;
      final result = await _getPrivacyPolicyUseCase.execute();
      privacyPolicyData.value = result;
    } catch (e) {
      print('Error fetching Privacy Policy: $e');
    } finally {
      isPrivacyLoading.value = false;
    }
  }

  Future<void> fetchPaymentPolicy() async {
    try {
      isPaymentLoading.value = true;
      final result = await _getPaymentPolicyUseCase.execute();
      paymentPolicyData.value = result;
    } catch (e) {
      print('Error fetching Payment Policy: $e');
    } finally {
      isPaymentLoading.value = false;
    }
  }

  Future<void> fetchTermsAndConditions() async {
    try {
      isTermsLoading.value = true;
      final result = await _getTermsAndConditionsUseCase.execute();
      termsAndConditionsData.value = result;
    } catch (e) {
      print('Error fetching Terms and Conditions: $e');
    } finally {
      isTermsLoading.value = false;
    }
  }
}
