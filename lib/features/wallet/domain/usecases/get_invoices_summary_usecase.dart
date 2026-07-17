import '../models/invoice_model.dart';
import '../repositories/i_wallet_repository.dart';

class GetInvoicesSummaryUseCase {
  final IWalletRepository _repository;

  GetInvoicesSummaryUseCase(this._repository);

  Future<InvoiceSummaryModel> execute() async {
    return await _repository.getInvoicesSummary();
  }
}
