import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/app_text.dart';
import '../../../core/widgets/custom_button.dart';
import '../../../core/widgets/custom_app_bar.dart';
import '../../finance/withdrawal_screen.dart';
import 'weekly_ranking_screen.dart';
import 'astromall_earnings_screen.dart';
import '../widgets/earning_breakup_bottom_sheet.dart';

class MyEarningsScreen extends StatefulWidget {
  const MyEarningsScreen({super.key});

  @override
  State<MyEarningsScreen> createState() => _MyEarningsScreenState();
}

class _MyEarningsScreenState extends State<MyEarningsScreen> {
  String _selectedFilter = 'Monthly';
  String _selectedPeriod = 'Today';
  String _activeTab = 'Earnings';

  // Mock data for transactions
  final List<Map<String, dynamic>> _transactions = [
    {'name': 'Rahul Sharma', 'mode': 'Chat', 'date': 'Today, 04:30 PM', 'amount': '150', 'status': 'Paid'},
    {'name': 'Priya Patel', 'mode': 'Call', 'date': 'Today, 02:15 PM', 'amount': '420', 'status': 'Paid'},
    {'name': 'Amit Kumar', 'mode': 'Video', 'date': 'Yesterday', 'amount': '900', 'status': 'Paid'},
    {'name': 'Sneha Reddy', 'mode': 'Chat', 'date': 'Yesterday', 'amount': '225', 'status': 'Paid'},
    {'name': 'Vikram Singh', 'mode': 'Call', 'date': '17 Feb 2026', 'amount': '350', 'status': 'Paid'},
  ];

  final List<Map<String, dynamic>> _withdrawals = [
    {'bank': 'HDFC Bank', 'acc': '**** 4512', 'date': 'Today, 11:00 AM', 'amount': '2000', 'status': 'Pending'},
    {'bank': 'HDFC Bank', 'acc': '**** 4512', 'date': '15 Feb 2026', 'amount': '5000', 'status': 'Completed'},
    {'bank': 'HDFC Bank', 'acc': '**** 4512', 'date': '10 Feb 2026', 'amount': '3000', 'status': 'Completed'},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.fieldBackground,
      appBar: const CustomAppBar(
        title: 'My Earnings',
      ),
      body: SingleChildScrollView(
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
                  const SizedBox(height: 12),
                  _buildPeriodSelector(),
                  const SizedBox(height: 12),
                  _buildBalancePayableCard(),
                  const SizedBox(height: 12),
                  _buildAstromallEarningsCard(),
                  const SizedBox(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _buildTabToggle(),
                      if (_activeTab == 'Earnings') _buildFilterDropdown(),
                    ],
                  ),
                  const SizedBox(height: 12),
                  _activeTab == 'Earnings' ? _buildTransactionList() : _buildWithdrawalHistoryList(),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ],
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  AppText('Total Balance', fontSize: 13, color: Colors.white.withOpacity(0.7), fontWeight: FontWeight.w500),
                  const SizedBox(height: 4),
                  const AppText('₹12,450.00', fontSize: 28, fontWeight: FontWeight.w800, color: Colors.white),
                ],
              ),
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Iconsax.wallet_2_copy, color: Colors.white, size: 24),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: CustomButton(
                  text: 'Withdraw Money',
                  onPressed: () => Get.to(() => const WithdrawalScreen()),
                  backgroundColor: AppColors.primaryColor,
                  borderRadius: 12,
                  height: 46,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCompactEarningsRow() {
    return Row(
      children: [
        Expanded(child: _buildSimpleInfoCard('Last 3 Months Earnings', '-')),
        const SizedBox(width: 12),
        Expanded(child: _buildSimpleInfoCard('Monthly Earnings', '-')),
      ],
    );
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
          AppText(title, fontSize: 13, fontWeight: FontWeight.bold),
          const SizedBox(height: 12),
          AppText(value, fontSize: 16, fontWeight: FontWeight.bold, color: Colors.green.shade600),
        ],
      ),
    );
  }

  Widget _buildWeeklyEarningsCard() {
    return GestureDetector(
      onTap: () => Get.to(() => const WeeklyRankingScreen()),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey.shade100),
        ),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const AppText('Weekly Earnings', fontSize: 14, fontWeight: FontWeight.bold),
                AppText('Rank', fontSize: 14, fontWeight: FontWeight.bold, color: Colors.amber.shade600),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                AppText('-', fontSize: 18, fontWeight: FontWeight.bold, color: Colors.green.shade600),
                Row(
                  children: [
                    const AppText('-', fontSize: 18, fontWeight: FontWeight.bold),
                    const SizedBox(width: 8),
                    Icon(Icons.arrow_forward_ios_rounded, size: 20, color: Colors.grey.shade400),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPeriodSelector() {
    return PopupMenuButton<String>(
      onSelected: (String value) {
        setState(() {
          _selectedPeriod = value;
          // You can trigger actual filtering logic here
        });
      },
      itemBuilder: (context) => [
        const PopupMenuItem(value: 'Today', child: AppText('Today')),
        const PopupMenuItem(value: 'Weekly', child: AppText('Weekly')),
        const PopupMenuItem(value: 'Monthly', child: AppText('Monthly')),
        const PopupMenuItem(value: 'Last 3 Months', child: AppText('Last 3 Months')),
      ],
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: Colors.grey.shade300),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            AppText(_selectedPeriod, fontSize: 15, fontWeight: FontWeight.bold, color: AppColors.primaryColor),
            const SizedBox(width: 8),
            const Icon(Icons.arrow_drop_down, color: Colors.grey),
          ],
        ),
      ),
    );
  }

  Widget _buildBalancePayableCard() {
    return GestureDetector(
      onTap: () {
        showModalBottomSheet(
          context: context,
          isScrollControlled: true,
          backgroundColor: Colors.transparent,
          builder: (context) => const EarningBreakupBottomSheet(),
        );
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey.shade100),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const AppText('Available Balance', fontSize: 14, fontWeight: FontWeight.bold),
                  const SizedBox(height: 8),
                  AppText('₹129', fontSize: 20, fontWeight: FontWeight.bold, color: AppColors.successColor),
                ],
              ),
            ),
            Container(width: 1, height: 40, color: Colors.grey.shade200),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const AppText('Payable Amount', fontSize: 14, fontWeight: FontWeight.bold),
                  const SizedBox(height: 8),
                  AppText('₹113', fontSize: 20, fontWeight: FontWeight.bold, color: AppColors.successColor),
                ],
              ),
            ),
            Icon(Icons.arrow_forward_ios_rounded, size: 20, color: Colors.grey.shade400),
          ],
        ),
      ),
    );
  }

  Widget _buildAstromallEarningsCard() {
    return GestureDetector(
      onTap: () => Get.to(() => const AstromallEarningsScreen()),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey.shade100),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const AppText("Today's Astromall", fontSize: 14, fontWeight: FontWeight.bold),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const AppText('Earnings', fontSize: 14, fontWeight: FontWeight.bold),
                      const SizedBox(height: 8),
                      AppText('₹0', fontSize: 20, fontWeight: FontWeight.bold, color: AppColors.successColor),
                    ],
                  ),
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const AppText('Pending Earnings', fontSize: 14, fontWeight: FontWeight.bold),
                      const SizedBox(height: 8),
                      AppText('₹0', fontSize: 20, fontWeight: FontWeight.bold, color: AppColors.successColor),
                    ],
                  ),
                ),
                Icon(Icons.arrow_forward_ios_rounded, size: 20, color: Colors.grey.shade400),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTransactionList() {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: _transactions.length,
      itemBuilder: (context, index) {
        final tx = _transactions[index];
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
                    tx['name'][0],
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
                    AppText(tx['name'], fontSize: 14, fontWeight: FontWeight.w700, color: const Color(0xFF2E1A47)),
                    const SizedBox(height: 2),
                    AppText('${tx['mode']} • ${tx['date']}', fontSize: 11, color: Colors.grey.shade500, fontWeight: FontWeight.w500),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  AppText('+₹${tx['amount']}', fontSize: 15, fontWeight: FontWeight.w800, color: AppColors.successColor),
                  const SizedBox(height: 2),
                  AppText(tx['status'], fontSize: 10, color: AppColors.successColor, fontWeight: FontWeight.w700),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildWithdrawalHistoryList() {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: _withdrawals.length,
      itemBuilder: (context, index) {
        final w = _withdrawals[index];
        final bool isPending = w['status'] == 'Pending';
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
                  color: (isPending ? Colors.orange : Colors.blue).withOpacity(0.05),
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
                    AppText('Withdrawal', fontSize: 14, fontWeight: FontWeight.w700, color: const Color(0xFF2E1A47)),
                    const SizedBox(height: 2),
                    AppText('${w['bank']} • ${w['date']}', fontSize: 11, color: Colors.grey.shade500, fontWeight: FontWeight.w500),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  AppText('₹${w['amount']}', fontSize: 15, fontWeight: FontWeight.w800, color: const Color(0xFF2E1A47)),
                  const SizedBox(height: 2),
                  AppText(w['status'], fontSize: 10, color: isPending ? Colors.orange : Colors.green, fontWeight: FontWeight.w700),
                ],
              ),
            ],
          ),
        );
      },
    );
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
          _buildTabButton('Withdrawals'),
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
          boxShadow: isActive ? [BoxShadow(color: AppColors.primaryColor.withOpacity(0.2), blurRadius: 4)] : [],
        ),
        child: AppText(
          title,
          fontSize: 12,
          fontWeight: FontWeight.w700,
          color: isActive ? Colors.white : Colors.grey.shade500,
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return AppText(
      title,
      fontSize: 12,
      fontWeight: FontWeight.w800,
      color: Colors.grey.shade400,
      letterSpacing: 0.5,
    );
  }

  Widget _buildFilterDropdown() {
    return PopupMenuButton<String>(
      onSelected: (String value) {
        setState(() {
          _selectedFilter = value;
        });
      },
      itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
        const PopupMenuItem<String>(value: 'Today', child: AppText('Today', fontSize: 13)),
        const PopupMenuItem<String>(value: 'Weekly', child: AppText('Weekly', fontSize: 13)),
        const PopupMenuItem<String>(value: 'Monthly', child: AppText('Monthly', fontSize: 13)),
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
            AppText(_selectedFilter, fontSize: 11, fontWeight: FontWeight.w700, color: AppColors.primaryColor),
            const SizedBox(width: 4),
            const Icon(Icons.keyboard_arrow_down_rounded, size: 14, color: AppColors.primaryColor),
          ],
        ),
      ),
    );
  }
}
