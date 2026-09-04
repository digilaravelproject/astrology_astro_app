import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:astro_astrologer/features/wallet/data/models/wallet_summary_model.dart';
import 'package:astro_astrologer/features/wallet/data/models/wallet_transaction_model.dart';
import 'package:astro_astrologer/features/wallet/domain/usecases/get_wallet_summary_usecase.dart';
import 'package:astro_astrologer/features/wallet/domain/usecases/get_wallet_earnings_usecase.dart';
import 'package:astro_astrologer/features/wallet/domain/usecases/get_wallet_withdrawals_usecase.dart';
import 'package:astro_astrologer/features/wallet/domain/usecases/request_withdrawal_usecase.dart';

class WalletController extends GetxController {
  final GetWalletSummaryUseCase _getWalletSummaryUseCase;
  final GetWalletEarningsUseCase _getWalletEarningsUseCase;
  final GetWalletWithdrawalsUseCase _getWalletWithdrawalsUseCase;
  final RequestWithdrawalUseCase _requestWithdrawalUseCase;

  WalletController(
    this._getWalletSummaryUseCase,
    this._getWalletEarningsUseCase,
    this._getWalletWithdrawalsUseCase,
    this._requestWithdrawalUseCase,
  );

  // Summary State
  final Rx<WalletSummaryModel?> summary = Rx<WalletSummaryModel?>(null);
  final RxBool isLoadingSummary = false.obs;
  final RxString summaryError = ''.obs;

  // Earnings State
  final RxList<WalletTransactionModel> earningsList =
      <WalletTransactionModel>[].obs;
  final RxBool isLoadingEarnings = false.obs;
  final RxString earningsError = ''.obs;
  int _currentEarningsPage = 1;
  bool _hasMoreEarnings = true;
  final RxString selectedEarningFilter = 'Today'.obs; // Default

  // Withdrawals State
  final RxList<WalletTransactionModel> withdrawalsList =
      <WalletTransactionModel>[].obs;
  final RxBool isLoadingWithdrawals = false.obs;
  final RxString withdrawalsError = ''.obs;
  int _currentWithdrawalsPage = 1;
  bool _hasMoreWithdrawals = true;

  @override
  void onInit() {
    super.onInit();
    fetchWalletSummary();
    fetchEarnings(isRefresh: true);
    fetchWithdrawals(isRefresh: true);
  }

  Future<void> fetchWalletSummary() async {
    try {
      isLoadingSummary.value = true;
      summaryError.value = '';
      summary.value = await _getWalletSummaryUseCase.execute();
    } catch (e) {
      summaryError.value = e.toString();
    } finally {
      isLoadingSummary.value = false;
    }
  }

  Future<void> fetchEarnings({bool isRefresh = false, String? filter}) async {
    if (filter != null) {
      selectedEarningFilter.value = filter;
      isRefresh = true;
    }

    if (isRefresh) {
      _currentEarningsPage = 1;
      _hasMoreEarnings = true;
      earningsList.clear();
      earningsError.value = '';
    }

    if (!_hasMoreEarnings || isLoadingEarnings.value) return;

    try {
      isLoadingEarnings.value = true;
      String apiFilter = selectedEarningFilter.value.toLowerCase();
      if (apiFilter == 'last 3 months')
        apiFilter = 'monthly'; // fallback or adjust according to API

      final response = await _getWalletEarningsUseCase.execute(
        filter: apiFilter,
        page: _currentEarningsPage,
      );

      if (response.isNotEmpty) {
        earningsList.addAll(response);
        _currentEarningsPage++;
      } else {
        _hasMoreEarnings = false;
      }
    } catch (e) {
      earningsError.value = e.toString();
    } finally {
      isLoadingEarnings.value = false;
    }
  }

  Future<void> fetchWithdrawals({bool isRefresh = false}) async {
    if (isRefresh) {
      _currentWithdrawalsPage = 1;
      _hasMoreWithdrawals = true;
      withdrawalsList.clear();
      withdrawalsError.value = '';
    }

    if (!_hasMoreWithdrawals || isLoadingWithdrawals.value) return;

    try {
      isLoadingWithdrawals.value = true;
      final response = await _getWalletWithdrawalsUseCase.execute(
        page: _currentWithdrawalsPage,
      );

      if (response.isNotEmpty) {
        withdrawalsList.addAll(response);
        _currentWithdrawalsPage++;
      } else {
        _hasMoreWithdrawals = false;
      }
    } catch (e) {
      withdrawalsError.value = e.toString();
    } finally {
      isLoadingWithdrawals.value = false;
    }
  }

  Future<Map<String, dynamic>> requestWithdrawal(
    double amount,
    int bankAccountId,
  ) async {
    try {
      final tx = await _requestWithdrawalUseCase.execute(
        amount: amount,
        bankAccountId: bankAccountId,
      );
      // Refresh summary to reflect new balance, and add to withdrawals list
      fetchWalletSummary();
      withdrawalsList.insert(0, tx);
      return {
        'success': true,
        'message': 'Withdrawal request submitted successfully.',
      };
    } catch (e) {
      return {
        'success': false,
        'message': e.toString().replaceAll('Exception: ', ''),
      };
    }
  }
}
