import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../constants/dimensions.dart';

class SelectionCard extends StatelessWidget {
  final String title;
  final String? subtitle;
  final bool isSelected;
  final VoidCallback onTap;
  final Widget? icon;
  final Color? selectedColor;
  final Color? unselectedColor;

  const SelectionCard({
    Key? key,
    required this.title,
    this.subtitle,
    required this.isSelected,
    required this.onTap,
    this.icon,
    this.selectedColor,
    this.unselectedColor,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.all(Dimensions.width15),
        decoration: BoxDecoration(
          color: isSelected
              ? (selectedColor ?? AppColors.primaryColor.withOpacity(0.1))
              : (unselectedColor ?? AppColors.cardColor),
          border: Border.all(
            color: isSelected
                ? (selectedColor ?? AppColors.primaryColor)
                : AppColors.borderColor,
            width: isSelected ? 2 : 1,
          ),
          borderRadius: BorderRadius.circular(Dimensions.radius12),
        ),
        child: Row(
          children: [
            if (icon != null) ...[
              icon!,
              SizedBox(width: Dimensions.width10),
            ],
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: Dimensions.font16,
                      fontWeight: FontWeight.w600,
                      color: isSelected
                          ? (selectedColor ?? AppColors.primaryColor)
                          : AppColors.textColorPrimary,
                    ),
                  ),
                  if (subtitle != null) ...[
                    SizedBox(height: Dimensions.height5),
                    Text(
                      subtitle!,
                      style: TextStyle(
                        fontSize: Dimensions.font12,
                        color: AppColors.textColorSecondary,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            if (isSelected)
              Icon(
                Icons.check_circle,
                color: selectedColor ?? AppColors.primaryColor,
                size: Dimensions.iconSize24,
              ),
          ],
        ),
      ),
    );
  }
}
