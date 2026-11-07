import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/constants/app_assets.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/widgets/custom_back_button.dart';
import '../../../core/widgets/primary_button.dart';

class SuccessScreen extends StatelessWidget {
  const SuccessScreen({super.key});

  void _handleContinue(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: AppColors.backgroundWarm,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: Text(
            'Enjoy Dining!',
            style: GoogleFonts.merienda(
              fontSize: 20,
              fontWeight: FontWeight.w400,
              color: AppColors.textPrimary,
            ),
          ),
          content: Text(
            'You have successfully completed the 4-screen authentication flow for Table Turn.',
            style: GoogleFonts.poppins(
              fontSize: 14,
              color: AppColors.textSecondary,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                context.go('/home');
              },
              child: Text(
                'Explore Restaurants',
                style: GoogleFonts.poppins(color: AppColors.primaryGreen, fontWeight: FontWeight.w600),
              ),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryGreen,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              onPressed: () {
                Navigator.pop(context);
                context.go('/splash');
              },
              child: Text(
                'Restart Flow',
                style: GoogleFonts.poppins(color: Colors.white),
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: AppColors.backgroundWarm,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                physics: const ClampingScrollPhysics(),
                child: Column(
                  children: [
                    // Top Bar with Back Arrow
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Padding(
                        padding: const EdgeInsets.only(left: 16.0, top: 8.0),
                        child: CustomBackButton(
                          onTap: () {
                            if (context.canPop()) {
                              context.pop();
                            } else {
                              context.go('/otp');
                            }
                          },
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),

                    // Success celebration badge with confetti
                    SizedBox(
                      width: 270,
                      height: 180,
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          // Confetti polygons
                          Positioned(
                            top: 0,
                            child: SvgPicture.asset(
                              AppAssets.confetti,
                              width: 263,
                              height: 132,
                              fit: BoxFit.contain,
                            ),
                          ),
                          // Mint Circle
                          Container(
                            width: 166,
                            height: 166,
                            decoration: const BoxDecoration(
                              color: AppColors.mintGreen,
                              shape: BoxShape.circle,
                            ),
                            child: Center(
                              child: SvgPicture.asset(
                                AppAssets.successCheck,
                                width: 70,
                                height: 50,
                                fit: BoxFit.contain,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 28),

                    // Welcome back Title
                    Text(
                      'Welcome back',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.merienda(
                        fontSize: 32,
                        fontWeight: FontWeight.w400,
                        color: AppColors.textPrimary,
                        height: 1.44,
                      ),
                    ),
                    const SizedBox(height: 12),

                    // Subtitle
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 40.0),
                      child: Text(
                        'You’ve signed in succesfully.\nReady to find your next great meal?',
                        textAlign: TextAlign.center,
                        style: GoogleFonts.merienda(
                          fontSize: 14,
                          fontWeight: FontWeight.w400,
                          color: AppColors.textPrimary,
                          height: 1.44,
                        ),
                      ),
                    ),
                    const SizedBox(height: 36),

                    // Continue to Home Button
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 26.0),
                      child: PrimaryButton(
                        text: 'Continue to Home',
                        height: 63,
                        borderRadius: 10,
                        textStyle: GoogleFonts.merienda(
                          fontSize: 14,
                          fontWeight: FontWeight.w400,
                          color: Colors.white,
                        ),
                        onPressed: () => _handleContinue(context),
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],
                ),
              ),
            ),

            // Bottom Food Illustration Image
            SizedBox(
              width: screenWidth,
              height: 230,
              child: Image.asset(
                AppAssets.foodIllustration,
                fit: BoxFit.cover,
                alignment: Alignment.topCenter,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
