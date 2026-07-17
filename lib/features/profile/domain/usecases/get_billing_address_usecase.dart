import '../../../../core/services/network/response_model.dart';
import '../repositories/billing_repository_interface.dart';

class GetBillingAddressUseCase {
  final BillingRepositoryInterface repository;

  GetBillingAddressUseCase(this.repository);

  Future<ResponseModel> call() async {
    return await repository.getBillingAddress();
  }
}
