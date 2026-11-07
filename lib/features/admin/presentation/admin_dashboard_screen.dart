import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/mock/mock_data.dart';
import '../../../core/widgets/app_header.dart';
import '../../reservation/providers/reservation_provider.dart';

class AdminDashboardScreen extends ConsumerWidget {
  const AdminDashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final resState = ref.watch(reservationProvider);
    final totalBookings = resState.reservations.length;
    final totalRestaurants = MockData.restaurants.length;

    return Scaffold(
      backgroundColor: AppColors.backgroundWarm,
      appBar: const AppHeader(
        title: 'Platform Administration',
        subtitle: 'TableTurn Bangladesh System Metrics',
        showBackButton: false,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // KPI Summary Row 1
            Row(
              children: [
                Expanded(
                  child: _buildKpiCard(
                    'Partner Venues',
                    '$totalRestaurants',
                    '8 Divisions Covered',
                    Icons.store_mall_directory_outlined,
                    AppColors.primaryGreen,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildKpiCard(
                    'Active Diners',
                    '1,480+',
                    '+14% this month',
                    Icons.people_outline,
                    AppColors.darkGreen,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 12),

            // KPI Summary Row 2
            Row(
              children: [
                Expanded(
                  child: _buildKpiCard(
                    'Reservations',
                    '${totalBookings + 2480}',
                    '99.4% check-in rate',
                    Icons.calendar_month_outlined,
                    const Color(0xFF2563EB),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildKpiCard(
                    'Coverage',
                    '8 / 8',
                    'All Divisions Live',
                    Icons.map_outlined,
                    AppColors.accentGold,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 24),

            // Quick Admin Navigation Buttons
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    icon: const Icon(Icons.people, size: 18),
                    label: const Text('Manage Users'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.darkGreen,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    onPressed: () => context.go('/admin-users'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton.icon(
                    icon: const Icon(Icons.restaurant, size: 18),
                    label: const Text('Restaurants'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryGreen,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    onPressed: () => context.go('/admin-restaurants'),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 24),

            // Division Distribution Section
            Text(
              'Reservations by Administrative Division',
              style: GoogleFonts.poppins(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 12),

            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                children: [
                  _buildDivisionBar('Dhaka Division (Gulshan/Banani)', 0.52, '52% • 1,290 Bookings'),
                  const SizedBox(height: 12),
                  _buildDivisionBar('Chittagong Division (GEC/Agrabad)', 0.22, '22% • 545 Bookings'),
                  const SizedBox(height: 12),
                  _buildDivisionBar('Sylhet Division (Tea Estates)', 0.11, '11% • 270 Bookings'),
                  const SizedBox(height: 12),
                  _buildDivisionBar('Rajshahi & Rangpur (North)', 0.09, '9% • 220 Bookings'),
                  const SizedBox(height: 12),
                  _buildDivisionBar('Khulna, Barishal & Mymensingh', 0.06, '6% • 155 Bookings'),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildKpiCard(
    String title,
    String value,
    String subtext,
    IconData icon,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.borderLight),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 22, color: color),
          const SizedBox(height: 10),
          Text(
            value,
            style: GoogleFonts.inter(
              fontSize: 22,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            title,
            style: GoogleFonts.poppins(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          Text(
            subtext,
            style: GoogleFonts.inter(
              fontSize: 10,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDivisionBar(String division, double percent, String label) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              division,
              style: GoogleFonts.poppins(
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
            Text(
              label,
              style: GoogleFonts.inter(
                fontSize: 11,
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        ClipRRect(
          borderRadius: BorderRadius.circular(6),
          child: LinearProgressIndicator(
            value: percent,
            minHeight: 8,
            backgroundColor: AppColors.inputBackground,
            valueColor: const AlwaysStoppedAnimation<Color>(AppColors.primaryGreen),
          ),
        ),
      ],
    );
  }
}
