import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/models/reservation_model.dart';
import '../../../core/widgets/app_header.dart';
import '../../../core/widgets/empty_state_widget.dart';
import '../../../core/widgets/status_badge.dart';
import '../../reservation/providers/reservation_provider.dart';

class ManagerReservationsScreen extends ConsumerStatefulWidget {
  const ManagerReservationsScreen({super.key});

  @override
  ConsumerState<ManagerReservationsScreen> createState() =>
      _ManagerReservationsScreenState();
}

class _ManagerReservationsScreenState
    extends ConsumerState<ManagerReservationsScreen> {
  String _filter = 'All';

  @override
  Widget build(BuildContext context) {
    final resState = ref.watch(reservationProvider);
    final resNotifier = ref.read(reservationProvider.notifier);

    final all = resState.reservations;
    final filtered = all.where((r) {
      if (_filter == 'All') return true;
      if (_filter == 'Confirmed') return r.status == ReservationStatus.confirmed;
      if (_filter == 'Checked In') return r.status == ReservationStatus.checkedIn;
      if (_filter == 'Seated') return r.status == ReservationStatus.seated;
      if (_filter == 'Completed') return r.status == ReservationStatus.completed;
      return true;
    }).toList();

    final dateFormatter = DateFormat('EEE, d MMM yyyy');

    return Scaffold(
      backgroundColor: AppColors.backgroundWarm,
      appBar: const AppHeader(
        title: 'Reservations Management',
        subtitle: 'Live floor guest bookings',
        showBackButton: false,
      ),
      body: Column(
        children: [
          // Filter Chips
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            child: Row(
              children: ['All', 'Confirmed', 'Checked In', 'Seated', 'Completed']
                  .map((f) {
                final isSelected = _filter == f;
                return Padding(
                  padding: const EdgeInsets.only(right: 8.0),
                  child: FilterChip(
                    label: Text(f),
                    selected: isSelected,
                    selectedColor: AppColors.primaryGreen,
                    labelStyle: GoogleFonts.poppins(
                      fontSize: 12,
                      fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                      color: isSelected ? Colors.white : AppColors.textPrimary,
                    ),
                    backgroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                      side: BorderSide(
                        color: isSelected ? AppColors.primaryGreen : AppColors.borderLight,
                      ),
                    ),
                    onSelected: (_) => setState(() => _filter = f),
                  ),
                );
              }).toList(),
            ),
          ),

          // Reservation List
          Expanded(
            child: filtered.isEmpty
                ? const EmptyStateWidget(
                    icon: Icons.event_available,
                    title: 'No Reservations in this Filter',
                    message: 'There are currently no guest bookings matching this status.',
                  )
                : ListView.separated(
                    padding: const EdgeInsets.all(20),
                    itemCount: filtered.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 14),
                    itemBuilder: (context, index) {
                      final booking = filtered[index];

                      return Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(14),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.03),
                              blurRadius: 8,
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
                                        'Ref: ${booking.bookingRef} • Phone: ${booking.userPhone}',
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

                            const Divider(height: 20),

                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  dateFormatter.format(booking.reservationDate),
                                  style: GoogleFonts.poppins(
                                    fontSize: 12,
                                    color: AppColors.textSecondary,
                                  ),
                                ),
                                Text(
                                  booking.timeSlot,
                                  style: GoogleFonts.poppins(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.primaryGreen,
                                  ),
                                ),
                                Text(
                                  '${booking.tableNumber} • ${booking.guestCount} Guests',
                                  style: GoogleFonts.poppins(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),

                            const SizedBox(height: 12),

                            // Action Progress
                            Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                if (booking.status == ReservationStatus.confirmed)
                                  ElevatedButton(
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: AppColors.primaryGreen,
                                      foregroundColor: Colors.white,
                                    ),
                                    onPressed: () => resNotifier.updateStatus(
                                      booking.id,
                                      ReservationStatus.checkedIn,
                                    ),
                                    child: const Text('Mark Checked-In'),
                                  ),
                                if (booking.status == ReservationStatus.checkedIn)
                                  ElevatedButton(
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: AppColors.darkGreen,
                                      foregroundColor: Colors.white,
                                    ),
                                    onPressed: () => resNotifier.updateStatus(
                                      booking.id,
                                      ReservationStatus.seated,
                                    ),
                                    child: const Text('Mark Seated'),
                                  ),
                                if (booking.status == ReservationStatus.seated)
                                  ElevatedButton(
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: AppColors.statusCompleted,
                                      foregroundColor: Colors.white,
                                    ),
                                    onPressed: () => resNotifier.updateStatus(
                                      booking.id,
                                      ReservationStatus.completed,
                                    ),
                                    child: const Text('Complete Reservation'),
                                  ),
                              ],
                            ),
                          ],
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}

