import '../models/wallet_transaction_model.dart';
import '../repositories/i_wallet_repository.dart';

class RequestWithdrawalUseCase {
  final IWalletRepository _repository;

  RequestWithdrawalUseCase(this._repository);

  Future<WalletTransactionModel> execute({
    required double amount,
    required int bankAccountId,
  }) {
    return _repository.requestWithdrawal(amount: amount, bankAccountId: bankAccountId);
  }
}
