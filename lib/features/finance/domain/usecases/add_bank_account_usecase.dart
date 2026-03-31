import 'dart:io';
import '../repositories/finance_repository_interface.dart';
import '../../../../core/services/network/response_model.dart';

class AddBankAccountUseCase {
  final FinanceRepositoryInterface _repository;

  AddBankAccountUseCase(this._repository);

  Future<ResponseModel> call({
    required String accountHolderName,
    required String bankName,
    required String accountNumber,
    required String ifscCode,
    File? passbookDocument,
  }) async {
    return await _repository.addBankAccount(
      accountHolderName: accountHolderName,
      bankName: bankName,
      accountNumber: accountNumber,
      ifscCode: ifscCode,
      passbookDocument: passbookDocument,
    );
  }
}