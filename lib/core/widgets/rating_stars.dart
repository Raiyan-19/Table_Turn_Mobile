import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../constants/app_colors.dart';

class RatingStars extends StatelessWidget {
  final double rating;
  final int? reviewCount;
  final double starSize;
  final bool showNumber;

  const RatingStars({
    super.key,
    required this.rating,
    this.reviewCount,
    this.starSize = 14.0,
    this.showNumber = true,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Icon(
          Icons.star_rounded,
          size: starSize,
          color: AppColors.ratingStar,
        ),
        const SizedBox(width: 3),
        if (showNumber)
          Text(
            rating.toStringAsFixed(1),
            style: GoogleFonts.inter(
              fontSize: starSize * 0.9,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
        if (reviewCount != null) ...[
          const SizedBox(width: 3),
          Text(
            '($reviewCount)',
            style: GoogleFonts.inter(
              fontSize: starSize * 0.8,
              fontWeight: FontWeight.w400,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ],
    );
  }
}

