import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/app_text.dart';
import '../../../core/widgets/custom_app_bar.dart';
import 'weekly_ranking_screen.dart';

class AstromallEarningsScreen extends StatefulWidget {
  const AstromallEarningsScreen({super.key});

  @override
  State<AstromallEarningsScreen> createState() => _AstromallEarningsScreenState();
}

class _AstromallEarningsScreenState extends State<AstromallEarningsScreen> {
  String _selectedPeriod = 'Today';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.fieldBackground,
      appBar: const CustomAppBar(
        title: 'Astromall Earnings',
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildTopEarningsRow(),
              const SizedBox(height: 12),
              _buildWeeklyRankCard(),
              const SizedBox(height: 12),
              _buildPeriodSelector(),
              const SizedBox(height: 12),
              _buildPerformanceGrid(),
              const SizedBox(height: 40),
              const Center(
                child: AppText(
                  'No Data Available',
                  fontSize: 16,
                  color: AppColors.accentColor,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 100),
              Center(
                child: AppText(
                  'Pending Earnings based on last 30 days only',
                  fontSize: 12,
                  color: Colors.grey.shade500,
                  textAlign: TextAlign.center,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTopEarningsRow() {
    return Row(
      children: [
        Expanded(child: _buildMetricCard('Last 3 Months Earnings', '₹0')),
        const SizedBox(width: 12),
        Expanded(
          child: GestureDetector(
            onTap: () {
              // Action for pending earnings if needed
            },
            child: _buildMetricCard('Pending Earnings', '₹0', showArrow: true),
          ),
        ),
      ],
    );
  }

  Widget _buildWeeklyRankCard() {
    return GestureDetector(
      onTap: () => Get.to(() => const WeeklyRankingScreen()),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey.shade100),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                AppText('Weekly Earnings', fontSize: 13, fontWeight: FontWeight.bold),
                SizedBox(height: 8),
                AppText('₹0', fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.successColor),
              ],
            ),
            Row(
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: const [
                    AppText('Rank', fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.goldAccent),
                    SizedBox(height: 4),
                    AppText('5629', fontSize: 16, fontWeight: FontWeight.bold),
                  ],
                ),
                const SizedBox(width: 8),
                Icon(Icons.arrow_forward_ios_rounded, size: 18, color: Colors.grey.shade300),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMetricCard(String title, String value, {bool showArrow = false}) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade100),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AppText(title, fontSize: 12, fontWeight: FontWeight.bold),
                const SizedBox(height: 8),
                AppText(value, fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.successColor),
              ],
            ),
          ),
          if (showArrow) Icon(Icons.arrow_forward_ios_rounded, size: 18, color: Colors.grey.shade300),
        ],
      ),
    );
  }

  Widget _buildPeriodSelector() {
    return PopupMenuButton<String>(
      onSelected: (String value) {
        setState(() {
          _selectedPeriod = value;
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
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const SizedBox(width: 24), // Spacer to center text
            AppText(_selectedPeriod, fontSize: 15, fontWeight: FontWeight.bold, color: AppColors.primaryColor),
            const Icon(Icons.arrow_drop_down, color: Colors.grey),
          ],
        ),
      ),
    );
  }

  Widget _buildPerformanceGrid() {
    return Column(
      children: [
        Row(
          children: [
            Expanded(child: _buildMetricCard('Earnings', '₹0')),
            const SizedBox(width: 12),
            Expanded(child: _buildMetricCard('Orders', '0')),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(child: _buildMetricCard('Product Earnings', '₹0')),
            const SizedBox(width: 12),
            Expanded(child: _buildMetricCard('Services Earnings', '₹0')),
          ],
        ),
      ],
    );
  }
}
