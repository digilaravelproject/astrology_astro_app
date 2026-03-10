import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/app_text.dart';

class StartPaidSessionSection extends StatelessWidget {
  const StartPaidSessionSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: AppText(
                  'Start Paid Session with Users',
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF2C2C2C),
                ),
              ),
              const SizedBox(width: 8),
              InkWell(
                onTap: () {
                  // View All Logic
                },
                child: AppText(
                  'View All',
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF3B82F6), // Blue color for View All
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        SizedBox(
          height: 110, // Dramatically reduced height
          child: ListView.separated(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            scrollDirection: Axis.horizontal,
            itemCount: 3, // Mock count
            separatorBuilder: (context, index) => const SizedBox(width: 10),
            itemBuilder: (context, index) {
              return _buildUserCard();
            },
          ),
        ),
      ],
    );
  }

  Widget _buildUserCard() {
    return Container(
      width: 220, // Even smaller width
      padding: const EdgeInsets.all(10), // Even smaller padding
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Avatar
              Container(
                width: 38, // Even smaller avatar size
                height: 38,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.yellow.shade400,
                  border: Border.all(color: Colors.white, width: 2),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 5,
                    ),
                  ],
                ),
                child: ClipOval(
                  child: Icon(Icons.person, size: 24, color: Colors.grey.shade600), // Even smaller icon size
                ),
              ),
              const SizedBox(width: 8),
              
              // Name and Spent Amount
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    AppText(
                      'Anisha',
                      fontSize: 13, // Smaller font size
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFF2C2C2C),
                    ),
                    const SizedBox(height: 1),
                    AppText(
                      'Spent ₹1,000+',
                      fontSize: 10, // Smaller font size
                      fontWeight: FontWeight.w500,
                      color: Colors.grey.shade600,
                    ),
                  ],
                ),
              ),
              
              // Timer Badge
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3), // Smaller padding
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(100),
                  border: Border.all(color: AppColors.primaryColor.withOpacity(0.3)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.schedule, size: 10, color: Colors.grey.shade600), // Smaller icon
                    const SizedBox(width: 3),
                    AppText(
                      '4 min',
                      fontSize: 10, // Smaller font

                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF2C2C2C),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const Spacer(),
          
          // Action Buttons
          Row(
            children: [
              Expanded(
                child: InkWell(
                  onTap: () {},
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 6), // Smaller padding
                    decoration: BoxDecoration(
                      color: AppColors.primaryColor,
                      borderRadius: BorderRadius.circular(6), // Smaller radius
                      border: Border.all(color: AppColors.primaryColor),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.call, size: 14, color: Colors.white), // Smaller icon
                        const SizedBox(width: 4),
                        AppText(
                          'Call Now',
                          fontSize: 11, // Smaller font
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 6),
              Expanded(
                child: InkWell(
                  onTap: () {},
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 6), // Smaller padding
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(6), // Smaller radius
                      border: Border.all(color: AppColors.primaryColor),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.chat_bubble_outline, size: 14, color: AppColors.primaryColor), // Smaller icon
                        const SizedBox(width: 4),
                        AppText(
                          'Chat Now',
                          fontSize: 11, // Smaller font
                          fontWeight: FontWeight.w600,
                          color: AppColors.primaryColor,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
