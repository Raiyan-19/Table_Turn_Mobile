import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/mock/mock_data.dart';
import '../../../core/widgets/app_header.dart';
import '../../../core/widgets/primary_button.dart';
import '../../auth/providers/auth_provider.dart';
import '../providers/reservation_provider.dart';

class ReservationConfirmationScreen extends ConsumerStatefulWidget {
  const ReservationConfirmationScreen({super.key});

  @override
  ConsumerState<ReservationConfirmationScreen> createState() =>
      _ReservationConfirmationScreenState();
}

class _ReservationConfirmationScreenState
    extends ConsumerState<ReservationConfirmationScreen> {
  bool _isSubmitting = false;

  void _onConfirm() async {
    setState(() => _isSubmitting = true);
    await Future.delayed(const Duration(milliseconds: 700));

    final resNotifier = ref.read(reservationProvider.notifier);
    final newBooking = resNotifier.createReservation();

    if (mounted) {
      setState(() => _isSubmitting = false);
      context.go('/booking-success/${newBooking.id}');
    }
  }

  @override
  Widget build(BuildContext context) {
    final resState = ref.watch(reservationProvider);
    final authState = ref.watch(authProvider);
    final draft = resState.draft;

    final restaurant = draft.restaurant ?? MockData.restaurants.first;
    final table = draft.selectedTable ?? MockData.tables.first;
    final user = authState.currentUser ?? MockData.defaultCustomer;
    final dateFormatter = DateFormat('EEEE, d MMMM yyyy');

    return Scaffold(
      backgroundColor: AppColors.backgroundWarm,
      appBar: const AppHeader(
        title: 'Review Booking',
        subtitle: 'TableTurn Smart Reservation',
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Restaurant Card Header
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.04),
                          blurRadius: 10,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: SizedBox(
                            width: 65,
                            height: 65,
                            child: Image.network(
                              restaurant.coverPhoto,
                              fit: BoxFit.cover,
                              errorBuilder: (_, __, ___) => Container(color: AppColors.inputBackground),
                            ),
                          ),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                restaurant.name,
                                style: GoogleFonts.poppins(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.textPrimary,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 2),
                              Text(
                                restaurant.address,
                                style: GoogleFonts.poppins(
                                  fontSize: 12,
                                  color: AppColors.textSecondary,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 4),
                              Text(
                                restaurant.division.label,
                                style: GoogleFonts.inter(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.primaryGreen,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Reservation Details Card
                  Text(
                    'Reservation Details',
                    style: GoogleFonts.poppins(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Container(
                    padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Column(
                      children: [
                        _buildDetailRow(
                          'Date',
                          dateFormatter.format(draft.reservationDate),
                          Icons.calendar_today_outlined,
                        ),
                        const Divider(height: 24),
                        _buildDetailRow(
                          'Time Slot',
                          draft.selectedTimeSlot,
                          Icons.access_time,
                        ),
                        const Divider(height: 24),
                        _buildDetailRow(
                          'Party Size',
                          '${draft.partySize} ${draft.partySize == 1 ? 'Guest' : 'Guests'}',
                          Icons.group_outlined,
                        ),
                        const Divider(height: 24),
                        _buildDetailRow(
                          'Table',
                          '${table.tableNumber} (${table.section.label})',
                          Icons.table_restaurant_outlined,
                        ),
                        if (draft.specialRequests.isNotEmpty) ...[
                          const Divider(height: 24),
                          _buildDetailRow(
                            'Special Notes',
                            draft.specialRequests,
                            Icons.notes_outlined,
                          ),
                        ],
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Diner Information Card
                  Text(
                    'Guest Contact',
                    style: GoogleFonts.poppins(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Row(
                      children: [
                        CircleAvatar(
                          radius: 18,
                          backgroundColor: AppColors.primaryGreen.withOpacity(0.12),
                          child: const Icon(Icons.person, color: AppColors.primaryGreen, size: 20),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                user.name,
                                style: GoogleFonts.poppins(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              Text(
                                '${user.phone} • ${user.email}',
                                style: GoogleFonts.poppins(
                                  fontSize: 12,
                                  color: AppColors.textSecondary,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Policy Alert Box
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: AppColors.lightGreen,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppColors.primaryGreen.withOpacity(0.3)),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(Icons.info_outline, color: AppColors.primaryGreen, size: 20),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            'Free cancellation up to 2 hours before dining time. Digital QR code pass will be activated instantly upon confirmation.',
                            style: GoogleFonts.poppins(
                              fontSize: 12,
                              color: AppColors.darkGreen,
                              height: 1.4,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),

          // Bottom CTA
          Container(
            padding: const EdgeInsets.fromLTRB(20, 14, 20, 24),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.06),
                  blurRadius: 10,
                  offset: const Offset(0, -3),
                ),
              ],
            ),
            child: SafeArea(
              top: false,
              child: PrimaryButton(
                text: 'Confirm & Generate QR Pass',
                height: 52,
                isLoading: _isSubmitting,
                onPressed: _onConfirm,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value, IconData icon) {
    return Row(
      children: [
        Icon(icon, size: 18, color: AppColors.primaryGreen),
        const SizedBox(width: 12),
        Text(
          label,
          style: GoogleFonts.poppins(
            fontSize: 13,
            color: AppColors.textSecondary,
          ),
        ),
        const Spacer(),
        Expanded(
          flex: 2,
          child: Text(
            value,
            textAlign: TextAlign.end,
            style: GoogleFonts.poppins(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
        ),
      ],
    );
  }
}
