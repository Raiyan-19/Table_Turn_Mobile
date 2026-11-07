import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/widgets/app_header.dart';

class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final notifications = [
      {
        'title': 'Reservation Confirmed',
        'body': 'Your table for 2 at The Forest Lounge (Gulshan-2) is confirmed for tomorrow at 07:30 PM.',
        'time': '2 hours ago',
        'icon': Icons.check_circle_outline,
        'color': AppColors.primaryGreen,
      },
      {
        'title': 'Upcoming Dining Reminder',
        'body': 'Reminder: Your reservation at Skyline Terrace Dining starts in 2 hours. Have your QR pass ready.',
        'time': '1 day ago',
        'icon': Icons.alarm,
        'color': AppColors.statusPending,
      },
      {
        'title': 'New Restaurant Added',
        'body': 'Seven Layer Green Garden is now open for instant table reservations in Sylhet.',
        'time': '3 days ago',
        'icon': Icons.restaurant,
        'color': AppColors.darkGreen,
      },
    ];

    return Scaffold(
      backgroundColor: AppColors.backgroundWarm,
      appBar: const AppHeader(
        title: 'Notifications',
        subtitle: 'Booking alerts & reminders',
      ),
      body: ListView.separated(
        padding: const EdgeInsets.all(20),
        itemCount: notifications.length,
        separatorBuilder: (_, __) => const SizedBox(height: 12),
        itemBuilder: (context, index) {
          final item = notifications[index];
          return Container(
            padding: const EdgeInsets.all(16),
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
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CircleAvatar(
                  radius: 18,
                  backgroundColor: (item['color'] as Color).withOpacity(0.12),
                  child: Icon(item['icon'] as IconData, size: 20, color: item['color'] as Color),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              item['title'] as String,
                              style: GoogleFonts.poppins(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: AppColors.textPrimary,
                              ),
                            ),
                          ),
                          Text(
                            item['time'] as String,
                            style: GoogleFonts.inter(
                              fontSize: 11,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        item['body'] as String,
                        style: GoogleFonts.poppins(
                          fontSize: 12,
                          color: AppColors.textSecondary,
                          height: 1.35,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
