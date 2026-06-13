import 'package:astro_astrologer/core/services/network/api_client.dart';
import 'package:astro_astrologer/core/constants/app_urls.dart';
import '../../domain/models/wallet_summary_model.dart';
import '../../domain/models/wallet_transaction_model.dart';
import '../../domain/models/weekly_ranking_model.dart';
import '../../domain/repositories/i_wallet_repository.dart';

class WalletRepositoryImpl implements IWalletRepository {
  final ApiClient _apiClient;

  WalletRepositoryImpl({required ApiClient apiClient}) : _apiClient = apiClient;

  @override
  Future<WalletSummaryModel> getWalletSummary() async {
    final response = await _apiClient.get(AppUrls.walletSummary);

    if (response.isSuccess) {
      return WalletSummaryModel.fromJson(response.body ?? {});
    } else {
      throw Exception(response.message);
    }
  }

  @override
  Future<WeeklyRankingData> getWeeklyRankings() async {
    final response = await _apiClient.get(AppUrls.walletWeeklyRankings);

    if (response.isSuccess) {
      final body = response.body;
      // ResponseModel already extracts json['data'] as body, so body IS the data object
      final dataMap = (body is Map<String, dynamic>) ? body : <String, dynamic>{};
      return WeeklyRankingData.fromJson(dataMap);
    } else {
      throw Exception(response.message);
    }
  }

  @override
  Future<List<WalletTransactionModel>> getEarnings({
    String? filter,
    int? page,
  }) async {
    final queryParams = <String, dynamic>{};
    if (filter != null) queryParams['filter'] = filter;
    if (page != null) queryParams['page'] = page;

    final response = await _apiClient.get(
      AppUrls.walletEarnings,
      queryParameters: queryParams,
    );

    if (response.isSuccess) {
      final List<dynamic> dataList = response.body?['data'] ?? [];
      return dataList.map((e) => WalletTransactionModel.fromJson(e)).toList();
    } else {
      throw Exception(response.message);
    }
  }

  @override
  Future<List<WalletTransactionModel>> getWithdrawals({
    int? page,
  }) async {
    final queryParams = <String, dynamic>{};
    if (page != null) queryParams['page'] = page;

    final response = await _apiClient.get(
      AppUrls.walletWithdrawals,
      queryParameters: queryParams,
    );

    if (response.isSuccess) {
      final List<dynamic> dataList = response.body?['data'] ?? [];
      return dataList.map((e) => WalletTransactionModel.fromJson(e)).toList();
    } else {
      throw Exception(response.message);
    }
  }

  @override
  Future<WalletTransactionModel> requestWithdrawal({
    required double amount,
    required int bankAccountId,
  }) async {
    final response = await _apiClient.post(
      AppUrls.walletWithdraw,
      data: {
        'amount': amount,
        'bank_account_id': bankAccountId,
      },
    );

    if (response.isSuccess) {
      final txData = response.body?['transaction'] ?? {};
      return WalletTransactionModel.fromJson(txData);
    } else {
      throw Exception(response.message);
    }
  }
}
