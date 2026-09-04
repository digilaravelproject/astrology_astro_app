import 'package:astro_astrologer/core/services/network/response_model.dart';
import 'package:astro_astrologer/features/support/data/models/faq_model.dart';
import 'package:astro_astrologer/features/support/domain/repositories/support_repository.dart';

class GetPrivacyPolicyUseCase {
  final SupportRepository repository;

  GetPrivacyPolicyUseCase({required this.repository});

  Future<FAQModel?> execute() async {
    final response = await repository.getPrivacyPolicy();
    if (response.isSuccess && response.body != null) {
      return FAQModel.fromJson(response.body);
    }
    return null;
  }
}
