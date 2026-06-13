import '../models/wallet_transaction_model.dart';
import '../repositories/i_wallet_repository.dart';

class GetWalletWithdrawalsUseCase {
  final IWalletRepository _repository;

  GetWalletWithdrawalsUseCase(this._repository);

  Future<List<WalletTransactionModel>> execute({
    int? page,
  }) {
    return _repository.getWithdrawals(page: page);
  }
}
