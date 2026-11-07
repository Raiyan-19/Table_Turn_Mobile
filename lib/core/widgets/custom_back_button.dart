import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import '../constants/app_assets.dart';

class CustomBackButton extends StatelessWidget {
  final VoidCallback? onTap;

  const CustomBackButton({
    super.key,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: 'Back',
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: () {
            if (onTap != null) {
              onTap!();
            } else if (context.canPop()) {
              context.pop();
            }
          },
          child: Container(
            padding: const EdgeInsets.all(12),
            child: SvgPicture.asset(
              AppAssets.backArrow,
              width: 22,
              height: 12,
              fit: BoxFit.contain,
            ),
          ),
        ),
      ),
    );
  }
}

