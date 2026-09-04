import 'package:astro_astrologer/features/wallet/data/models/wallet_transaction_model.dart';
import 'package:astro_astrologer/features/wallet/domain/repositories/i_wallet_repository.dart';

class GetWalletWithdrawalsUseCase {
  final IWalletRepository _repository;

  GetWalletWithdrawalsUseCase(this._repository);

  Future<List<WalletTransactionModel>> execute({int? page}) {
    return _repository.getWithdrawals(page: page);
  }
}
