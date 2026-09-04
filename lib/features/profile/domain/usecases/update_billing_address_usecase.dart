import 'package:astro_astrologer/core/services/network/response_model.dart';
import 'package:astro_astrologer/features/profile/domain/repositories/billing_repository_interface.dart';

class UpdateBillingAddressUseCase {
  final BillingRepositoryInterface repository;

  UpdateBillingAddressUseCase(this.repository);

  Future<ResponseModel> call(Map<String, dynamic> data) async {
    return await repository.updateBillingAddress(data);
  }
}
