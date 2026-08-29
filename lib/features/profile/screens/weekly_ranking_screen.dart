import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:astro_astrologer/core/constants/app_urls.dart';
import 'package:astro_astrologer/core/theme/app_colors.dart';
import 'package:astro_astrologer/core/widgets/app_text.dart';
import 'package:astro_astrologer/core/widgets/custom_app_bar.dart';
import 'package:astro_astrologer/features/auth/controllers/auth_controller.dart';
import 'package:astro_astrologer/features/wallet/presentation/controllers/weekly_ranking_controller.dart';
import 'package:astro_astrologer/features/wallet/domain/models/weekly_ranking_model.dart';
import 'package:astro_astrologer/features/wallet/data/repositories/wallet_repository_impl.dart';
import 'package:astro_astrologer/core/services/network/api_client.dart';
import 'package:astro_astrologer/core/widgets/custom_image_widget.dart';

class WeeklyRankingScreen extends StatelessWidget {
  WeeklyRankingScreen({super.key}) {
    if (!Get.isRegistered<WeeklyRankingController>()) {
      Get.put(
        WeeklyRankingController(
          WalletRepositoryImpl(apiClient: Get.find<ApiClient>()),
        ),
      );
    }
  }

  WeeklyRankingController get controller => Get.find<WeeklyRankingController>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: CustomAppBar(title: 'Weekly Ranking'.tr, centerTitle: true),
      body: Obx(() {
        if (controller.isLoading.value &&
            controller.rankingData.value == null) {
          return const Center(
            child: CircularProgressIndicator(color: AppColors.primaryColor),
          );
        }

        if (controller.error.value.isNotEmpty &&
            controller.rankingData.value == null) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                AppText(controller.error.value, color: Colors.red),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: controller.fetchRankings,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryColor,
                  ),
                  child: AppText('Retry'.tr, color: Colors.white),
                ),
              ],
            ),
          );
        }

        final data = controller.rankingData.value;
        if (data == null) {
          return Center(child: AppText('No ranking data available'.tr));
        }

        return Column(
          children: [
            // Header
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
              color: const Color(0xFFF8F8F8),
              child: AppText(
                'Earnings in this week (Monday to Sunday)'.tr,
                textAlign: TextAlign.center,
                fontSize: 13,
                color: Colors.black87,
              ),
            ),

            // Table header
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border(bottom: BorderSide(color: Colors.grey.shade300)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  AppText(
                    'Rank'.tr,
                    fontSize: 16,
                    color: Colors.black54,
                    fontWeight: FontWeight.w500,
                  ),
                  AppText(
                    'Earning'.tr,
                    fontSize: 16,
                    color: Colors.black54,
                    fontWeight: FontWeight.w500,
                  ),
                ],
              ),
            ),

            // Ranking list
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
                  separatorBuilder:
                      (context, index) =>
                          Divider(color: Colors.grey.shade200, height: 1),
                  itemBuilder: (context, index) {
                    final astrologer = data.topAstrologers[index];
                    return _buildRankingRow(astrologer);
                  },
                ),
              ),
            ),

            // Sticky bottom bar
            if (data.myRank != null && data.myWeeklyEarnings != null)
              _buildStickyBottomBar(data),
          ],
        );
      }),
    );
  }

  String _toTitleCase(String text) {
    if (text.isEmpty) return text;
    return text
        .split(' ')
        .map(
          (w) =>
              w.isNotEmpty
                  ? '${w[0].toUpperCase()}${w.substring(1).toLowerCase()}'
                  : '',
        )
        .join(' ');
  }

  Widget _buildAvatar({
    required String name,
    required String? rawPhoto,
    double radius = 20,
  }) {
    final photoUrl =
        rawPhoto != null && rawPhoto.isNotEmpty
            ? (rawPhoto.startsWith('http')
                ? rawPhoto
                : '${AppUrls.baseImageUrl}$rawPhoto')
            : null;
    final initials = name.isNotEmpty ? name[0].toUpperCase() : '?';

    Widget letterWidget = AppText(
      initials,
      fontSize: radius * 0.8,
      fontWeight: FontWeight.bold,
      color: AppColors.primaryColor,
    );

    return CircleAvatar(
      radius: radius,
      backgroundColor: AppColors.primaryColor.withValues(alpha: 0.15),
      child:
          photoUrl != null
              ? ClipOval(
                child: CustomImageWidget(
                  imagePath: photoUrl,
                  width: radius * 2,
                  height: radius * 2,
                  fit: BoxFit.cover,
                  // Image load fail ho to letter dikhao
                  errorBuilder: (_, __, ___) => letterWidget,
                  // Load hone tak bhi letter dikhao
                  loadingBuilder:
                      (_, child, progress) =>
                          progress == null ? child : letterWidget,
                ),
              )
              : letterWidget,
    );
  }

  Widget _buildRankingRow(WeeklyRankingModel astrologer) {
    final bool isTopThree = astrologer.rank <= 3;
    final titleName = _toTitleCase(astrologer.name);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10.0),
      child: Row(
        children: [
          // Rank badge (star or trophy)
          SizedBox(
            width: 28,
            height: 28,
            child:
                isTopThree
                    ? Container(
                      decoration: const BoxDecoration(
                        color: Color(0xFFFFD700),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.star,
                        color: Colors.white,
                        size: 18,
                      ),
                    )
                    : const Icon(
                      Icons.emoji_events,
                      color: Color(0xFFFFD700),
                      size: 24,
                    ),
          ),
          const SizedBox(width: 10),

          // Rank number
          SizedBox(
            width: 22,
            child: AppText(
              '${astrologer.rank}',
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: Colors.black87,
            ),
          ),
          const SizedBox(width: 10),

          // Avatar
          _buildAvatar(
            name: astrologer.name,
            rawPhoto: astrologer.profilePhoto,
          ),
          const SizedBox(width: 10),

          // Name
          Expanded(
            child: AppText(
              titleName,
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: Colors.black87,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),

          // Earnings + arrow
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              AppText(
                '₹${astrologer.weeklyEarnings.toStringAsFixed(0)}',
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: Colors.black87,
              ),
              const SizedBox(width: 4),
              Icon(
                astrologer.weeklyEarnings > 0
                    ? Icons.arrow_drop_up
                    : Icons.remove,
                color:
                    astrologer.weeklyEarnings > 0 ? Colors.green : Colors.grey,
                size: 20,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStickyBottomBar(WeeklyRankingData data) {
    final authController = Get.find<AuthController>();
    final user = authController.currentUser.value;
    final name = user?.name ?? 'My Profile';
    final rawPhoto = user?.astrologer?.profilePhoto ?? user?.profilePhoto;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            offset: const Offset(0, -4),
            blurRadius: 8,
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                AppText(
                  'Your Weekly Earning'.tr,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
                AppText(
                  'Your Rank'.tr,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: AppColors.goldAccent,
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                _buildAvatar(name: name, rawPhoto: rawPhoto),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      AppText(
                        name,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                      AppText(
                        '₹${data.myWeeklyEarnings?.toStringAsFixed(0) ?? '0'}',
                        fontSize: 13,
                        color: Colors.grey,
                      ),
                    ],
                  ),
                ),
                AppText(
                  '${data.myRank ?? '-'}',
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
