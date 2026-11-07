import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/models/reservation_model.dart';
import '../../../core/widgets/app_header.dart';
import '../../../core/widgets/empty_state_widget.dart';
import '../../../core/widgets/status_badge.dart';
import '../providers/reservation_provider.dart';

class BookingListScreen extends ConsumerWidget {
  const BookingListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final resState = ref.watch(reservationProvider);
    final upcoming = resState.upcomingReservations;
    final past = resState.pastReservations;

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: AppColors.backgroundWarm,
        appBar: const AppHeader(
          title: 'My Reservations',
          subtitle: 'Active passes & booking history',
          showBackButton: false,
        ),
        body: Column(
          children: [
            // Tabs Bar
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              decoration: BoxDecoration(
                color: AppColors.inputBackground,
                borderRadius: BorderRadius.circular(12),
              ),
              child: TabBar(
                indicatorSize: TabBarIndicatorSize.tab,
                indicator: BoxDecoration(
                  color: AppColors.primaryGreen,
                  borderRadius: BorderRadius.circular(10),
                ),
                labelColor: Colors.white,
                unselectedLabelColor: AppColors.textSecondary,
                labelStyle: GoogleFonts.poppins(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
                unselectedLabelStyle: GoogleFonts.poppins(
                  fontSize: 13,
                  fontWeight: FontWeight.w400,
                ),
                dividerColor: Colors.transparent,
                tabs: [
                  Tab(text: 'Upcoming (${upcoming.length})'),
                  Tab(text: 'Past History (${past.length})'),
                ],
              ),
            ),

            // Tabs Content
            Expanded(
              child: TabBarView(
                children: [
                  _buildBookingsList(context, upcoming, isUpcoming: true),
                  _buildBookingsList(context, past, isUpcoming: false),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBookingsList(
    BuildContext context,
    List<ReservationModel> list, {
    required bool isUpcoming,
  }) {
    if (list.isEmpty) {
      return EmptyStateWidget(
        icon: isUpcoming ? Icons.calendar_today_outlined : Icons.history,
        title: isUpcoming ? 'No Active Reservations' : 'No Past Bookings',
        message: isUpcoming
            ? 'You don\'t have any upcoming reservations right now. Browse top dining spots across Bangladesh!'
            : 'Your completed or past dining history will appear here.',
        buttonText: isUpcoming ? 'Find a Table' : null,
        onButtonPressed: isUpcoming ? () => context.go('/home') : null,
      );
    }

    final dateFormatter = DateFormat('EEE, d MMM yyyy');

    return ListView.separated(
      padding: const EdgeInsets.all(20),
      itemCount: list.length,
      separatorBuilder: (_, __) => const SizedBox(height: 14),
      itemBuilder: (context, index) {
        final booking = list[index];

        return Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.04),
                blurRadius: 10,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: BorderRadius.circular(16),
              onTap: () => context.push('/booking-detail/${booking.id}'),
              child: Padding(
                padding: const EdgeInsets.all(14.0),
                child: Column(
                  children: [
                    // Top: Restaurant & Status
                    Row(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: SizedBox(
                            width: 54,
                            height: 54,
                            child: Image.network(
                              booking.restaurantCoverPhoto,
                              fit: BoxFit.cover,
                              errorBuilder: (_, __, ___) => Container(
                                color: AppColors.inputBackground,
                                child: const Icon(Icons.restaurant),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                booking.restaurantName,
                                style: GoogleFonts.poppins(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.textPrimary,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 2),
                              Text(
                                'Ref: ${booking.bookingRef}',
                                style: GoogleFonts.inter(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w500,
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

                    // Date, Time & Table info
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            const Icon(Icons.calendar_today, size: 13, color: AppColors.primaryGreen),
                            const SizedBox(width: 5),
                            Text(
                              dateFormatter.format(booking.reservationDate),
                              style: GoogleFonts.poppins(fontSize: 12, color: AppColors.textPrimary),
                            ),
                          ],
                        ),
                        Row(
                          children: [
                            const Icon(Icons.access_time, size: 13, color: AppColors.primaryGreen),
                            const SizedBox(width: 5),
                            Text(
                              booking.timeSlot,
                              style: GoogleFonts.poppins(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: AppColors.textPrimary,
                              ),
                            ),
                          ],
                        ),
                        Row(
                          children: [
                            const Icon(Icons.people_outline, size: 14, color: AppColors.primaryGreen),
                            const SizedBox(width: 4),
                            Text(
                              '${booking.guestCount} Guests',
                              style: GoogleFonts.poppins(fontSize: 12, color: AppColors.textPrimary),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

