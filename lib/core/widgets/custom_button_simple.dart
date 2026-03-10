import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

class CustomButton extends StatelessWidget {
  final String text;
  final VoidCallback? onTap;
  final bool isLoading;
  final double height;
  final double? width;
  final double fontSize;
  final FontWeight fontWeight;
  final EdgeInsetsGeometry? margin;
  final EdgeInsetsGeometry? padding;
  final Color? textColor;
  final Gradient? gradient;
  final double? borderRadius;
  final Color? backgroundColor;
  final IconData? icon;

  const CustomButton({
    Key? key,
    required this.text,
    this.onTap,
    this.isLoading = false,
    this.height = 50,
    this.width,
    this.fontSize = 18,
    this.fontWeight = FontWeight.w700,
    this.margin,
    this.padding,
    this.textColor,
    this.gradient,
    this.borderRadius,
    this.icon,
    this.backgroundColor,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: margin,
      child: GestureDetector(
        onTap: isLoading ? null : onTap,
        child: Container(
          width: width ?? double.infinity,
          height: height,
          padding: padding,
          decoration: BoxDecoration(
            color: backgroundColor ?? (gradient == null ? (textColor == AppColors.deepPink ? Colors.white : AppColors.primaryColor) : null),
            gradient: gradient,
            borderRadius: BorderRadius.circular(borderRadius ?? height / 2),
            boxShadow: [
              BoxShadow(
                color: AppColors.primaryColor.withOpacity(0.3),
                blurRadius: 15,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: Center(
            child: isLoading
                ? const SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(
                      color: Colors.white,
                      strokeWidth: 2,
                    ),
                  )
                : Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (icon != null) ...[
                        Icon(
                          icon,
                          color: textColor ?? Colors.white,
                          size: fontSize + 2,
                        ),
                        const SizedBox(width: 8),
                      ],
                      Text(
                        text,
                        style: TextStyle(
                          color: textColor ?? Colors.white,
                          fontSize: fontSize,
                          fontWeight: fontWeight,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ],
                  ),
          ),
        ),
      ),
    );
  }
}
