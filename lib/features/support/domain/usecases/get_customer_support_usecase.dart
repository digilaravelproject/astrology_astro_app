import '../../../../core/services/network/response_model.dart';
import '../models/faq_model.dart';
import '../repositories/support_repository.dart';

class GetCustomerSupportUseCase {
  final SupportRepository repository;

  GetCustomerSupportUseCase({required this.repository});

  Future<FAQModel?> execute() async {
    final response = await repository.getCustomerSupport();
    if (response.isSuccess && response.body != null) {
      return FAQModel.fromJson(response.body);
    }
    return null;
  }
}
