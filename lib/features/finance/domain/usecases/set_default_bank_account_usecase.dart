import 'package:astro_astrologer/features/finance/domain/repositories/finance_repository_interface.dart';
import 'package:astro_astrologer/core/services/network/response_model.dart';

class SetDefaultBankAccountUseCase {
  final FinanceRepositoryInterface _repository;

  SetDefaultBankAccountUseCase(this._repository);

  Future<ResponseModel> call(int id) async {
    return await _repository.setDefaultBankAccount(id);
  }
}
