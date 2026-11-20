import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/mock/mock_data.dart';
import '../../../core/widgets/app_header.dart';
import '../../../core/widgets/primary_button.dart';
import '../providers/reservation_provider.dart';
import '../../restaurant/providers/restaurant_content_provider.dart';

class MakeReservationScreen extends ConsumerStatefulWidget {
  final String restaurantId;

  const MakeReservationScreen({
    super.key,
    required this.restaurantId,
  });

  @override
  ConsumerState<MakeReservationScreen> createState() => _MakeReservationScreenState();
}

class _MakeReservationScreenState extends ConsumerState<MakeReservationScreen> {
  final _specialRequestsController = TextEditingController();

  final List<String> _timeSlots = [
    '12:30 PM',
    '01:00 PM',
    '01:30 PM',
    '07:00 PM',
    '07:30 PM',
    '08:00 PM',
    '08:30 PM',
    '09:00 PM',
  ];

  @override
  void dispose() {
    _specialRequestsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final resState = ref.watch(reservationProvider);
    final resNotifier = ref.read(reservationProvider.notifier);
    final draft = resState.draft;

    final restaurant = draft.restaurant ??
        MockData.restaurants.firstWhere(
          (r) => r.id == widget.restaurantId,
          orElse: () => MockData.restaurants.first,
        );

    final tablesList = ref.watch(restaurantTablesProvider(restaurant.id));
    final availableTables = tablesList.where((t) => t.isAvailable).toList();

    return Scaffold(
      backgroundColor: AppColors.backgroundWarm,
      appBar: AppHeader(
        title: 'Reserve Table',
        subtitle: restaurant.name,
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 1. Date Selector
                  Text(
                    '1. Select Date',
                    style: GoogleFonts.poppins(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    height: 74,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      itemCount: 14,
                      separatorBuilder: (_, __) => const SizedBox(width: 10),
                      itemBuilder: (context, index) {
                        final date = DateTime.now().add(Duration(days: index + 1));
                        final isSelected = DateUtils.isSameDay(date, draft.reservationDate);
                        final dayName = DateFormat('EEE').format(date);
                        final dayNum = DateFormat('d').format(date);
                        final monthName = DateFormat('MMM').format(date);

                        return GestureDetector(
                          onTap: () => resNotifier.setDate(date),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            width: 60,
                            padding: const EdgeInsets.symmetric(vertical: 8),
                            decoration: BoxDecoration(
                              color: isSelected ? AppColors.primaryGreen : Colors.white,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: isSelected ? AppColors.primaryGreen : AppColors.borderLight,
                              ),
                              boxShadow: isSelected
                                  ? [
                                      BoxShadow(
                                        color: AppColors.primaryGreen.withOpacity(0.3),
                                        blurRadius: 8,
                                        offset: const Offset(0, 3),
                                      ),
                                    ]
                                  : null,
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  dayName,
                                  style: GoogleFonts.inter(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w500,
                                    color: isSelected ? AppColors.mintGreen : AppColors.textSecondary,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  dayNum,
                                  style: GoogleFonts.inter(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w700,
                                    color: isSelected ? Colors.white : AppColors.textPrimary,
                                  ),
                                ),
                                Text(
                                  monthName,
                                  style: GoogleFonts.inter(
                                    fontSize: 10,
                                    color: isSelected ? Colors.white70 : AppColors.textSecondary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),

                  const SizedBox(height: 24),

                  // 2. Party Size Stepper
                  Text(
                    '2. Party Size (Guests)',
                    style: GoogleFonts.poppins(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: AppColors.borderLight),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            const Icon(Icons.group_outlined, color: AppColors.primaryGreen),
                            const SizedBox(width: 10),
                            Text(
                              '${draft.partySize} ${draft.partySize == 1 ? 'Guest' : 'Guests'}',
                              style: GoogleFonts.poppins(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: AppColors.textPrimary,
                              ),
                            ),
                          ],
                        ),
                        Row(
                          children: [
                            _buildStepperButton(
                              icon: Icons.remove,
                              onTap: draft.partySize > 1
                                  ? () => resNotifier.setPartySize(draft.partySize - 1)
                                  : null,
                            ),
                            const SizedBox(width: 12),
                            _buildStepperButton(
                              icon: Icons.add,
                              onTap: draft.partySize < 12
                                  ? () => resNotifier.setPartySize(draft.partySize + 1)
                                  : null,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),

                  // 3. Time Slot Grid
                  Text(
                    '3. Preferred Dining Time',
                    style: GoogleFonts.poppins(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 10,
                    runSpacing: 10,
                    children: _timeSlots.map((slot) {
                      final isSelected = draft.selectedTimeSlot == slot;
                      return GestureDetector(
                        onTap: () => resNotifier.setTimeSlot(slot),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                          decoration: BoxDecoration(
                            color: isSelected ? AppColors.darkGreen : Colors.white,
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                              color: isSelected ? AppColors.darkGreen : AppColors.borderLight,
                            ),
                          ),
                          child: Text(
                            slot,
                            style: GoogleFonts.inter(
                              fontSize: 13,
                              fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                              color: isSelected ? Colors.white : AppColors.textPrimary,
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),

                  const SizedBox(height: 24),

                  // 4. Select Seating / Table Section
                  Text(
                    '4. Select Table & Seating Area',
                    style: GoogleFonts.poppins(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 12),
                  if (availableTables.isEmpty)
                    Text(
                      'All tables currently booked. Please try another time.',
                      style: GoogleFonts.poppins(color: Colors.red),
                    )
                  else
                    ...availableTables.map((table) {
                      final isSelected = draft.selectedTable?.id == table.id;
                      return Container(
                        margin: const EdgeInsets.only(bottom: 10),
                        decoration: BoxDecoration(
                          color: isSelected ? AppColors.lightGreen : Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: isSelected ? AppColors.primaryGreen : AppColors.borderLight,
                            width: isSelected ? 1.5 : 1,
                          ),
                        ),
                        child: Material(
                          color: Colors.transparent,
                          child: InkWell(
                            borderRadius: BorderRadius.circular(12),
                            onTap: () => resNotifier.setSelectedTable(table),
                            child: Padding(
                              padding: const EdgeInsets.all(14.0),
                              child: Row(
                                children: [
                                  Icon(
                                    isSelected ? Icons.radio_button_checked : Icons.radio_button_off,
                                    color: isSelected ? AppColors.primaryGreen : AppColors.textSecondary,
                                    size: 20,
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          '${table.tableNumber} — ${table.section.label}',
                                          style: GoogleFonts.poppins(
                                            fontSize: 14,
                                            fontWeight: FontWeight.w600,
                                            color: AppColors.textPrimary,
                                          ),
                                        ),
                                        Text(
                                          'Seats up to ${table.capacity} guests • Min spend ৳${table.minimumSpend.toStringAsFixed(0)}',
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
                          ),
                        ),
                      );
                    }),

                  const SizedBox(height: 20),

                  // 5. Special Notes / Dietary Requests
                  Text(
                    '5. Special Requests (Optional)',
                    style: GoogleFonts.poppins(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 10),
                  TextField(
                    controller: _specialRequestsController,
                    maxLines: 2,
                    onChanged: (val) => resNotifier.setSpecialRequests(val),
                    decoration: InputDecoration(
                      hintText: 'e.g., quiet corner, anniversary setup, baby chair...',
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: const BorderSide(color: AppColors.borderLight),
                      ),
                    ),
                  ),

                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),

          // Bottom Action
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
                text: 'Review & Confirm Reservation',
                height: 52,
                onPressed: () {
                  context.push('/reservation-confirm');
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStepperButton({
    required IconData icon,
    required VoidCallback? onTap,
  }) {
    return Material(
      color: onTap != null ? AppColors.inputBackground : Colors.grey.shade200,
      borderRadius: BorderRadius.circular(8),
      child: InkWell(
        borderRadius: BorderRadius.circular(8),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Icon(
            icon,
            size: 18,
            color: onTap != null ? AppColors.darkGreen : Colors.grey,
          ),
        ),
      ),
    );
  }
}
