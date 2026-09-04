import 'package:astro_astrologer/core/services/network/response_model.dart';
import 'package:astro_astrologer/features/profile/domain/repositories/billing_repository_interface.dart';

class GetBillingAddressUseCase {
  final BillingRepositoryInterface repository;

  GetBillingAddressUseCase(this.repository);

  Future<ResponseModel> call() async {
    return await repository.getBillingAddress();
  }
}
