import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/constants/app_colors.dart';
import '../../core/models/user_model.dart';
import '../auth/providers/auth_provider.dart';

class MainScaffold extends ConsumerWidget {
  final Widget child;

  const MainScaffold({
    super.key,
    required this.child,
  });

  int _calculateSelectedIndex(BuildContext context, UserRole role) {
    final location = GoRouterState.of(context).uri.toString();
    if (role == UserRole.manager) {
      if (location.startsWith('/manager-reservations')) return 1;
      if (location.startsWith('/manager-tables')) return 2;
      if (location.startsWith('/manager-scanner')) return 3;
      return 0; // manager-dashboard
    }
    if (role == UserRole.admin) {
      if (location.startsWith('/admin-users')) return 1;
      if (location.startsWith('/admin-restaurants')) return 2;
      return 0; // admin-dashboard
    }
    // Default Customer navigation
    if (location.startsWith('/search')) return 1;
    if (location.startsWith('/bookings')) return 2;
    if (location.startsWith('/profile')) return 3;
    return 0; // /home
  }

  void _onItemTapped(int index, BuildContext context, UserRole role) {
    if (role == UserRole.manager) {
      switch (index) {
        case 0:
          context.go('/manager-dashboard');
          break;
        case 1:
          context.go('/manager-reservations');
          break;
        case 2:
          context.go('/manager-tables');
          break;
        case 3:
          context.go('/manager-scanner');
          break;
      }
      return;
    }

    if (role == UserRole.admin) {
      switch (index) {
        case 0:
          context.go('/admin-dashboard');
          break;
        case 1:
          context.go('/admin-users');
          break;
        case 2:
          context.go('/admin-restaurants');
          break;
        case 3:
          context.go('/profile');
          break;
      }
      return;
    }

    // Customer
    switch (index) {
      case 0:
        context.go('/home');
        break;
      case 1:
        context.go('/search');
        break;
      case 2:
        context.go('/bookings');
        break;
      case 3:
        context.go('/profile');
        break;
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authProvider);
    final role = authState.currentRole;
    final selectedIndex = _calculateSelectedIndex(context, role);

    List<BottomNavigationBarItem> items;
    if (role == UserRole.manager) {
      items = const [
        BottomNavigationBarItem(
          icon: Icon(Icons.dashboard_outlined),
          activeIcon: Icon(Icons.dashboard),
          label: 'Overview',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.calendar_month_outlined),
          activeIcon: Icon(Icons.calendar_month),
          label: 'Bookings',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.table_restaurant_outlined),
          activeIcon: Icon(Icons.table_restaurant),
          label: 'Tables',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.qr_code_scanner),
          activeIcon: Icon(Icons.qr_code_scanner_rounded),
          label: 'Scan QR',
        ),
      ];
    } else if (role == UserRole.admin) {
      items = const [
        BottomNavigationBarItem(
          icon: Icon(Icons.analytics_outlined),
          activeIcon: Icon(Icons.analytics),
          label: 'Analytics',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.people_outline),
          activeIcon: Icon(Icons.people),
          label: 'Users',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.store_mall_directory_outlined),
          activeIcon: Icon(Icons.store_mall_directory),
          label: 'Restaurants',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.person_outline),
          activeIcon: Icon(Icons.person),
          label: 'Profile',
        ),
      ];
    } else {
      items = const [
        BottomNavigationBarItem(
          icon: Icon(Icons.home_outlined),
          activeIcon: Icon(Icons.home),
          label: 'Home',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.search_rounded),
          activeIcon: Icon(Icons.search_rounded),
          label: 'Explore',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.bookmark_border_rounded),
          activeIcon: Icon(Icons.bookmark_rounded),
          label: 'Bookings',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.person_outline_rounded),
          activeIcon: Icon(Icons.person_rounded),
          label: 'Profile',
        ),
      ];
    }

    return Scaffold(
      backgroundColor: AppColors.backgroundWarm,
      body: child,
      bottomNavigationBar: Container(
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
        child: BottomNavigationBar(
          currentIndex: selectedIndex,
          onTap: (index) => _onItemTapped(index, context, role),
          backgroundColor: Colors.white,
          selectedItemColor: AppColors.primaryGreen,
          unselectedItemColor: AppColors.textSecondary,
          selectedLabelStyle: GoogleFonts.poppins(
            fontSize: 12,
            fontWeight: FontWeight.w600,
          ),
          unselectedLabelStyle: GoogleFonts.poppins(
            fontSize: 12,
            fontWeight: FontWeight.w400,
          ),
          elevation: 0,
          type: BottomNavigationBarType.fixed,
          items: items,
        ),
      ),
    );
  }
}
