import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:astro_astrologer/core/theme/app_colors.dart';
import 'package:astro_astrologer/core/widgets/app_text.dart';
import 'package:astro_astrologer/core/widgets/custom_app_bar.dart';
import 'package:astro_astrologer/features/wallet/domain/repositories/i_wallet_repository.dart';
import 'package:astro_astrologer/features/wallet/presentation/controllers/weekly_ranking_controller.dart';
import 'package:astro_astrologer/features/wallet/domain/models/weekly_ranking_model.dart';

import 'package:astro_astrologer/features/wallet/data/repositories/wallet_repository_impl.dart';
import 'package:astro_astrologer/core/services/network/api_client.dart';

class WeeklyRankingScreen extends StatelessWidget {
  WeeklyRankingScreen({super.key});

  final WeeklyRankingController controller = Get.put(
    WeeklyRankingController(WalletRepositoryImpl(apiClient: Get.find<ApiClient>())),
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: const CustomAppBar(
        title: 'Weekly Ranking',
        centerTitle: true,
      ),
      body: Obx(() {
        if (controller.isLoading.value && controller.rankingData.value == null) {
          return const Center(
            child: CircularProgressIndicator(color: AppColors.primaryColor),
          );
        }

        if (controller.error.value.isNotEmpty && controller.rankingData.value == null) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                AppText(controller.error.value, color: Colors.red),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: controller.fetchRankings,
                  style: ElevatedButton.styleFrom(backgroundColor: AppColors.primaryColor),
                  child: const AppText('Retry', color: Colors.white),
                )
              ],
            ),
          );
        }

        final data = controller.rankingData.value;
        if (data == null) {
          return const Center(child: AppText('No ranking data available'));
        }

        return Column(
            children: [
              // Header description
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                color: const Color(0xFFF8F8F8),
                child: const AppText(
                  'Earnings in this week (Monday to Sunday)',
                  textAlign: TextAlign.center,
                  fontSize: 13,
                  color: Colors.black87,
                ),
              ),
              
              // Table Header
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  border: Border(bottom: BorderSide(color: Colors.grey.shade300)),
                ),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    AppText('Rank', fontSize: 16, color: Colors.black54, fontWeight: FontWeight.w500),
                    AppText('Earning', fontSize: 16, color: Colors.black54, fontWeight: FontWeight.w500),
                  ],
                ),
              ),

              // Ranking List
              Expanded(
                child: RefreshIndicator(
                  color: AppColors.primaryColor,
                  onRefresh: () async {
                    await controller.fetchRankings();
                  },
                  child: ListView.separated(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.only(bottom: 20),
                    itemCount: data.topAstrologers.length,
                    separatorBuilder: (context, index) => Divider(color: Colors.grey.shade200, height: 1),
                    itemBuilder: (context, index) {
                      final astrologer = data.topAstrologers[index];
                      return _buildRankingRow(astrologer);
                    },
                  ),
                ),
              ),

              // Sticky Bottom Sheet
              if (data.myRank != null && data.myWeeklyEarnings != null)
                _buildStickyBottomBar(data),
            ],
          );
      }),
    );
  }

  Widget _buildRankingRow(WeeklyRankingModel astrologer) {
    bool isTopThree = astrologer.rank <= 3;
    
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              if (isTopThree)
                Container(
                  width: 28,
                  height: 28,
                  decoration: const BoxDecoration(
                    color: Color(0xFFFFD700), // Gold/Yellow
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.star, color: Colors.white, size: 18),
                )
              else
                const SizedBox(
                  width: 28,
                  height: 28,
                  child: Icon(Icons.emoji_events, color: Color(0xFFFFD700), size: 24), // Trophy
                ),
              const SizedBox(width: 16),
              AppText(
                '${astrologer.rank}',
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ],
          ),
          Row(
            children: [
              AppText(
                '₹${astrologer.weeklyEarnings.toStringAsFixed(0)}',
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: Colors.black87,
              ),
              const SizedBox(width: 8),
              // Direction indicator
              Icon(
                astrologer.weeklyEarnings > 0 ? Icons.arrow_drop_up : Icons.remove,
                color: astrologer.weeklyEarnings > 0 ? Colors.green : Colors.grey,
                size: 20,
              )
            ],
          )
        ],
      ),
    );
  }

  Widget _buildStickyBottomBar(WeeklyRankingData data) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            offset: const Offset(0, -4),
            blurRadius: 8,
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const AppText('Your Weekly Earning', fontSize: 13, color: Colors.grey),
              AppText('Your Rank', fontSize: 13, color: AppColors.primaryColor, fontWeight: FontWeight.w600),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              // User logic: Try to get from auth or rely on the data provided? The data has 'my_rank' and 'my_weekly_earnings', but not my name.
              // In the screenshot, it shows Profile Photo, Name, and Rank (562). Earning is on top maybe? Wait.
              // I'll show it like: Photo, Name, and then right aligned: Rank number.
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.grey.shade200,
                  image: const DecorationImage(
                    image: AssetImage('assets/images/placeholder_profile.png'), // Need a fallback
                    fit: BoxFit.cover,
                  ),
                ),
                child: const Icon(Icons.person, color: Colors.grey),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // We don't have astrologer's own name in the /weekly-rankings endpoint, only their rank and earnings.
                  // We can fetch from AuthController if available, or just say 'My Profile'.
                  const AppText(
                    'My Profile',
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                  AppText(
                    '₹${data.myWeeklyEarnings?.toStringAsFixed(0) ?? 0}',
                    fontSize: 13,
                    color: Colors.grey,
                  ),
                ],
              ),
              const Spacer(),
              AppText(
                '${data.myRank ?? '-'}',
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ],
          ),
        ],
      ),
    );
  }
}
