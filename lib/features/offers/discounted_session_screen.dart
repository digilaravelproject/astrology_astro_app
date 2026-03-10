import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/app_text.dart';
import '../../../../core/widgets/custom_app_bar.dart';

class DiscountedSessionScreen extends StatelessWidget {
  const DiscountedSessionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: const CustomAppBar(
        title: 'Discounted Session',
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                _buildOfferCard(
                  duration: '30-minute',
                  originalPrice: '450.0',
                  discountedPrice: '360.0',
                  discountPercentage: '20% Off',
                  isSelected: true,
                ),
                _buildOfferCard(
                  duration: '60-minute',
                  originalPrice: '900.0',
                  discountedPrice: '720.0',
                  discountPercentage: '20% Off',
                ),
                _buildOfferCard(
                  duration: '30-minute',
                  originalPrice: '450.0',
                  discountedPrice: '225.0',
                  discountPercentage: '50% Off',
                ),
                _buildOfferCard(
                  duration: '60-minute',
                  originalPrice: '900.0',
                  discountedPrice: '450.0',
                  discountPercentage: '50% Off',
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.all(16),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {},
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryColor,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
                child: const AppText('Share Session', color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
          )
        ],
      ),
    );
  }

  Widget _buildOfferCard({
    required String duration,
    required String originalPrice,
    required String discountedPrice,
    required String discountPercentage,
    bool isSelected = false,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isSelected ? AppColors.lightPink.withOpacity(0.3) : Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: isSelected ? AppColors.primaryColor : Colors.grey.shade300,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AppText(
            'Offer clients a $duration discounted session',
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              AppText(
                '₹ $originalPrice',
                fontSize: 14,
                color: Colors.grey.shade500,
                decoration: TextDecoration.lineThrough,
              ),
              const SizedBox(width: 8),
              AppText(
                '₹ $discountedPrice',
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 10),
                height: 14,
                width: 1,
                color: Colors.grey.shade400,
              ),
              AppText(
                discountPercentage,
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Colors.green.shade600,
              ),
            ],
          ),
        ],
      ),
    );
  }
}
