import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/constants/app_colors.dart';

class CustomTextField extends StatelessWidget {
  final TextEditingController? controller;
  final String hintText;
  final String prefixIconAsset;
  final double prefixIconWidth;
  final double prefixIconHeight;
  final bool isPassword;
  final bool obscureText;
  final VoidCallback? onToggleVisibility;
  final String? suffixIconAsset;
  final TextInputType keyboardType;
  final ValueChanged<String>? onChanged;
  final String? errorText;

  const CustomTextField({
    super.key,
    this.controller,
    required this.hintText,
    required this.prefixIconAsset,
    this.prefixIconWidth = 20,
    this.prefixIconHeight = 20,
    this.isPassword = false,
    this.obscureText = false,
    this.onToggleVisibility,
    this.suffixIconAsset,
    this.keyboardType = TextInputType.text,
    this.onChanged,
    this.errorText,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          height: 64,
          decoration: BoxDecoration(
            color: AppColors.inputBackground,
            borderRadius: BorderRadius.circular(10),
            border: errorText != null
                ? Border.all(color: Colors.red.shade400, width: 1.2)
                : null,
          ),
          child: Row(
            children: [
              const SizedBox(width: 16),
              SizedBox(
                width: 24,
                height: 24,
                child: Center(
                  child: SvgPicture.asset(
                    prefixIconAsset,
                    width: prefixIconWidth,
                    height: prefixIconHeight,
                    fit: BoxFit.contain,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: TextField(
                  controller: controller,
                  keyboardType: keyboardType,
                  obscureText: obscureText,
                  onChanged: onChanged,
                  cursorColor: AppColors.primaryGreen,
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    fontWeight: FontWeight.w400,
                    color: AppColors.textPrimary,
                  ),
                  decoration: InputDecoration(
                    hintText: hintText,
                    hintStyle: GoogleFonts.poppins(
                      fontSize: 14,
                      fontWeight: FontWeight.w300,
                      color: AppColors.textSecondary,
                    ),
                    isDense: true,
                    filled: false,
                    contentPadding: const EdgeInsets.symmetric(vertical: 20),
                    border: InputBorder.none,
                    enabledBorder: InputBorder.none,
                    focusedBorder: InputBorder.none,
                  ),
                ),
              ),
              if (isPassword)
                Material(
                  color: Colors.transparent,
                  child: InkWell(
                    borderRadius: BorderRadius.circular(20),
                    onTap: onToggleVisibility,
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: SvgPicture.asset(
                        suffixIconAsset ?? prefixIconAsset,
                        width: 24,
                        height: 18,
                        fit: BoxFit.contain,
                        colorFilter: obscureText
                            ? null
                            : const ColorFilter.mode(
                                AppColors.primaryGreen,
                                BlendMode.srcIn,
                              ),
                      ),
                    ),
                  ),
                )
              else
                const SizedBox(width: 16),
            ],
          ),
        ),
        if (errorText != null)
          Padding(
            padding: const EdgeInsets.only(left: 8, top: 4),
            child: Text(
              errorText!,
              style: GoogleFonts.poppins(
                fontSize: 12,
                color: Colors.red.shade700,
                fontWeight: FontWeight.w400,
              ),
            ),
          ),
      ],
    );
  }
}

