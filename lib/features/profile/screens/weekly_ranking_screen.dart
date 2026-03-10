import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/app_text.dart';
import '../../../core/widgets/custom_app_bar.dart';

class WeeklyRankingScreen extends StatefulWidget {
  const WeeklyRankingScreen({super.key});

  @override
  State<WeeklyRankingScreen> createState() => _WeeklyRankingScreenState();
}

class _WeeklyRankingScreenState extends State<WeeklyRankingScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: const CustomAppBar(
        title: 'Weekly Ranking',
        centerTitle: true,
      ),
      body: Column(
        children: [
          _buildTabBar(),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildRankList('Astrotalk Earning (without Astromall) in this week (Monday to Sunday)'),
                _buildRankList('Earning from Astromall in this week (Monday to Sunday)'),
              ],
            ),
          ),
          _buildStickyFooter(),
        ],
      ),
    );
  }

  Widget _buildTabBar() {
    return Container(
      color: Colors.white,
      width: double.infinity,
      child: TabBar(
        controller: _tabController,
        isScrollable: false,
        dividerColor: Colors.grey.shade300,
        labelColor: Colors.black,
        unselectedLabelColor: Colors.grey,
        indicatorColor: AppColors.primaryColor,
        indicatorSize: TabBarIndicatorSize.tab,
        labelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, fontFamily: 'Poppins'),
        unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.normal, fontSize: 13, fontFamily: 'Poppins'),
        tabs: const [
          Tab(text: 'Astrotalk'),
          Tab(text: 'Astromall'),
        ],
      ),
    );
  }

  Widget _buildRankList(String subTitle) {
    return Column(
      children: [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          color: AppColors.fieldBackground,
          child: AppText(
            subTitle,
            fontSize: 11,
            color: Colors.black87,
            textAlign: TextAlign.center,
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              AppText('Rank', fontSize: 16, fontWeight: FontWeight.bold, color: Colors.grey.shade600),
              AppText('Earning', fontSize: 16, fontWeight: FontWeight.bold, color: Colors.grey.shade600),
            ],
          ),
        ),
        const Divider(height: 1),
        Expanded(
          child: ListView.separated(
            itemCount: 20,
            separatorBuilder: (context, index) => const Divider(height: 1, color: Color(0xFFF9F9F9)),
            itemBuilder: (context, index) {
              int rank = index + 1;
              return Container(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  border: Border(bottom: BorderSide(color: Colors.grey.shade100)),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        _buildRankIcon(rank),
                        const SizedBox(width: 12),
                        AppText(rank.toString(), fontSize: 16, fontWeight: FontWeight.w600, color: Colors.black87),
                      ],
                    ),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const AppText('-', fontSize: 16, fontWeight: FontWeight.w600, color: Colors.black87),
                        const SizedBox(width: 8),
                        Icon(
                          index % 3 == 0 ? Icons.arrow_drop_up_rounded : Icons.arrow_drop_down_rounded,
                          color: index % 3 == 0 ? AppColors.successColor : AppColors.errorColor,
                          size: 24,
                        ),
                      ],
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildRankIcon(int rank) {
    if (rank <= 3) {
      return Container(
        width: 28,
        height: 28,
        decoration: const BoxDecoration(
          color: AppColors.goldAccent,
          shape: BoxShape.circle,
        ),
        child: const Center(
          child: Icon(Icons.star_rounded, color: Colors.white, size: 20),
        ),
      );
    } else if (rank <= 9) {
      return const Icon(Icons.emoji_events_rounded, color: AppColors.goldAccent, size: 28);
    }
    return const SizedBox(width: 28);
  }

  Widget _buildStickyFooter() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: const [
                AppText('Your Weekly Earning', fontSize: 12, fontWeight: FontWeight.bold),
                AppText('Your Rank', fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.goldAccent),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                const CircleAvatar(
                  radius: 20,
                  backgroundImage: NetworkImage('https://i.pravatar.cc/100?u=astrologer'),
                ),
                const SizedBox(width: 12),
                const Expanded(
                  child: AppText(
                    'Saurabh Sawant',
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey,
                  ),
                ),
                const AppText(
                  '5629',
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
