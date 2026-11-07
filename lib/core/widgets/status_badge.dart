import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../constants/app_colors.dart';
import '../models/reservation_model.dart';
import '../models/table_model.dart';

class StatusBadge extends StatelessWidget {
  final String label;
  final Color backgroundColor;
  final Color textColor;
  final IconData? icon;

  const StatusBadge({
    super.key,
    required this.label,
    required this.backgroundColor,
    required this.textColor,
    this.icon,
  });

  factory StatusBadge.fromReservationStatus(ReservationStatus status) {
    switch (status) {
      case ReservationStatus.confirmed:
        return StatusBadge(
          label: status.label,
          backgroundColor: AppColors.primaryGreen.withOpacity(0.12),
          textColor: AppColors.primaryGreen,
          icon: Icons.check_circle_outline,
        );
      case ReservationStatus.checkedIn:
        return StatusBadge(
          label: status.label,
          backgroundColor: AppColors.mintGreen.withOpacity(0.35),
          textColor: AppColors.darkGreen,
          icon: Icons.qr_code_scanner,
        );
      case ReservationStatus.seated:
        return StatusBadge(
          label: status.label,
          backgroundColor: AppColors.statusSeated.withOpacity(0.15),
          textColor: AppColors.statusSeated,
          icon: Icons.restaurant,
        );
      case ReservationStatus.pending:
        return StatusBadge(
          label: status.label,
          backgroundColor: AppColors.statusPending.withOpacity(0.15),
          textColor: AppColors.statusPending,
          icon: Icons.access_time,
        );
      case ReservationStatus.completed:
        return StatusBadge(
          label: status.label,
          backgroundColor: AppColors.statusCompleted.withOpacity(0.12),
          textColor: AppColors.statusCompleted,
          icon: Icons.task_alt,
        );
      case ReservationStatus.cancelled:
        return StatusBadge(
          label: status.label,
          backgroundColor: AppColors.statusReserved.withOpacity(0.12),
          textColor: AppColors.statusReserved,
          icon: Icons.cancel_outlined,
        );
    }
  }

  factory StatusBadge.fromTableStatus(TableStatus status) {
    switch (status) {
      case TableStatus.available:
        return const StatusBadge(
          label: 'Available',
          backgroundColor: Color(0xFFDCFCE7),
          textColor: Color(0xFF15803D),
          icon: Icons.fiber_manual_record,
        );
      case TableStatus.reserved:
        return const StatusBadge(
          label: 'Reserved',
          backgroundColor: Color(0xFFFEE2E2),
          textColor: Color(0xFFB91C1C),
          icon: Icons.access_time_filled,
        );
      case TableStatus.occupied:
        return const StatusBadge(
          label: 'Occupied',
          backgroundColor: Color(0xFFFEF3C7),
          textColor: Color(0xFFB45309),
          icon: Icons.people,
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 13, color: textColor),
            const SizedBox(width: 4),
          ],
          Text(
            label,
            style: GoogleFonts.inter(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: textColor,
            ),
          ),
        ],
      ),
    );
  }
}
