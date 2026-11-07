import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../../core/constants/app_colors.dart';

class SocialButton extends StatelessWidget {
  final String iconAsset;
  final VoidCallback onTap;
  final double iconWidth;
  final double iconHeight;
  final double? width;
  final double height;

  const SocialButton({
    super.key,
    required this.iconAsset,
    required this.onTap,
    this.iconWidth = 28,
    this.iconHeight = 28,
    this.width,
    this.height = 50,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.inputBackground,
      borderRadius: BorderRadius.circular(7),
      child: InkWell(
        borderRadius: BorderRadius.circular(7),
        onTap: onTap,
        child: SizedBox(
          width: width,
          height: height,
          child: Center(
            child: SvgPicture.asset(
              iconAsset,
              width: iconWidth,
              height: iconHeight,
              fit: BoxFit.contain,
            ),
          ),
        ),
      ),
    );
  }
}

