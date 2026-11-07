import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/mock/mock_data.dart';
import '../../../core/models/reservation_model.dart';
import '../../../core/widgets/app_header.dart';
import '../../../core/widgets/status_badge.dart';
import '../../reservation/providers/reservation_provider.dart';

class ManagerDashboardScreen extends ConsumerWidget {
  const ManagerDashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final resState = ref.watch(reservationProvider);
    final resNotifier = ref.read(reservationProvider.notifier);

    final restaurant = MockData.restaurants.first; // The Forest Lounge
    final reservations = resState.reservations;
    final confirmedCount = reservations.where((r) => r.status == ReservationStatus.confirmed).length;
    final checkedInCount = reservations.where((r) => r.status == ReservationStatus.checkedIn).length;
    final seatedCount = reservations.where((r) => r.status == ReservationStatus.seated).length;

    return Scaffold(
      backgroundColor: AppColors.backgroundWarm,
      appBar: AppHeader(
        title: '${restaurant.name} Host',
        subtitle: 'Manager Control Center',
        showBackButton: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.qr_code_scanner_rounded, color: AppColors.primaryGreen),
            onPressed: () => context.push('/manager-scanner'),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Welcome Card
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [AppColors.darkGreen, Color(0xFF165B36)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Shift Operations',
                        style: GoogleFonts.poppins(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: AppColors.mintGreen,
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          'Host Desk Active',
                          style: GoogleFonts.inter(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    '${restaurant.name} — Gulshan',
                    style: GoogleFonts.poppins(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Manage guest arrivals, assign tables, and verify QR passes in real time.',
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      color: Colors.white70,
                      height: 1.35,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // Metrics Row
            Row(
              children: [
                Expanded(
                  child: _buildMetricCard(
                    title: 'Upcoming',
                    count: '$confirmedCount',
                    color: AppColors.primaryGreen,
                    icon: Icons.bookmark_added_outlined,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildMetricCard(
                    title: 'Checked-In',
                    count: '$checkedInCount',
                    color: AppColors.darkGreen,
                    icon: Icons.how_to_reg_outlined,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildMetricCard(
                    title: 'Seated',
                    count: '$seatedCount',
                    color: AppColors.accentGold,
                    icon: Icons.table_restaurant_outlined,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 20),

            // Quick Actions
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    icon: const Icon(Icons.qr_code_scanner, size: 18),
                    label: const Text('Scan Guest QR'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryGreen,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    onPressed: () => context.push('/manager-scanner'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: OutlinedButton.icon(
                    icon: const Icon(Icons.table_bar, size: 18),
                    label: const Text('Table Floor'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.darkGreen,
                      side: const BorderSide(color: AppColors.darkGreen),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    onPressed: () => context.go('/manager-tables'),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 24),

            // Live Reservation Queue
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Today\'s Guest Arrival Queue',
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
                TextButton(
                  onPressed: () => context.go('/manager-reservations'),
                  child: Text(
                    'View All',
                    style: GoogleFonts.poppins(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: AppColors.primaryGreen,
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 8),

            ...reservations.take(4).map((booking) {
              return Container(
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(14),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.03),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        CircleAvatar(
                          radius: 16,
                          backgroundColor: AppColors.primaryGreen.withOpacity(0.12),
                          child: Text(
                            booking.userName[0],
                            style: GoogleFonts.poppins(
                              fontWeight: FontWeight.w600,
                              color: AppColors.primaryGreen,
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                booking.userName,
                                style: GoogleFonts.poppins(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              Text(
                                '${booking.bookingRef} • ${booking.userPhone}',
                                style: GoogleFonts.inter(
                                  fontSize: 11,
                                  color: AppColors.textSecondary,
                                ),
                              ),
                            ],
                          ),
                        ),
                        StatusBadge.fromReservationStatus(booking.status),
                      ],
                    ),

                    const SizedBox(height: 10),

                    Row(
                      children: [
                        Text(
                          '${booking.timeSlot} • ${booking.tableNumber} (${booking.tableSection}) • ${booking.guestCount} Guests',
                          style: GoogleFonts.poppins(
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            color: AppColors.textPrimary,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 10),

                    // Host Action Buttons
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        if (booking.status == ReservationStatus.confirmed)
                          ElevatedButton.icon(
                            icon: const Icon(Icons.check, size: 14),
                            label: const Text('Check In Guest'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primaryGreen,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                              textStyle: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w600),
                            ),
                            onPressed: () {
                              resNotifier.updateStatus(booking.id, ReservationStatus.checkedIn);
                            },
                          ),
                        if (booking.status == ReservationStatus.checkedIn)
                          ElevatedButton.icon(
                            icon: const Icon(Icons.restaurant, size: 14),
                            label: const Text('Seat Guest'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.darkGreen,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                              textStyle: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w600),
                            ),
                            onPressed: () {
                              resNotifier.updateStatus(booking.id, ReservationStatus.seated);
                            },
                          ),
                        if (booking.status == ReservationStatus.seated)
                          OutlinedButton.icon(
                            icon: const Icon(Icons.task_alt, size: 14),
                            label: const Text('Complete Dining'),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: AppColors.statusCompleted,
                              side: const BorderSide(color: AppColors.statusCompleted),
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                              textStyle: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w600),
                            ),
                            onPressed: () {
                              resNotifier.updateStatus(booking.id, ReservationStatus.completed);
                            },
                          ),
                      ],
                    ),
                  ],
                ),
              );
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildMetricCard({
    required String title,
    required String count,
    required Color color,
    required IconData icon,
  }) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.borderLight),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 20, color: color),
          const SizedBox(height: 8),
          Text(
            count,
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
              fontSize: 11,
              fontWeight: FontWeight.w500,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}
