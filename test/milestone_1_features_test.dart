import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:table_turn/core/mock/mock_data.dart';
import 'package:table_turn/core/models/reservation_model.dart';
import 'package:table_turn/core/models/restaurant_model.dart';
import 'package:table_turn/core/models/user_model.dart';
import 'package:table_turn/features/admin/presentation/admin_dashboard_screen.dart';
import 'package:table_turn/features/home/presentation/home_screen.dart';
import 'package:table_turn/features/home/providers/restaurant_provider.dart';
import 'package:table_turn/features/manager/presentation/qr_scanner_screen.dart';
import 'package:table_turn/features/reservation/presentation/make_reservation_screen.dart';
import 'package:table_turn/features/reservation/providers/reservation_provider.dart';
import 'package:table_turn/features/search/presentation/search_screen.dart';

void main() {
  group('Milestone 1 — Domain Models Tests', () {
    test('BangladeshDivision enum has all 8 administrative divisions', () {
      expect(BangladeshDivision.values.length, 8);
      expect(BangladeshDivision.dhaka.label, 'Dhaka');
      expect(BangladeshDivision.chittagong.label, 'Chittagong');
      expect(BangladeshDivision.sylhet.label, 'Sylhet');
      expect(BangladeshDivision.rajshahi.label, 'Rajshahi');
      expect(BangladeshDivision.rangpur.label, 'Rangpur');
      expect(BangladeshDivision.khulna.label, 'Khulna');
      expect(BangladeshDivision.barishal.label, 'Barishal');
      expect(BangladeshDivision.mymensingh.label, 'Mymensingh');
    });

    test('UserRole enum parses correctly', () {
      expect(UserRole.fromString('customer'), UserRole.customer);
      expect(UserRole.fromString('manager'), UserRole.manager);
      expect(UserRole.fromString('admin'), UserRole.admin);
      expect(UserRole.fromString(null), UserRole.customer);
    });

    test('ReservationModel generates valid QR data and calculates upcoming state', () {
      final res = ReservationModel(
        id: 'res_test_1',
        bookingRef: 'TT-2026-9999',
        userId: 'u1',
        userName: 'Raiyan',
        userPhone: '+8801571284636',
        restaurantId: 'rest_01',
        restaurantName: 'The Forest Lounge',
        restaurantAddress: 'Gulshan-2, Dhaka',
        restaurantCoverPhoto: '',
        tableId: 't1',
        tableNumber: 'Table 01',
        tableSection: 'Window View',
        reservationDate: DateTime.now().add(const Duration(days: 1)),
        timeSlot: '07:30 PM',
        guestCount: 2,
        status: ReservationStatus.confirmed,
        qrCodeData: 'TT-2026-9999:rest_01:t1:u1',
        createdAt: DateTime.now(),
      );

      expect(res.isUpcoming, true);
      expect(res.isCancellable, true);
      expect(res.qrCodeData.contains('TT-2026-9999'), true);
    });
  });

  group('Milestone 1 — Provider State Tests', () {
    test('RestaurantNotifier filters by Bangladesh Division and search query', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final notifier = container.read(restaurantProvider.notifier);

      // Initially all restaurants
      expect(container.read(restaurantProvider).filteredRestaurants.length, 9);

      // Filter by Chittagong
      notifier.setDivision(BangladeshDivision.chittagong);
      var chittagongList = container.read(restaurantProvider).filteredRestaurants;
      expect(chittagongList.length, 1);
      expect(chittagongList.first.name, 'Mezban Bari');

      // Clear division filter
      notifier.setDivision(BangladeshDivision.chittagong); // toggles off
      expect(container.read(restaurantProvider).filteredRestaurants.length, 9);

      // Search query
      notifier.setSearchQuery('Steak');
      expect(container.read(restaurantProvider).filteredRestaurants.length, 1);
      expect(container.read(restaurantProvider).filteredRestaurants.first.name, 'The Forest Lounge');
    });

    test('ReservationNotifier manages draft, creates reservation, and updates host status', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final notifier = container.read(reservationProvider.notifier);
      final initialCount = container.read(reservationProvider).reservations.length;

      // Start draft
      final restaurant = MockData.restaurants.first;
      notifier.startDraft(restaurant);
      notifier.setTimeSlot('08:00 PM');
      notifier.setPartySize(4);
      notifier.setSpecialRequests('Window seat please');

      // Create reservation
      final newBooking = notifier.createReservation();
      expect(newBooking.timeSlot, '08:00 PM');
      expect(newBooking.guestCount, 4);
      expect(newBooking.status, ReservationStatus.confirmed);
      expect(container.read(reservationProvider).reservations.length, initialCount + 1);

      // Host updates status: confirmed -> checkedIn -> seated
      notifier.updateStatus(newBooking.id, ReservationStatus.checkedIn);
      var updated = container.read(reservationProvider).reservations.firstWhere((r) => r.id == newBooking.id);
      expect(updated.status, ReservationStatus.checkedIn);

      notifier.updateStatus(newBooking.id, ReservationStatus.seated);
      updated = container.read(reservationProvider).reservations.firstWhere((r) => r.id == newBooking.id);
      expect(updated.status, ReservationStatus.seated);
    });
  });

  group('Milestone 1 — Screen Widget Rendering Tests', () {
    testWidgets('Renders HomeScreen with greeting and division pills', (WidgetTester tester) async {
      tester.view.physicalSize = const Size(402 * 3, 874 * 3);
      tester.view.devicePixelRatio = 3.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: HomeScreen(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.textContaining('Hi,'), findsOneWidget);
      expect(find.text('Explore by Division'), findsOneWidget);
      expect(find.text('Dhaka'), findsWidgets);
      expect(find.text('Chittagong'), findsWidgets);
      expect(find.text('The Forest Lounge'), findsOneWidget);
    });

    testWidgets('Renders SearchScreen with search bar and filter button', (WidgetTester tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: SearchScreen(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Explore & Search'), findsOneWidget);
      expect(find.byType(TextField), findsOneWidget);
      expect(find.textContaining('Restaurants Found'), findsOneWidget);
    });

    testWidgets('Renders MakeReservationScreen with step-by-step selectors', (WidgetTester tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: MakeReservationScreen(restaurantId: 'rest_01'),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('1. Select Date'), findsOneWidget);
      expect(find.text('2. Party Size (Guests)'), findsOneWidget);
      expect(find.text('3. Preferred Dining Time'), findsOneWidget);
      expect(find.text('4. Select Table & Seating Area'), findsOneWidget);
      expect(find.text('Review & Confirm Reservation'), findsOneWidget);
    });

    testWidgets('Renders QrScannerScreen for Host Check-in', (WidgetTester tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: QrScannerScreen(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('QR Pass Verification'), findsOneWidget);
      expect(find.text('Manual Verification by Reference'), findsOneWidget);
      expect(find.text('Lookup'), findsOneWidget);
    });

    testWidgets('Renders AdminDashboardScreen with nationwide statistics', (WidgetTester tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: AdminDashboardScreen(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Platform Administration'), findsOneWidget);
      expect(find.text('Partner Venues'), findsOneWidget);
      expect(find.text('Active Customers'), findsOneWidget);
      expect(find.text('Reservations by Administrative Division'), findsOneWidget);
    });
  });
}
