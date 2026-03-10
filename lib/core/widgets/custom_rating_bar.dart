import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

class CustomRatingBar extends StatelessWidget {
  final double rating;
  final double size;
  final Color? color;
  final int maxRating;
  final bool showRatingText;
  final Function(double)? onRatingUpdate;

  const CustomRatingBar({
    Key? key,
    required this.rating,
    this.size = 20,
    this.color,
    this.maxRating = 5,
    this.showRatingText = false,
    this.onRatingUpdate,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        ...List.generate(maxRating, (index) {
          return GestureDetector(
            onTap: onRatingUpdate != null
                ? () => onRatingUpdate!(index + 1.0)
                : null,
            child: Icon(
              index < rating.floor()
                  ? Icons.star
                  : index < rating
                      ? Icons.star_half
                      : Icons.star_border,
              color: color ?? AppColors.goldAccent,
              size: size,
            ),
          );
        }),
        if (showRatingText) ...[
          const SizedBox(width: 4),
          Text(
            rating.toStringAsFixed(1),
            style: TextStyle(
              fontSize: size * 0.7,
              fontWeight: FontWeight.w600,
              color: AppColors.textColorSecondary,
            ),
          ),
        ],
      ],
    );
  }
}
