import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/constants/app_assets.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/models/user_model.dart';
import '../../auth/providers/auth_provider.dart';

class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen> {
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _timer = Timer(const Duration(milliseconds: 1400), () {
      if (mounted) {
        _checkSessionAndNavigate();
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _checkSessionAndNavigate() {
    final authState = ref.read(authProvider);
    if (authState.isAuthenticated) {
      if (authState.currentRole == UserRole.manager) {
        context.go('/manager-dashboard');
      } else if (authState.currentRole == UserRole.admin) {
        context.go('/admin-dashboard');
      } else {
        context.go('/home');
      }
    }
  }

  void _onProceed() {
    _timer?.cancel();
    final authState = ref.read(authProvider);
    if (authState.isAuthenticated) {
      if (authState.currentRole == UserRole.manager) {
        context.go('/manager-dashboard');
      } else if (authState.currentRole == UserRole.admin) {
        context.go('/admin-dashboard');
      } else {
        context.go('/home');
      }
    } else {
      context.push('/sign-in');
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final bottomPadding = MediaQuery.of(context).padding.bottom;

    return Scaffold(
      body: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: _onProceed,
        onHorizontalDragEnd: (details) {
          if (details.primaryVelocity != null && details.primaryVelocity! < 0) {
            _onProceed();
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
                      onTap: _onProceed,
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
