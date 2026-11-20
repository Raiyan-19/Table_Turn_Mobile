import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/models/reservation_model.dart';
import '../../../core/widgets/app_header.dart';
import '../../../core/widgets/primary_button.dart';
import '../../auth/providers/auth_provider.dart';
import '../../reservation/providers/reservation_provider.dart';

class QrScannerScreen extends ConsumerStatefulWidget {
  const QrScannerScreen({super.key});

  @override
  ConsumerState<QrScannerScreen> createState() => _QrScannerScreenState();
}

class _QrScannerScreenState extends ConsumerState<QrScannerScreen> {
  final _refController = TextEditingController();
  ReservationModel? _matchedBooking;
  bool _hasSearched = false;
  String? _searchErrorMessage;

  @override
  void dispose() {
    _refController.dispose();
    super.dispose();
  }

  void _verifyCode(String query) async {
    final cleanQuery = query.trim().toUpperCase();
    if (cleanQuery.isEmpty) return;

    final resState = ref.read(reservationProvider);
    final resNotifier = ref.read(reservationProvider.notifier);
    final currentManager = ref.read(authProvider).currentUser;
    final managedRestId = currentManager?.managedRestaurantId;

    ReservationModel? match;
    String? error;

    try {
      final found = resState.reservations.firstWhere(
        (r) =>
            r.bookingRef.toUpperCase() == cleanQuery ||
            r.qrCodeData.toUpperCase() == cleanQuery ||
            r.qrCodeData.toUpperCase().startsWith('$cleanQuery:'),
      );
      match = found;
    } catch (_) {
      // Try online verification with backend
      final onlineMatch = await resNotifier.verifyQrCodeOnline(
        cleanQuery,
        managerRestaurantId: managedRestId,
      );
      if (onlineMatch != null) {
        match = onlineMatch;
      }
    }

    if (match != null) {
      // Check tenant isolation: manager cannot check in a reservation for a different restaurant
      if (managedRestId != null && match.restaurantId != managedRestId) {
        error =
            'Security Alert: This reservation belongs to "${match.restaurantName}". Cross-restaurant check-in is forbidden.';
      } else if (match.status == ReservationStatus.checkedIn ||
          match.status == ReservationStatus.completed) {
        error = 'Notice: This guest has already been checked in.';
      } else if (match.status == ReservationStatus.cancelled) {
        error = 'Notice: This reservation was cancelled.';
      }
    } else {
      error =
          'No active reservation matches that code. Please verify the code or scan again.';
    }

    if (mounted) {
      setState(() {
        _matchedBooking = match;
        _searchErrorMessage = error;
        _hasSearched = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final resNotifier = ref.read(reservationProvider.notifier);

    return Scaffold(
      backgroundColor: AppColors.backgroundWarm,
      appBar: const AppHeader(
        title: 'QR Pass Verification',
        subtitle: 'Host check-in scanner',
        showBackButton: false,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            // Scanner Viewport Mockup
            Container(
              height: 250,
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.black,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: AppColors.primaryGreen, width: 2),
              ),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        width: 140,
                        height: 140,
                        decoration: BoxDecoration(
                          border: Border.all(color: AppColors.mintGreen, width: 2),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: const Center(
                          child: Icon(
                            Icons.qr_code_scanner,
                            size: 64,
                            color: Colors.white70,
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'Align Diner QR Pass within frame',
                        style: GoogleFonts.poppins(
                          fontSize: 12,
                          color: Colors.white70,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Manual Code Lookup
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Manual Verification by Reference',
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _refController,
                          textCapitalization: TextCapitalization.characters,
                          decoration: InputDecoration(
                            hintText: 'e.g. TT-2026-9812',
                            filled: true,
                            fillColor: AppColors.inputBackground,
                            contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide: BorderSide.none,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primaryGreen,
                          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        onPressed: () => _verifyCode(_refController.text),
                        child: Text(
                          'Lookup',
                          style: GoogleFonts.poppins(color: Colors.white, fontWeight: FontWeight.w600),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // Matched Result Card or Error
            if (_hasSearched) ...[
              if (_searchErrorMessage != null) ...[
                Container(
                  padding: const EdgeInsets.all(16),
                  margin: const EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(
                    color: _matchedBooking == null ? Colors.red.shade50 : Colors.amber.shade50,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: _matchedBooking == null ? Colors.red.shade300 : Colors.amber.shade400,
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        _matchedBooking == null ? Icons.error_outline : Icons.info_outline,
                        color: _matchedBooking == null ? Colors.red : Colors.amber.shade900,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          _searchErrorMessage!,
                          style: GoogleFonts.poppins(
                            fontSize: 13,
                            color: _matchedBooking == null ? Colors.red.shade800 : Colors.amber.shade900,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
              if (_matchedBooking != null && _searchErrorMessage == null)
                Container(
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppColors.primaryGreen, width: 1.5),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.verified, color: AppColors.primaryGreen, size: 22),
                          const SizedBox(width: 8),
                          Text(
                            'Valid Reservation Found',
                            style: GoogleFonts.poppins(
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                              color: AppColors.darkGreen,
                            ),
                          ),
                        ],
                      ),
                      const Divider(height: 20),
                      Text(
                        'Guest: ${_matchedBooking!.userName}',
                        style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.w600),
                      ),
                      Text(
                        'Phone: ${_matchedBooking!.userPhone}',
                        style: GoogleFonts.inter(fontSize: 12, color: AppColors.textSecondary),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'Time: ${_matchedBooking!.timeSlot} • ${_matchedBooking!.tableNumber} (${_matchedBooking!.tableSection})',
                        style: GoogleFonts.poppins(fontSize: 13, fontWeight: FontWeight.w500),
                      ),
                      Text(
                        'Party Size: ${_matchedBooking!.guestCount} Diners',
                        style: GoogleFonts.poppins(fontSize: 12, color: AppColors.textSecondary),
                      ),
                      const SizedBox(height: 16),
                      PrimaryButton(
                        text: 'Confirm Check-In & Seat Guest',
                        height: 48,
                        onPressed: () {
                          resNotifier.updateStatus(
                            _matchedBooking!.id,
                            ReservationStatus.checkedIn,
                          );
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Guest ${_matchedBooking!.userName} checked in!'),
                              backgroundColor: AppColors.primaryGreen,
                            ),
                          );
                          setState(() {
                            _matchedBooking = null;
                            _hasSearched = false;
                            _searchErrorMessage = null;
                            _refController.clear();
                          });
                        },
                      ),
                    ],
                  ),
                ),
            ],
          ],
        ),
      ),
    );
  }
}

