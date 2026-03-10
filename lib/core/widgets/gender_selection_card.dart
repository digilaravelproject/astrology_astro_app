import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../constants/dimensions.dart';

class GenderSelectionCard extends StatelessWidget {
  final String gender;
  final IconData icon;
  final bool isSelected;
  final VoidCallback onTap;

  const GenderSelectionCard({
    Key? key,
    required this.gender,
    required this.icon,
    required this.isSelected,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(
          vertical: Dimensions.height20,
          horizontal: Dimensions.width15,
        ),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.primaryColor.withOpacity(0.1)
              : AppColors.cardColor,
          border: Border.all(
            color: isSelected ? AppColors.primaryColor : AppColors.borderColor,
            width: isSelected ? 2 : 1,
          ),
          borderRadius: BorderRadius.circular(Dimensions.radius12),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: Dimensions.iconSize24 * 2,
              color: isSelected
                  ? AppColors.primaryColor
                  : AppColors.textColorSecondary,
            ),
            SizedBox(height: Dimensions.height10),
            Text(
              gender,
              style: TextStyle(
                fontSize: Dimensions.font16,
                fontWeight: FontWeight.w600,
                color: isSelected
                    ? AppColors.primaryColor
                    : AppColors.textColorPrimary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
