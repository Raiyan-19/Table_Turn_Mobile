import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/constants/app_assets.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/widgets/primary_button.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  final List<Map<String, String>> _slides = [
    {
      'title': 'Table Turn',
      'subtitle': 'Good food deserves a great table',
      'description':
          'Discover celebrated restaurants, curated dining spaces, and instant table availability in one central hub.',
    },
    {
      'title': 'Welcome To Our Service',
      'subtitle': 'Nationwide Dining Across Bangladesh',
      'description':
          'Explore premium restaurants across all 8 administrative divisions — from Gulshan rooftops to Chittagong Mezbani.',
    },
    {
      'title': 'Instant Smart Reservation',
      'subtitle': 'Live Tables & Digital QR Passes',
      'description':
          'Pick your preferred time and table. Check in seamlessly upon arrival with your personalized digital QR pass.',
    },
  ];

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _onNext() {
    if (_currentPage < _slides.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 350),
        curve: Curves.easeInOut,
      );
    } else {
      context.go('/sign-in');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Background Image
          Positioned.fill(
            child: Image.asset(
              AppAssets.splashBg,
              fit: BoxFit.cover,
            ),
          ),

          // Content Overlay
          SafeArea(
            child: Column(
              children: [
                // Top Bar with Skip Button
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 8.0),
                  child: Align(
                    alignment: Alignment.centerRight,
                    child: TextButton(
                      onPressed: () => context.go('/sign-in'),
                      child: Text(
                        'Skip',
                        style: GoogleFonts.poppins(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: AppColors.darkGreen,
                        ),
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 10),

                // Logo
                Image.asset(
                  AppAssets.logo,
                  width: 140,
                  height: 140,
                  fit: BoxFit.contain,
                ),

                const SizedBox(height: 12),

                // PageView
                Expanded(
                  child: PageView.builder(
                    controller: _pageController,
                    onPageChanged: (idx) => setState(() => _currentPage = idx),
                    itemCount: _slides.length,
                    itemBuilder: (context, index) {
                      final slide = _slides[index];
                      final isWelcomeScreen = index == 1;

                      return Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 32.0),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              slide['title']!,
                              textAlign: TextAlign.center,
                              style: isWelcomeScreen
                                  ? GoogleFonts.poppins(
                                      fontSize: 30,
                                      fontWeight: FontWeight.w700,
                                      color: AppColors.darkGreen,
                                      height: 1.25,
                                    )
                                  : GoogleFonts.merienda(
                                      fontSize: 30,
                                      fontWeight: FontWeight.w400,
                                      color: AppColors.textPrimary,
                                      height: 1.3,
                                    ),
                            ),
                            const SizedBox(height: 12),
                            Text(
                              slide['subtitle']!,
                              textAlign: TextAlign.center,
                              style: GoogleFonts.poppins(
                                fontSize: 15,
                                fontWeight: FontWeight.w600,
                                color: AppColors.primaryGreen,
                              ),
                            ),
                            const SizedBox(height: 16),
                            Text(
                              slide['description']!,
                              textAlign: TextAlign.center,
                              style: GoogleFonts.poppins(
                                fontSize: 13,
                                fontWeight: FontWeight.w400,
                                color: AppColors.textPrimary,
                                height: 1.5,
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),

                // Indicators
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(
                    _slides.length,
                    (idx) => AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      margin: const EdgeInsets.symmetric(horizontal: 4),
                      width: _currentPage == idx ? 28 : 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: _currentPage == idx
                            ? AppColors.darkGreen
                            : AppColors.inactiveIndicator,
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 28),

                // Bottom Action CTA
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 32.0),
                  child: PrimaryButton(
                    text: _currentPage == _slides.length - 1 ? 'Get Started' : 'Next',
                    height: 54,
                    onPressed: _onNext,
                  ),
                ),

                const SizedBox(height: 28),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
