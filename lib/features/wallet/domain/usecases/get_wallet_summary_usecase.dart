import 'package:astro_astrologer/features/wallet/data/models/wallet_summary_model.dart';
import 'package:astro_astrologer/features/wallet/domain/repositories/i_wallet_repository.dart';

class GetWalletSummaryUseCase {
  final IWalletRepository _repository;

  GetWalletSummaryUseCase(this._repository);

  Future<WalletSummaryModel> execute() {
    return _repository.getWalletSummary();
  }
}
