import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../core/models/user_model.dart';
import '../features/admin/presentation/admin_dashboard_screen.dart';
import '../features/admin/presentation/restaurant_management_screen.dart';
import '../features/admin/presentation/user_management_screen.dart';
import '../features/auth/presentation/forgot_password_screen.dart';
import '../features/auth/presentation/otp_screen.dart';
import '../features/auth/presentation/sign_in_screen.dart';
import '../features/auth/presentation/sign_up_screen.dart';
import '../features/auth/providers/auth_provider.dart';
import '../features/home/presentation/home_screen.dart';
import '../features/manager/presentation/manager_dashboard_screen.dart';
import '../features/manager/presentation/manager_reservations_screen.dart';
import '../features/manager/presentation/qr_scanner_screen.dart';
import '../features/manager/presentation/table_management_screen.dart';
import '../features/navigation/main_scaffold.dart';
import '../features/onboarding/presentation/onboarding_screen.dart';
import '../features/profile/presentation/favorites_screen.dart';
import '../features/profile/presentation/notifications_screen.dart';
import '../features/profile/presentation/profile_screen.dart';
import '../features/reservation/presentation/booking_detail_screen.dart';
import '../features/reservation/presentation/booking_list_screen.dart';
import '../features/reservation/presentation/booking_success_screen.dart';
import '../features/reservation/presentation/make_reservation_screen.dart';
import '../features/reservation/presentation/reservation_confirmation_screen.dart';
import '../features/restaurant/presentation/menu_screen.dart';
import '../features/restaurant/presentation/restaurant_detail_screen.dart';
import '../features/search/presentation/search_screen.dart';
import '../features/splash/presentation/splash_screen.dart';
import '../features/success/presentation/success_screen.dart';

GoRouter createAppRouter([Ref? ref]) {
  return GoRouter(
    initialLocation: '/splash',
    redirect: (context, state) {
      if (ref == null) return null;
      final authState = ref.read(authProvider);
      final location = state.matchedLocation;
      final role = authState.currentRole;
      final isAuthenticated = authState.isAuthenticated;

      // Unauthenticated attempts to access protected manager or admin routes
      if (!isAuthenticated) {
        if (location.startsWith('/admin') || location.startsWith('/manager')) {
          return '/sign-in';
        }
      }

      // Route authorization guard: Protect admin endpoints
      if (location.startsWith('/admin') && role != UserRole.admin) {
        return isAuthenticated && role == UserRole.manager
            ? '/manager-dashboard'
            : '/home';
      }

      // Route authorization guard: Protect manager endpoints
      if (location.startsWith('/manager') && role != UserRole.manager) {
        return isAuthenticated && role == UserRole.admin
            ? '/admin-dashboard'
            : '/home';
      }
      return null;
    },
    routes: [
    // 1. Initial Authentication & Onboarding Routes
    GoRoute(
      path: '/splash',
      builder: (context, state) => const SplashScreen(),
    ),
    GoRoute(
      path: '/onboarding',
      builder: (context, state) => const OnboardingScreen(),
    ),
    GoRoute(
      path: '/sign-in',
      builder: (context, state) => const SignInScreen(),
    ),
    GoRoute(
      path: '/sign-up',
      builder: (context, state) => const SignUpScreen(),
    ),
    GoRoute(
      path: '/forgot-password',
      builder: (context, state) => const ForgotPasswordScreen(),
    ),
    GoRoute(
      path: '/otp',
      builder: (context, state) => const OtpScreen(),
    ),
    GoRoute(
      path: '/success',
      builder: (context, state) => const SuccessScreen(),
    ),

    // 2. Main Tab Navigation Shell
    ShellRoute(
      builder: (context, state, child) => MainScaffold(child: child),
      routes: [
        // Diner Shell Tabs
        GoRoute(
          path: '/home',
          pageBuilder: (context, state) => const NoTransitionPage(child: HomeScreen()),
        ),
        GoRoute(
          path: '/search',
          pageBuilder: (context, state) => const NoTransitionPage(child: SearchScreen()),
        ),
        GoRoute(
          path: '/bookings',
          pageBuilder: (context, state) => const NoTransitionPage(child: BookingListScreen()),
        ),
        GoRoute(
          path: '/profile',
          pageBuilder: (context, state) => const NoTransitionPage(child: ProfileScreen()),
        ),

        // Manager Shell Tabs
        GoRoute(
          path: '/manager-dashboard',
          pageBuilder: (context, state) => const NoTransitionPage(child: ManagerDashboardScreen()),
        ),
        GoRoute(
          path: '/manager-reservations',
          pageBuilder: (context, state) => const NoTransitionPage(child: ManagerReservationsScreen()),
        ),
        GoRoute(
          path: '/manager-tables',
          pageBuilder: (context, state) => const NoTransitionPage(child: TableManagementScreen()),
        ),
        GoRoute(
          path: '/manager-scanner',
          pageBuilder: (context, state) => const NoTransitionPage(child: QrScannerScreen()),
        ),

        // Admin Shell Tabs
        GoRoute(
          path: '/admin-dashboard',
          pageBuilder: (context, state) => const NoTransitionPage(child: AdminDashboardScreen()),
        ),
        GoRoute(
          path: '/admin-users',
          pageBuilder: (context, state) => const NoTransitionPage(child: UserManagementScreen()),
        ),
        GoRoute(
          path: '/admin-restaurants',
          pageBuilder: (context, state) => const NoTransitionPage(child: RestaurantManagementScreen()),
        ),
      ],
    ),

    // 3. Sub-pages & Reservation Flow
    GoRoute(
      path: '/restaurant/:id',
      builder: (context, state) => RestaurantDetailScreen(
        restaurantId: state.pathParameters['id'] ?? 'rest_01',
      ),
    ),
    GoRoute(
      path: '/restaurant/:id/menu',
      builder: (context, state) => MenuScreen(
        restaurantId: state.pathParameters['id'] ?? 'rest_01',
      ),
    ),
    GoRoute(
      path: '/make-reservation/:id',
      builder: (context, state) => MakeReservationScreen(
        restaurantId: state.pathParameters['id'] ?? 'rest_01',
      ),
    ),
    GoRoute(
      path: '/reservation-confirm',
      builder: (context, state) => const ReservationConfirmationScreen(),
    ),
    GoRoute(
      path: '/booking-success/:id',
      builder: (context, state) => BookingSuccessScreen(
        bookingId: state.pathParameters['id'] ?? '',
      ),
    ),
    GoRoute(
      path: '/booking-detail/:id',
      builder: (context, state) => BookingDetailScreen(
        bookingId: state.pathParameters['id'] ?? '',
      ),
    ),
    GoRoute(
      path: '/favorites',
      builder: (context, state) => const FavoritesScreen(),
    ),
    GoRoute(
      path: '/notifications',
      builder: (context, state) => const NotificationsScreen(),
    ),
  ],
);
}

final routerProvider = Provider<GoRouter>((ref) {
  return createAppRouter(ref);
});

final appRouter = createAppRouter();
