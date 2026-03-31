import '../repositories/finance_repository_interface.dart';
import '../../../../core/services/network/response_model.dart';

class GetBankAccountsUseCase {
  final FinanceRepositoryInterface _repository;

  GetBankAccountsUseCase(this._repository);

  Future<ResponseModel> call() async {
    return await _repository.getBankAccounts();
  }
}