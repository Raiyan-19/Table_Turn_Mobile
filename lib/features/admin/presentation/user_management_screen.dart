import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/mock/mock_data.dart';
import '../../../core/models/user_model.dart';
import '../../../core/widgets/app_header.dart';

class UserManagementScreen extends StatefulWidget {
  const UserManagementScreen({super.key});

  @override
  State<UserManagementScreen> createState() => _UserManagementScreenState();
}

class _UserManagementScreenState extends State<UserManagementScreen> {
  final List<UserModel> _users = [
    MockData.defaultCustomer,
    MockData.defaultManager,
    MockData.defaultAdmin,
    UserModel(
      id: 'user_04',
      name: 'Nabila Karim',
      email: 'nabila@gmail.com',
      phone: '+8801722334455',
      role: UserRole.customer,
      isPhoneVerified: true,
      isEmailVerified: true,
      createdAt: DateTime.now().subtract(const Duration(days: 15)),
    ),
    UserModel(
      id: 'user_05',
      name: 'Fahim Shakil',
      email: 'manager@skyline.bd',
      phone: '+8801822334455',
      role: UserRole.manager,
      managedRestaurantId: 'rest_02',
      isPhoneVerified: true,
      isEmailVerified: true,
      createdAt: DateTime.now().subtract(const Duration(days: 45)),
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundWarm,
      appBar: const AppHeader(
        title: 'Platform Users',
        subtitle: 'Manage diners & restaurant managers',
        showBackButton: false,
      ),
      body: ListView.separated(
        padding: const EdgeInsets.all(20),
        itemCount: _users.length,
        separatorBuilder: (_, __) => const SizedBox(height: 12),
        itemBuilder: (context, index) {
          final user = _users[index];
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
            child: Row(
              children: [
                CircleAvatar(
                  radius: 20,
                  backgroundColor: AppColors.primaryGreen.withOpacity(0.12),
                  child: Text(
                    user.name[0],
                    style: GoogleFonts.poppins(
                      fontWeight: FontWeight.w700,
                      color: AppColors.primaryGreen,
                    ),
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              user.name,
                              style: GoogleFonts.poppins(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: user.role == UserRole.admin
                                  ? Colors.purple.shade50
                                  : user.role == UserRole.manager
                                      ? AppColors.lightGreen
                                      : Colors.blue.shade50,
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              user.role.displayName,
                              style: GoogleFonts.inter(
                                fontSize: 10,
                                fontWeight: FontWeight.w600,
                                color: user.role == UserRole.admin
                                    ? Colors.purple
                                    : user.role == UserRole.manager
                                        ? AppColors.primaryGreen
                                        : Colors.blue.shade800,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '${user.email} • ${user.phone}',
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
          );
        },
      ),
    );
  }
}
