import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/app_text.dart';
import '../../../core/widgets/custom_app_bar.dart';

class PerformanceScreen extends StatefulWidget {
  const PerformanceScreen({super.key});

  @override
  State<PerformanceScreen> createState() => _PerformanceScreenState();
}

class _PerformanceScreenState extends State<PerformanceScreen> {
  final List<Map<String, dynamic>> _reviews = [
    {
      'id': '1',
      'user': 'Rohan Sharma',
      'rating': 5,
      'date': '18 Feb 2026',
      'comment': 'He is very accurate and his remedies are really helpful. Must consult!',
      'reply': null,
    },
    {
      'id': '2',
      'user': 'Priya Patel',
      'rating': 4,
      'date': '17 Feb 2026',
      'comment': 'Good experience, very polite and explained everything clearly.',
      'reply': 'Thank you Priya! Glad I could help.',
    },
  ];
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9F9F9),
      appBar: const CustomAppBar(
        title: 'My Performance',
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            _buildTierSection(),
            const SizedBox(height: 20),
            _buildPerformanceContent(),
          ],
        ),
      ),
    );
  }

  Widget _buildTierSection() {
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
              _buildTierLabel('Rising Star', true),
              _buildTierLabel('Top Choice', false),
              _buildTierLabel('Celebrity', false),
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
              widthFactor: 0.2, // Mock progress
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


  Widget _buildPerformanceContent() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildProfileHealthSection(),
          const SizedBox(height: 32),
          _buildAvailabilitySection(),
          const SizedBox(height: 32),
          _buildAvailabilityLink(),
          const SizedBox(height: 32),
          _buildLoyalUserSection(),
          const SizedBox(height: 32),
          _buildRatingSection(
            'Average Chat Rating',
            4.78,
            'Excellent',
            'Average Chat Rating is the average of ratings given by users on paid (non-PO) chat orders over the last 90 days. It may increase or decrease daily as the 90-day window keeps shifting. If a user rates multiple times, only one rating is counted.',
            [1.0, 4.5, 4.75, 5.0],
            Colors.green,
          ),
          const SizedBox(height: 32),
          _buildRatingSection(
            'Average Call Rating',
            4.76,
            'Excellent',
            'Average Call Rating is the average of ratings given by users on paid (non-PO) call orders over the last 90 days. It may increase or decrease daily as the 90-day window keeps shifting. If a user rates multiple times, only one rating is counted.',
            [1.0, 4.5, 4.75, 5.0],
            Colors.green,
          ),
          const SizedBox(height: 32),
          _buildRecentReviewsSection(),
          const SizedBox(height: 40),
        ],
      ),
    );
  }

  Widget _buildProfileHealthSection() {
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
                '19 February 2026',
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
              _buildHealthRow('Total Sessions', '0', isFirst: true),
              _buildHealthRow('Missed Sessions', '0'),
              _buildHealthRow('Revenue Loss from missed Sessions', '₹0', showInfo: true),
              _buildHealthRow('Missed Calls', '0'),
              _buildHealthRow('Missed Chats', '0'),
              _buildHealthRow('Loyal Users', '0', isLast: true),
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

  Widget _buildAvailabilitySection() {
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
              _buildAvailabilityRow('Available Mins', '0 mins', '290 mins', '212 mins'),
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 16),
                child: Divider(height: 1),
              ),
              _buildAvailabilityRow('Busy Mins', '0 mins', '194 mins', '185 mins'),
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

  Widget _buildLoyalUserSection() {
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
                    '22.4 %',
                    fontSize: 32,
                    fontWeight: FontWeight.w700,
                    color: Colors.amber.shade700,
                  ),
                  _buildStatusBadge('Average', Colors.amber),
                ],
              ),
              const SizedBox(height: 20),
              _buildMarkerProgressBar(22.4, [0.0, 17.0, 25.5, 100.0], Colors.amber),
              const SizedBox(height: 32),
              const Divider(color: Color(0xFFF0F0F0)),
              const SizedBox(height: 16),
              Row(
                children: [
                  _buildStatItem('Total users', '500'),
                  _buildStatItem('Loyal Users', '112'),
                  _buildStatItem('Loyal user level', '2'),
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

  Widget _buildRatingSection(
    String title,
    double rating,
    String status,
    String description,
    List<double> markers,
    Color color,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AppText(
          title,
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
            border: Border.all(color: color.withOpacity(0.1), width: 2),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Row(
                      children: [
                        AppText(
                          rating.toString(),
                          fontSize: 26, // Reduced from 28
                          fontWeight: FontWeight.w700,
                          color: color,
                        ),
                        const SizedBox(width: 6),
                        Flexible(
                          child: FittedBox(
                            fit: BoxFit.scaleDown,
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: List.generate(5, (index) {
                                return const Icon(
                                  Icons.star_rounded,
                                  color: Colors.amber,
                                  size: 18,
                                );
                              }),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  _buildStatusBadge(status, color, icon: Icons.check_circle_rounded),
                ],
              ),
              const SizedBox(height: 24),
              if (markers.isNotEmpty) _buildMarkerProgressBar(rating, markers, color),
            ],
          ),
        ),
        if (description.isNotEmpty) ...[
          const SizedBox(height: 12),
          AppText(
            description,
            fontSize: 12,
            color: Colors.grey.shade500,
            height: 1.5,
          ),
        ],
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
    double min = markers.first;
    double max = markers.last;
    double progress = ((value - min) / (max - min)).clamp(0.0, 1.0);

    return Column(
      children: [
        Container(
          height: 12,
          width: double.infinity,
          decoration: BoxDecoration(
            color: color.withOpacity(0.05),
            borderRadius: BorderRadius.circular(10),
          ),
          child: FractionallySizedBox(
            alignment: Alignment.centerLeft,
            widthFactor: progress,
            child: Container(
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),
        ),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: markers.map((m) {
            return AppText(
              m.toString(),
              fontSize: 11,
              color: Colors.grey.shade400,
              fontWeight: FontWeight.w500,
            );
          }).toList(),
        ),
      ],
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
                Icon(Icons.chevron_right_rounded, color: Colors.grey.shade400, size: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildRecentReviewsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AppText(
          "Recent Reviews",
          fontSize: 16,
          fontWeight: FontWeight.w700,
          color: const Color(0xFF2E1A47),
        ),
        const SizedBox(height: 16),
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: _reviews.length,
          itemBuilder: (context, index) {
            final review = _reviews[index];
            return Container(
              margin: const EdgeInsets.only(bottom: 16),
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.02),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      AppText(
                        review['user'],
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFF2E1A47),
                      ),
                      AppText(
                        review['date'],
                        fontSize: 11,
                        color: Colors.grey.shade400,
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: List.generate(5, (starIndex) {
                      return Icon(
                        starIndex < review['rating'] ? Icons.star_rounded : Icons.star_outline_rounded,
                        color: Colors.amber,
                        size: 16,
                      );
                    }),
                  ),
                  const SizedBox(height: 12),
                  AppText(
                    review['comment'],
                    fontSize: 13,
                    color: Colors.grey.shade700,
                    height: 1.5,
                  ),
                  if (review['reply'] != null) ...[
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppColors.primaryColor.withOpacity(0.05),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          AppText(
                            'Your Reply:',
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            color: AppColors.primaryColor,
                          ),
                          const SizedBox(height: 4),
                          AppText(
                            review['reply'],
                            fontSize: 12,
                            color: Colors.grey.shade700,
                            height: 1.4,
                          ),
                        ],
                      ),
                    ),
                  ],
                  const SizedBox(height: 16),
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton.icon(
                      onPressed: () => _showReplyBottomSheet(review),
                      icon: Icon(Iconsax.message_text_copy, size: 16, color: AppColors.primaryColor),
                      label: AppText(
                        review['reply'] == null ? 'Reply' : 'Edit Reply',
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: AppColors.primaryColor,
                      ),
                      style: TextButton.styleFrom(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        backgroundColor: AppColors.primaryColor.withOpacity(0.1),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(100)),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ],
    );
  }

  void _showReplyBottomSheet(Map<String, dynamic> review) {
    final TextEditingController replyController = TextEditingController(text: review['reply'] ?? '');
    
    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.all(24),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(30),
            topRight: Radius.circular(30),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                AppText(
                  review['reply'] == null ? 'Reply to Review' : 'Edit Reply',
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: const Color(0xFF2E1A47),
                ),
                IconButton(
                  onPressed: () => Get.back(),
                  icon: const Icon(Icons.close_rounded),
                ),
              ],
            ),
            const SizedBox(height: 8),
            AppText(
              'Review by ${review['user']}',
              fontSize: 13,
              color: Colors.grey.shade500,
            ),
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey.shade50,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.grey.shade200),
              ),
              child: TextField(
                controller: replyController,
                maxLines: 4,
                style: TextStyle(fontSize: 14, color: const Color(0xFF2E1A47)),
                decoration: InputDecoration(
                  hintText: 'Type your reply here...',
                  hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 14),
                  border: InputBorder.none,
                ),
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: () {
                  setState(() {
                    review['reply'] = replyController.text;
                  });
                  Get.back();
                  Get.snackbar(
                    'Success',
                    review['reply'] == null ? 'Reply posted successfully!' : 'Reply updated successfully!',
                    snackPosition: SnackPosition.BOTTOM,
                    backgroundColor: Colors.green,
                    colorText: Colors.white,
                    margin: const EdgeInsets.all(20),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryColor,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(100)),
                  elevation: 0,
                ),
                child: AppText(
                  review['reply'] == null ? 'Post Reply' : 'Update Reply',
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
      isScrollControlled: true,
    );
  }
}
