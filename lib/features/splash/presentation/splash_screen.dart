import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/constants/app_assets.dart';
import '../../../core/constants/app_colors.dart';

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final bottomPadding = MediaQuery.of(context).padding.bottom;

    return Scaffold(
      body: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () => context.push('/sign-in'),
        onHorizontalDragEnd: (details) {
          if (details.primaryVelocity != null && details.primaryVelocity! < 0) {
            context.push('/sign-in');
          }
        },
        child: Stack(
          children: [
            // Background image
            Positioned.fill(
              child: Image.asset(
                AppAssets.splashBg,
                fit: BoxFit.cover,
                width: size.width,
                height: size.height,
              ),
            ),

            // Main content
            SafeArea(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: Column(
                  children: [
                    const SizedBox(height: 10),
                    // Logo
                    Center(
                      child: Image.asset(
                        AppAssets.logo,
                        width: 171,
                        height: 171,
                        fit: BoxFit.contain,
                      ),
                    ),
                    const SizedBox(height: 8),

                    // App Title
                    Text(
                      'Table Turn',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.merienda(
                        fontSize: 32,
                        fontWeight: FontWeight.w400,
                        color: AppColors.textPrimary,
                        height: 1.44,
                      ),
                    ),
                    const SizedBox(height: 8),

                    // Tagline
                    Text(
                      'Good food deserves a great table',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.merienda(
                        fontSize: 12,
                        fontWeight: FontWeight.w400,
                        color: AppColors.textPrimary,
                        height: 1.44,
                      ),
                    ),
                    const SizedBox(height: 12),

                    // Center Line divider
                    Container(
                      width: 45,
                      height: 1.5,
                      color: AppColors.textPrimary,
                    ),

                    const Spacer(),

                    // Page indicator
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          width: 30,
                          height: 8,
                          decoration: BoxDecoration(
                            color: AppColors.darkGreen,
                            borderRadius: BorderRadius.circular(15),
                          ),
                        ),
                        const SizedBox(width: 6),
                        Container(
                          width: 8,
                          height: 8,
                          decoration: const BoxDecoration(
                            color: AppColors.inactiveIndicator,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 6),
                        Container(
                          width: 8,
                          height: 8,
                          decoration: const BoxDecoration(
                            color: AppColors.inactiveIndicator,
                            shape: BoxShape.circle,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // Bottom subtitle / action
                    InkWell(
                      borderRadius: BorderRadius.circular(8),
                      onTap: () => context.push('/sign-in'),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                        child: Text(
                          'A better dining experinece awaits',
                          textAlign: TextAlign.center,
                          style: GoogleFonts.merienda(
                            fontSize: 12,
                            fontWeight: FontWeight.w400,
                            color: AppColors.textPrimary,
                            height: 1.44,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: bottomPadding > 0 ? 12 : 24),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
