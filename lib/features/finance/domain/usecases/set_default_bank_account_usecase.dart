import '../repositories/finance_repository_interface.dart';
import '../../../../core/services/network/response_model.dart';

class SetDefaultBankAccountUseCase {
  final FinanceRepositoryInterface _repository;

  SetDefaultBankAccountUseCase(this._repository);

  Future<ResponseModel> call(int id) async {
    return await _repository.setDefaultBankAccount(id);
  }
}
