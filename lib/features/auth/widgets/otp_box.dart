import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/constants/app_colors.dart';

class OtpBox extends StatelessWidget {
  final String digit;
  final bool isFocused;
  final double width;
  final double height;

  const OtpBox({
    super.key,
    required this.digit,
    this.isFocused = false,
    this.width = 48.0,
    this.height = 48.0,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: AppColors.otpBoxBackground,
        borderRadius: BorderRadius.circular(8),
        border: isFocused
            ? Border.all(color: AppColors.primaryGreen, width: 2)
            : null,
      ),
      child: Center(
        child: Text(
          digit,
          style: GoogleFonts.inter(
            fontSize: 22,
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
          ),
        ),
      ),
    );
  }
}

