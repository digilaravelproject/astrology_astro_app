import '../models/weekly_ranking_model.dart';
import '../models/wallet_summary_model.dart';
import '../models/wallet_transaction_model.dart';
import '../models/invoice_model.dart';

abstract class IWalletRepository {
  Future<WeeklyRankingData> getWeeklyRankings();
  Future<WalletSummaryModel> getWalletSummary();
  Future<InvoiceSummaryModel> getInvoicesSummary();

  Future<List<WalletTransactionModel>> getEarnings({String? filter, int? page});

  Future<List<WalletTransactionModel>> getWithdrawals({int? page});

  Future<WalletTransactionModel> requestWithdrawal({
    required double amount,
    required int bankAccountId,
  });
}
