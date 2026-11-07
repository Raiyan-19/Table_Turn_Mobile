import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/constants/app_assets.dart';
import '../../../core/constants/app_colors.dart';

class DialPad extends StatelessWidget {
  final ValueChanged<String> onNumberTap;
  final VoidCallback onDeleteTap;

  const DialPad({
    super.key,
    required this.onNumberTap,
    required this.onDeleteTap,
  });

  Widget _buildKey({
    required Widget child,
    required VoidCallback onTap,
    bool isTransparent = false,
  }) {
    if (isTransparent) {
      return const SizedBox(height: 48);
    }

    return SizedBox(
      height: 48,
      child: Material(
        color: AppColors.dialKeyBackground,
        borderRadius: BorderRadius.circular(12),
        elevation: 0,
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: () {
            HapticFeedback.lightImpact();
            onTap();
          },
          child: Center(child: child),
        ),
      ),
    );
  }

  Widget _buildNumberKey(String number) {
    return _buildKey(
      child: Text(
        number,
        style: GoogleFonts.inter(
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: AppColors.textPrimary,
        ),
      ),
      onTap: () => onNumberTap(number),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      color: AppColors.dialPadBackground,
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Expanded(child: _buildNumberKey('1')),
              const SizedBox(width: 12),
              Expanded(child: _buildNumberKey('2')),
              const SizedBox(width: 12),
              Expanded(child: _buildNumberKey('3')),
            ],
          ),
          const SizedBox(height: 11),
          Row(
            children: [
              Expanded(child: _buildNumberKey('4')),
              const SizedBox(width: 12),
              Expanded(child: _buildNumberKey('5')),
              const SizedBox(width: 12),
              Expanded(child: _buildNumberKey('6')),
            ],
          ),
          const SizedBox(height: 11),
          Row(
            children: [
              Expanded(child: _buildNumberKey('7')),
              const SizedBox(width: 12),
              Expanded(child: _buildNumberKey('8')),
              const SizedBox(width: 12),
              Expanded(child: _buildNumberKey('9')),
            ],
          ),
          const SizedBox(height: 11),
          Row(
            children: [
              Expanded(
                child: _buildKey(
                  isTransparent: true,
                  child: const SizedBox.shrink(),
                  onTap: () {},
                ),
              ),
              const SizedBox(width: 12),
              Expanded(child: _buildNumberKey('0')),
              const SizedBox(width: 12),
              Expanded(
                child: _buildKey(
                  child: SvgPicture.asset(
                    AppAssets.dialBackspace,
                    width: 24,
                    height: 18,
                    fit: BoxFit.contain,
                  ),
                  onTap: onDeleteTap,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

