import 'package:astro_astrologer/features/wallet/data/models/wallet_transaction_model.dart';
import 'package:astro_astrologer/features/wallet/domain/repositories/i_wallet_repository.dart';

class GetWalletEarningsUseCase {
  final IWalletRepository _repository;

  GetWalletEarningsUseCase(this._repository);

  Future<List<WalletTransactionModel>> execute({String? filter, int? page}) {
    return _repository.getEarnings(filter: filter, page: page);
  }
}
