import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/mock/mock_data.dart';
import '../../../core/widgets/primary_button.dart';
import '../../../core/widgets/qr_pass_widget.dart';
import '../providers/reservation_provider.dart';

class BookingSuccessScreen extends ConsumerWidget {
  final String bookingId;

  const BookingSuccessScreen({
    super.key,
    required this.bookingId,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final resState = ref.watch(reservationProvider);
    final reservation = resState.reservations.firstWhere(
      (r) => r.id == bookingId,
      orElse: () => MockData.initialReservations.first,
    );

    return Scaffold(
      backgroundColor: AppColors.backgroundWarm,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 12),

              // Celebration Icon
              Container(
                width: 72,
                height: 72,
                decoration: const BoxDecoration(
                  color: AppColors.primaryGreen,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.check_rounded,
                  size: 44,
                  color: Colors.white,
                ),
              ),

              const SizedBox(height: 16),

              Text(
                'Reservation Confirmed!',
                textAlign: TextAlign.center,
                style: GoogleFonts.poppins(
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),

              const SizedBox(height: 6),

              Text(
                'Your table has been reserved. Show this pass on arrival.',
                textAlign: TextAlign.center,
                style: GoogleFonts.poppins(
                  fontSize: 13,
                  color: AppColors.textSecondary,
                ),
              ),

              const SizedBox(height: 24),

              // The Digital Scannable QR Pass
              QrPassWidget(reservation: reservation),

              const SizedBox(height: 28),

              // View My Bookings button
              PrimaryButton(
                text: 'View My Bookings',
                height: 52,
                onPressed: () => context.go('/bookings'),
              ),

              const SizedBox(height: 12),

              // Return to Home
              TextButton(
                onPressed: () => context.go('/home'),
                child: Text(
                  'Back to Discovery Home',
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.primaryGreen,
                  ),
                ),
              ),

              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }
}

