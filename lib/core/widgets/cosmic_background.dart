import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

class CosmicBackground extends StatelessWidget {
  final Widget child;
  final bool showGradient;
  final List<Color>? gradientColors;

  const CosmicBackground({
    Key? key,
    required this.child,
    this.showGradient = true,
    this.gradientColors,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: showGradient
            ? LinearGradient(
                colors: gradientColors ??
                    [
                      AppColors.primaryColor.withOpacity(0.1),
                      AppColors.secondaryColor.withOpacity(0.05),
                      Colors.white,
                    ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              )
            : null,
        color: showGradient ? null : AppColors.backgroundColor,
      ),
      child: child,
    );
  }
}
