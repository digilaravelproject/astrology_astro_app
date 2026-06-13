import '../../../../core/services/network/response_model.dart';
import '../repositories/billing_repository_interface.dart';

class UpdateBillingAddressUseCase {
  final BillingRepositoryInterface repository;

  UpdateBillingAddressUseCase(this.repository);

  Future<ResponseModel> call(Map<String, dynamic> data) async {
    return await repository.updateBillingAddress(data);
  }
}
