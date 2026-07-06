import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import '../../../core/services/network/api_client.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/app_text.dart';
import '../../../core/widgets/custom_app_bar.dart';
import '../domain/models/performance_model.dart';
import '../data/repositories/performance_repository.dart';
import '../presentation/controllers/performance_controller.dart';

class PerformanceScreen extends StatefulWidget {
  const PerformanceScreen({super.key});

  @override
  State<PerformanceScreen> createState() => _PerformanceScreenState();
}

class _PerformanceScreenState extends State<PerformanceScreen> {
  late PerformanceController controller;

  @override
  void initState() {
    super.initState();
    // Inject dependencies for the screen
    if (!Get.isRegistered<ApiClient>()) {
      Get.lazyPut(() => ApiClient());
    }
    if (!Get.isRegistered<PerformanceRepository>()) {
      Get.lazyPut(() => PerformanceRepository(apiClient: Get.find<ApiClient>()));
    }
    controller = Get.put(PerformanceController(repository: Get.find<PerformanceRepository>()));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9F9F9),
      appBar: const CustomAppBar(
        title: 'My Performance',
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        final data = controller.performanceData.value;
        if (data == null) {
          return Center(
            child: AppText('Failed to load performance data', color: Colors.grey),
          );
        }

        return SingleChildScrollView(
          child: Column(
            children: [
              _buildTierSection(data.badgeType ?? ''),
              const SizedBox(height: 20),
              _buildPerformanceContent(data),
            ],
          ),
        );
      }),
    );
  }

  Widget _buildTierSection(String badgeType) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(30),
          bottomRight: Radius.circular(30),
        ),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildTierLabel('Rising Star', badgeType == 'Rising Star'),
              _buildTierLabel('Top Choice', badgeType == 'Top Choice'),
              _buildTierLabel('Celebrity', badgeType == 'Celebrity'),
            ],
          ),
          const SizedBox(height: 12),
          // Custom Progress Bar
          Container(
            height: 8,
            width: double.infinity,
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              borderRadius: BorderRadius.circular(10),
            ),
            child: FractionallySizedBox(
              alignment: Alignment.centerLeft,
              widthFactor: badgeType == 'Celebrity' ? 1.0 : (badgeType == 'Top Choice' ? 0.6 : 0.2), 
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      AppColors.primaryColor.withOpacity(0.6),
                      AppColors.primaryColor,
                    ],
                  ),
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTierLabel(String label, bool isActive) {
    return Column(
      children: [
        Icon(
          isActive ? Icons.stars_rounded : Icons.radio_button_unchecked_rounded,
          color: isActive ? AppColors.primaryColor : Colors.grey.shade300,
          size: 20,
        ),
        const SizedBox(height: 4),
        AppText(
          label,
          fontSize: 12,
          fontWeight: isActive ? FontWeight.w700 : FontWeight.w500,
          color: isActive ? AppColors.primaryColor : Colors.grey.shade400,
        ),
      ],
    );
  }

  Widget _buildPerformanceContent(PerformanceModel data) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildProfileHealthSection(data.profileHealth),
          const SizedBox(height: 32),
          _buildAvailabilitySection(data.availability),
          const SizedBox(height: 32),
          _buildAvailabilityLink(),
          const SizedBox(height: 32),
          _buildLoyalUserSection(data.loyalUserConversion),
          const SizedBox(height: 40),
        ],
      ),
    );
  }

  Widget _buildProfileHealthSection(ProfileHealth? health) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: AppText(
                "Today's Profile Health",
                fontSize: 16,
                fontWeight: FontWeight.w800,
                color: const Color(0xFF2E1A47),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(100),
                border: Border.all(color: Colors.grey.shade200),
              ),
              child: AppText(
                health?.date ?? '',
                fontSize: 11,
                color: Colors.grey.shade600,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.03),
                blurRadius: 15,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Column(
            children: [
              _buildHealthRow('Total Sessions', '${health?.totalSessions ?? 0}', isFirst: true),
              _buildHealthRow('Missed Sessions', '${health?.missedSessions ?? 0}'),
              _buildHealthRow('Revenue Loss from missed Sessions', '₹${health?.revenueLoss ?? 0.0}', showInfo: true),
              _buildHealthRow('Missed Calls', '${health?.missedCalls ?? 0}'),
              _buildHealthRow('Missed Chats', '${health?.missedChats ?? 0}'),
              _buildHealthRow('Loyal Users', '${health?.loyalUsers ?? 0}', isLast: true),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildHealthRow(String label, String value, {bool showInfo = false, bool isFirst = false, bool isLast = false}) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        border: Border(
          bottom: isLast ? BorderSide.none : BorderSide(color: Colors.grey.shade50),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: Row(
              children: [
                Flexible(
                  child: AppText(
                    label,
                    fontSize: 14,
                    color: Colors.grey.shade700,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                if (showInfo) ...[
                  const SizedBox(width: 6),
                  Icon(Iconsax.info_circle_copy, size: 14, color: Colors.grey.shade400),
                ],
              ],
            ),
          ),
          AppText(
            value,
            fontSize: 15,
            fontWeight: FontWeight.w700,
            color: const Color(0xFF2E1A47),
          ),
        ],
      ),
    );
  }

  Widget _buildAvailabilitySection(AvailabilityData? availability) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AppText(
          "My Availability",
          fontSize: 18,
          fontWeight: FontWeight.w800,
          color: const Color(0xFF2E1A47),
        ),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.03),
                blurRadius: 15,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Column(
            children: [
              // Table Header
              Row(
                children: [
                  const Expanded(flex: 3, child: SizedBox()),
                  Expanded(flex: 2, child: _buildColHeader('Today')),
                  Expanded(flex: 2, child: _buildColHeader('7 Days')),
                  Expanded(flex: 2, child: _buildColHeader('30 days')),
                ],
              ),
              const SizedBox(height: 20),
              _buildAvailabilityRow('Available Mins', 
                '${availability?.availableMins?.today ?? 0} mins', 
                '${availability?.availableMins?.sevenDays ?? 0} mins', 
                '${availability?.availableMins?.thirtyDays ?? 0} mins'
              ),
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 16),
                child: Divider(height: 1),
              ),
              _buildAvailabilityRow('Busy Mins', 
                '${availability?.busyMins?.today ?? 0} mins', 
                '${availability?.busyMins?.sevenDays ?? 0} mins', 
                '${availability?.busyMins?.thirtyDays ?? 0} mins'
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildColHeader(String title) {
    return AppText(
      title,
      fontSize: 12,
      fontWeight: FontWeight.w700,
      color: Colors.grey.shade400,
      textAlign: TextAlign.center,
    );
  }

  Widget _buildAvailabilityRow(String label, String v1, String v2, String v3) {
    return Row(
      children: [
        Expanded(
          flex: 3,
          child: AppText(
            label,
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: Colors.grey.shade700,
          ),
        ),
        Expanded(flex: 2, child: _buildValueText(v1)),
        Expanded(flex: 2, child: _buildValueText(v2)),
        Expanded(flex: 2, child: _buildValueText(v3)),
      ],
    );
  }

  Widget _buildValueText(String value) {
    return AppText(
      value,
      fontSize: 13,
      fontWeight: FontWeight.w700,
      color: const Color(0xFF2E1A47),
      textAlign: TextAlign.center,
    );
  }

  Widget _buildAvailabilityLink() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {},
          borderRadius: BorderRadius.circular(20),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            child: Row(
              children: [
                Expanded(
                  child: AppText(
                    'Check Last 30 Days Availability',
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey.shade700,
                  ),
                ),
                Icon(Iconsax.arrow_right_3_copy, size: 20, color: Colors.grey.shade400),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLoyalUserSection(LoyalUserConversion? conversion) {
    final double percentage = conversion?.conversionPercentage ?? 0.0;
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AppText(
          "Loyal User Conversion",
          fontSize: 16,
          fontWeight: FontWeight.w700,
          color: const Color(0xFF2E1A47),
        ),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: Colors.amber.shade100, width: 2),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  AppText(
                    '$percentage %',
                    fontSize: 32,
                    fontWeight: FontWeight.w700,
                    color: Colors.amber.shade700,
                  ),
                  _buildStatusBadge('Average', Colors.amber),
                ],
              ),
              const SizedBox(height: 20),
              _buildMarkerProgressBar(percentage, [0.0, 17.0, 25.5, 100.0], Colors.amber),
              const SizedBox(height: 32),
              const Divider(color: Color(0xFFF0F0F0)),
              const SizedBox(height: 16),
              Row(
                children: [
                  _buildStatItem('Total users', '${conversion?.totalUsers ?? 0}'),
                  _buildStatItem('Loyal Users', '${conversion?.loyalUsers ?? 0}'),
                  _buildStatItem('Loyal user level', '${conversion?.loyalUserLevel ?? 0}'),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        AppText(
          'Loyal user conversion means if Astrotalk provides you with 500 new customers then how many of them became your loyal customers',
          fontSize: 12,
          color: Colors.grey.shade500,
          height: 1.5,
        ),
      ],
    );
  }

  Widget _buildStatusBadge(String text, Color color, {IconData? icon}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(100),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon ?? Iconsax.info_circle_copy, size: 14, color: color),
          const SizedBox(width: 6),
          AppText(
            text,
            fontSize: 12,
            fontWeight: FontWeight.w700,
            color: color,
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(String label, String value) {
    return Expanded(
      child: Column(
        children: [
          AppText(
            label,
            fontSize: 12,
            color: Colors.grey.shade500,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          AppText(
            value,
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: const Color(0xFF2E1A47),
          ),
        ],
      ),
    );
  }

  Widget _buildMarkerProgressBar(double value, List<double> markers, Color color) {
    return Column(
      children: [
        Stack(
          clipBehavior: Clip.none,
          children: [
            Container(
              height: 12,
              width: double.infinity,
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            FractionallySizedBox(
              widthFactor: value / 100,
              child: Container(
                height: 12,
                decoration: BoxDecoration(
                  color: color,
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
            // Positioned triangle indicator at current value
            Positioned(
              left: 0,
              right: 0,
              top: -12,
              child: FractionallySizedBox(
                alignment: Alignment.centerLeft,
                widthFactor: value / 100,
                child: Align(
                  alignment: Alignment.centerRight,
                  child: Icon(Icons.arrow_drop_down, color: color, size: 24),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: markers.map((m) {
            return AppText(
              '${m.toInt()}%',
              fontSize: 10,
              color: Colors.grey.shade500,
              fontWeight: FontWeight.w600,
            );
          }).toList(),
        ),
      ],
    );
  }
}
