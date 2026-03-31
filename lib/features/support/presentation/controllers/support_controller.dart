import 'package:get/get.dart';
import '../../domain/models/faq_model.dart';
import '../../domain/usecases/get_faq_usecase.dart';
import '../../domain/usecases/get_payment_policy_usecase.dart';
import '../../domain/usecases/get_privacy_policy_usecase.dart';
import '../../domain/usecases/get_terms_and_conditions_usecase.dart';

class SupportController extends GetxController {
  final GetFAQUseCase _getFAQUseCase;
  final GetPrivacyPolicyUseCase _getPrivacyPolicyUseCase;
  final GetPaymentPolicyUseCase _getPaymentPolicyUseCase;
  final GetTermsAndConditionsUseCase _getTermsAndConditionsUseCase;

  SupportController({
    required GetFAQUseCase getFAQUseCase,
    required GetPrivacyPolicyUseCase getPrivacyPolicyUseCase,
    required GetPaymentPolicyUseCase getPaymentPolicyUseCase,
    required GetTermsAndConditionsUseCase getTermsAndConditionsUseCase,
  })  : _getFAQUseCase = getFAQUseCase,
        _getPrivacyPolicyUseCase = getPrivacyPolicyUseCase,
        _getPaymentPolicyUseCase = getPaymentPolicyUseCase,
        _getTermsAndConditionsUseCase = getTermsAndConditionsUseCase;

  final Rx<FAQModel?> faqData = Rx<FAQModel?>(null);
  final Rx<FAQModel?> privacyPolicyData = Rx<FAQModel?>(null);
  final Rx<FAQModel?> termsAndConditionsData = Rx<FAQModel?>(null);
  final Rx<FAQModel?> paymentPolicyData = Rx<FAQModel?>(null);
  final RxBool isLoading = false.obs;
  final RxBool isPrivacyLoading = false.obs;
  final RxBool isPaymentLoading = false.obs;
  final RxBool isTermsLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    fetchFAQs();
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
