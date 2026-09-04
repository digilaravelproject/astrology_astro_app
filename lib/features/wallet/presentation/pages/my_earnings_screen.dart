import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import 'package:intl/intl.dart';
import 'package:astro_astrologer/core/theme/app_colors.dart';
import 'package:astro_astrologer/core/widgets/app_text.dart';
import 'package:astro_astrologer/core/widgets/custom_app_bar.dart';
import 'package:astro_astrologer/features/profile/presentation/screens/weekly_ranking_screen.dart';
import 'package:astro_astrologer/features/wallet/presentation/controllers/wallet_controller.dart';
import 'package:astro_astrologer/features/wallet/domain/usecases/get_wallet_summary_usecase.dart';
import 'package:astro_astrologer/features/wallet/domain/usecases/get_wallet_earnings_usecase.dart';
import 'package:astro_astrologer/features/wallet/domain/usecases/get_wallet_withdrawals_usecase.dart';
import 'package:astro_astrologer/features/wallet/domain/usecases/request_withdrawal_usecase.dart';
import 'package:astro_astrologer/features/wallet/data/repositories/wallet_repository_impl.dart';
import 'package:astro_astrologer/core/services/network/api_client.dart';
import 'package:astro_astrologer/features/finance/withdrawal_screen.dart';

class MyEarningsScreen extends StatefulWidget {
  const MyEarningsScreen({super.key});

  @override
  State<MyEarningsScreen> createState() => _MyEarningsScreenState();
}

class _MyEarningsScreenState extends State<MyEarningsScreen> {
  String _activeTab = 'Earnings';

  late WalletController _walletController;

  @override
  void initState() {
    super.initState();
    if (!Get.isRegistered<WalletController>()) {
      final repository = WalletRepositoryImpl(apiClient: Get.find<ApiClient>());
      Get.put(
        WalletController(
          GetWalletSummaryUseCase(repository),
          GetWalletEarningsUseCase(repository),
          GetWalletWithdrawalsUseCase(repository),
          RequestWithdrawalUseCase(repository),
        ),
      );
    }
    _walletController = Get.find<WalletController>();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.fieldBackground,
      appBar: CustomAppBar(title: 'My Earnings'.tr),
      body: RefreshIndicator(
        onRefresh: () async {
          await Future.wait([
            _walletController.fetchWalletSummary(),
            _walletController.fetchEarnings(isRefresh: true),
            _walletController.fetchWithdrawals(isRefresh: true),
          ]);
        },
        color: AppColors.primaryColor,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Column(
            children: [
              _buildWalletCard(),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildCompactEarningsRow(),
                    const SizedBox(height: 12),
                    _buildWeeklyEarningsCard(),
                    const SizedBox(height: 24),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _buildTabToggle(),
                        if (_activeTab == 'Earnings') _buildFilterDropdown(),
                      ],
                    ),
                    const SizedBox(height: 12),
                    _activeTab == 'Earnings'
                        ? _buildTransactionList()
                        : _buildWithdrawalHistoryList(),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildWalletCard() {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.fromLTRB(20, 10, 20, 10),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF2E1A47), Color(0xFF1A0F2E)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF2E1A47).withOpacity(0.3),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Obx(() {
        final summary = _walletController.summary.value;
        final balance = summary?.totalBalance ?? 0.0;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    AppText(
                      'Total Balance'.tr,
                      fontSize: 13,
                      color: Colors.white.withOpacity(0.7),
                      fontWeight: FontWeight.w500,
                    ),
                    const SizedBox(height: 4),
                    AppText(
                      '₹${NumberFormat("#,##0.00").format(balance)}',
                      fontSize: 28,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                    ),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Iconsax.wallet_2_copy,
                    color: Colors.white,
                    size: 24,
                  ),
                ),
              ],
            ),

            /// const SizedBox(height: 20),
            // Row(
            //   children: [
            //     Expanded(
            //       child: CustomButton(
            //         text: 'Withdraw Money'.tr,
            //         onPressed: () => Get.to(() => const WithdrawalScreen()),
            //         backgroundColor: AppColors.primaryColor,
            //         borderRadius: 12,
            //         height: 46,
            //       ),
            //     ),
            //   ],
            // ),
          ],
        );
      }),
    );
  }

  Widget _buildCompactEarningsRow() {
    return Obx(() {
      final summary = _walletController.summary.value;
      return Row(
        children: [
          Expanded(
            child: _buildSimpleInfoCard(
              'Last 3 Months Earnings'.tr,
              summary != null ? '₹${summary.threeMonthEarning}' : '-',
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _buildSimpleInfoCard(
              'Monthly Earnings'.tr,
              summary != null ? '₹${summary.monthlyEarning}' : '-',
            ),
          ),
        ],
      );
    });
  }

  Widget _buildSimpleInfoCard(String title, String value) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade100),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AppText(title.tr, fontSize: 13, fontWeight: FontWeight.bold),
          const SizedBox(height: 12),
          AppText(
            value,
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.green.shade600,
          ),
        ],
      ),
    );
  }

  Widget _buildWeeklyEarningsCard() {
    return GestureDetector(
      onTap: () => Get.to(() => WeeklyRankingScreen()),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey.shade100),
        ),
        child: Obx(() {
          final summary = _walletController.summary.value;
          return Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  AppText(
                    'Weekly Earnings'.tr,
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                  AppText(
                    'Rank'.tr,
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Colors.amber.shade600,
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  AppText(
                    summary != null ? '₹${summary.weeklyEarning}' : '-',
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.green.shade600,
                  ),
                  Row(
                    children: [
                      AppText(
                        summary != null ? '#${summary.rank}' : '-',
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                      const SizedBox(width: 8),
                      Icon(
                        Icons.arrow_forward_ios_rounded,
                        size: 20,
                        color: Colors.grey.shade400,
                      ),
                    ],
                  ),
                ],
              ),
            ],
          );
        }),
      ),
    );
  }

  Widget _buildTransactionList() {
    return Obx(() {
      if (_walletController.isLoadingEarnings.value &&
          _walletController.earningsList.isEmpty) {
        return const Center(child: CircularProgressIndicator());
      }
      if (_walletController.earningsList.isEmpty) {
        return Center(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: AppText('No earnings found.'.tr),
          ),
        );
      }
      return ListView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: _walletController.earningsList.length,
        itemBuilder: (context, index) {
          final tx = _walletController.earningsList[index];
          String name = 'User';
          String model = tx.description;

          if (tx.meta != null) {
            name = tx.meta!['user_name'] ?? 'User';
            model = tx.meta!['service_type'] ?? tx.description;
          }

          String formattedDate = '';
          try {
            if (tx.createdAt.isNotEmpty) {
              final dt = DateTime.parse(tx.createdAt).toLocal();
              formattedDate = DateFormat('dd MMM yy, hh:mm a').format(dt);
            }
          } catch (_) {}

          return Container(
            margin: const EdgeInsets.only(bottom: 10),
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.grey.shade100),
            ),
            child: Row(
              children: [
                Container(
                  height: 44,
                  width: 44,
                  decoration: BoxDecoration(
                    color: AppColors.primaryColor.withOpacity(0.05),
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: AppText(
                      name.isNotEmpty ? name[0].toUpperCase() : 'U',
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: AppColors.primaryColor,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      AppText(
                        name,
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFF2E1A47),
                      ),
                      const SizedBox(height: 2),
                      AppText(
                        model,
                        fontSize: 11,
                        color: Colors.grey.shade500,
                        fontWeight: FontWeight.w500,
                      ),
                      if (formattedDate.isNotEmpty) ...[
                        const SizedBox(height: 2),
                        AppText(
                          formattedDate,
                          fontSize: 10,
                          color: Colors.grey.shade400,
                          fontWeight: FontWeight.w600,
                        ),
                      ],
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    AppText(
                      '+₹${tx.amount}',
                      fontSize: 15,
                      fontWeight: FontWeight.w800,
                      color: AppColors.successColor,
                    ),
                    const SizedBox(height: 2),
                    AppText(
                      tx.status.capitalizeFirst ?? tx.status,
                      fontSize: 10,
                      color: AppColors.successColor,
                      fontWeight: FontWeight.w700,
                    ),
                  ],
                ),
              ],
            ),
          );
        },
      );
    });
  }

  Widget _buildWithdrawalHistoryList() {
    return Obx(() {
      if (_walletController.isLoadingWithdrawals.value &&
          _walletController.withdrawalsList.isEmpty) {
        return const Center(child: CircularProgressIndicator());
      }
      if (_walletController.withdrawalsList.isEmpty) {
        return Center(
          child: Padding(
            padding: EdgeInsets.all(20),
            child: AppText('No withdrawals found.'.tr),
          ),
        );
      }
      return ListView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: _walletController.withdrawalsList.length,
        itemBuilder: (context, index) {
          final w = _walletController.withdrawalsList[index];
          final bool isPending = w.status.toLowerCase() == 'pending';

          String bankInfo = 'Bank Transfer';
          if (w.meta != null && w.meta!['bank_name'] != null) {
            bankInfo = w.meta!['bank_name'];
          }

          return Container(
            margin: const EdgeInsets.only(bottom: 10),
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.grey.shade100),
            ),
            child: Row(
              children: [
                Container(
                  height: 44,
                  width: 44,
                  decoration: BoxDecoration(
                    color: (isPending ? Colors.orange : Colors.blue)
                        .withOpacity(0.05),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    isPending ? Iconsax.timer_copy : Iconsax.tick_circle_copy,
                    color: isPending ? Colors.orange : Colors.blue,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      AppText('Withdrawal'.tr,
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFF2E1A47),
                      ),
                      const SizedBox(height: 2),
                      AppText(
                        bankInfo,
                        fontSize: 11,
                        color: Colors.grey.shade500,
                        fontWeight: FontWeight.w500,
                      ),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    AppText(
                      '₹${w.amount}',
                      fontSize: 15,
                      fontWeight: FontWeight.w800,
                      color: const Color(0xFF2E1A47),
                    ),
                    const SizedBox(height: 2),
                    AppText(
                      w.status.capitalizeFirst ?? w.status,
                      fontSize: 10,
                      color: isPending ? Colors.orange : Colors.green,
                      fontWeight: FontWeight.w700,
                    ),
                  ],
                ),
              ],
            ),
          );
        },
      );
    });
  }

  Widget _buildTabToggle() {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildTabButton('Earnings'),
          // _buildTabButton('Withdrawals'), // Disabled as settlements are processed directly by admin
        ],
      ),
    );
  }

  Widget _buildTabButton(String title) {
    bool isActive = _activeTab == title;
    return GestureDetector(
      onTap: () => setState(() => _activeTab = title),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isActive ? AppColors.primaryColor : Colors.transparent,
          borderRadius: BorderRadius.circular(10),
          boxShadow:
              isActive
                  ? [
                    BoxShadow(
                      color: AppColors.primaryColor.withOpacity(0.2),
                      blurRadius: 4,
                    ),
                  ]
                  : [],
        ),
        child: AppText(
          title.tr,
          fontSize: 12,
          fontWeight: FontWeight.w700,
          color: isActive ? Colors.white : Colors.grey.shade500,
        ),
      ),
    );
  }

  Widget _buildFilterDropdown() {
    return Obx(() {
      return PopupMenuButton<String>(
        onSelected: (String value) {
          _walletController.fetchEarnings(filter: value, isRefresh: true);
        },
        itemBuilder:
            (BuildContext context) => <PopupMenuEntry<String>>[
              PopupMenuItem<String>(
                value: 'Today',
                child: AppText('Today'.tr, fontSize: 13),
              ),
              PopupMenuItem<String>(
                value: 'Weekly',
                child: AppText('Weekly'.tr, fontSize: 13),
              ),
              PopupMenuItem<String>(
                value: 'Monthly',
                child: AppText('Monthly'.tr, fontSize: 13),
              ),
            ],
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(100),
            border: Border.all(color: Colors.grey.shade200),
          ),
          child: Row(
            children: [
              AppText(
                _walletController.selectedEarningFilter.value.tr,
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: AppColors.primaryColor,
              ),
              const SizedBox(width: 4),
              const Icon(
                Icons.keyboard_arrow_down_rounded,
                size: 14,
                color: AppColors.primaryColor,
              ),
            ],
          ),
        ),
      );
    });
  }
}
