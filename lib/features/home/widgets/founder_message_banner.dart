import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/custom_image_widget.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/widgets/app_text.dart';
import '../../../../core/theme/text_theme.dart';

class FounderMessageBanner extends StatelessWidget {
  const FounderMessageBanner({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 0), // Adjusting margin to 0 as it will be inside a padding container
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        gradient: const LinearGradient(
          colors: [
            Color(0xFFFFF0F0), // Very light pink
            Color(0xFFFFF8E1), // Very light gold
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryColor.withOpacity(0.08),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
        border: Border.all(
          color: Colors.white,
          width: 2,
        ),
      ),
      child: Stack(
        children: [
          // Decorative background pattern (sparkles)
          Positioned(
            right: 0,
            top: 0,
            child: Icon(Icons.auto_awesome, color: AppColors.goldAccent.withOpacity(0.4), size: 40),
          ),
          Positioned(
            left: 10,
            bottom: 10,
            child: Icon(Icons.star_rate_rounded, color: AppColors.accentColor.withOpacity(0.2), size: 30),
          ),

          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Founder Image
                Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: AppColors.goldAccent, width: 2),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: CustomImageWidget(
                    imagePath: 'https://img.freepik.com/free-photo/closeup-young-hispanic-man-casuals-studio_662251-600.jpg', // User-provided founder image
                    height: 50,
                    width: 50,
                    radius: BorderRadius.circular(35),
                    fit: BoxFit.cover,
                  ),
                ),
                
                const SizedBox(width: 12),
                
                // Text Content
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      AppText(
                        AppStrings.foundersWords,
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFF8B0000), // Dark Red
                      ),
                      const SizedBox(height: 8),
                      AppText(
                        AppStrings.founderMessage,
                        fontSize: 12,
                        fontWeight: FontWeight.w400,
                        color: Colors.black87.withOpacity(0.7),
                        height: 1.4,
                      ),
                      const SizedBox(height: 12),
                      Align(
                        alignment: Alignment.centerRight,
                        child: AppText(
                          AppStrings.yourFounder,
                          style: AppTextTheme.signatureStyle(
                            fontSize: 18,
                            color: AppColors.primaryColor,
                          ),
                        ),
                      ),
                    ],
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
