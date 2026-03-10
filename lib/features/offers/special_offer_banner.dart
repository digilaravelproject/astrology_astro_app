import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/app_text.dart';

class SpecialOfferBanner extends StatefulWidget {
  const SpecialOfferBanner({Key? key}) : super(key: key);

  @override
  State<SpecialOfferBanner> createState() => _SpecialOfferBannerState();
}

class _SpecialOfferBannerState extends State<SpecialOfferBanner> {
  bool isOfferEnabled = false;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFFEFCE8), // Light yellow background
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFFDE047), width: 1.5), // Yellow border
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Header
          Container(
            padding: const EdgeInsets.symmetric(vertical: 10),
            decoration: const BoxDecoration(
              color: Color(0xFFFEF08A), // Slightly darker yellow header
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(14.5),
                topRight: Radius.circular(14.5),
              ),
              border: Border(
                bottom: BorderSide(color: Color(0xFFFDE047), width: 1.5),
              ),
            ),
            alignment: Alignment.center,
            child: AppText(
              'Special offer to attract new users!',
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: const Color(0xFF423D00), // Dark yellow text
            ),
          ),
          
          // Body
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      AppText(
                        'PO@5 - Paid Users',
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFF4A4A4A),
                      ),
                      const SizedBox(height: 6),
                      AppText(
                        'Users get 5 sessions at ₹5/min. Astrologer gets up to ₹2.5/min. You may receive PO@5 calls or chats even if your button is disabled.',
                        fontSize: 11,
                        color: const Color(0xFF6B6B6B),
                        height: 1.4,
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 16),
                // Custom Toggle
                GestureDetector(
                  onTap: () {
                    setState(() {
                      isOfferEnabled = !isOfferEnabled;
                    });
                  },
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    width: 76,
                    height: 36,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      color: Colors.white,
                      border: Border.all(color: const Color(0xFFD1D5DB), width: 1.5),
                    ),
                    child: Stack(
                      children: [
                        AnimatedPositioned(
                          duration: const Duration(milliseconds: 200),
                          curve: Curves.easeInOut,
                          left: isOfferEnabled ? 42 : 6,
                          top: 6,
                          child: Container(
                            width: 20,
                            height: 20,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: isOfferEnabled ? AppColors.primaryColor : const Color(0xFF64748B),
                            ),
                          ),
                        ),
                        Align(
                          alignment: isOfferEnabled ? Alignment.centerLeft : Alignment.centerRight,
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 10),
                            child: AppText(
                              isOfferEnabled ? 'On' : 'Off',
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: isOfferEnabled ? AppColors.primaryColor : const Color(0xFF64748B),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
