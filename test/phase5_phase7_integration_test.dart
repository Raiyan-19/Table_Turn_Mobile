import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:table_turn/core/mock/mock_data.dart';
import 'package:table_turn/core/models/reservation_model.dart';
import 'package:table_turn/core/models/restaurant_model.dart';
import 'package:table_turn/core/models/table_model.dart';
import 'package:table_turn/features/home/providers/restaurant_provider.dart';
import 'package:table_turn/features/profile/providers/notification_provider.dart';
import 'package:table_turn/features/reservation/providers/reservation_provider.dart';
import 'package:table_turn/features/restaurant/providers/restaurant_content_provider.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Phase 5-7 Full Integration Test Suite', () {
    test('RestaurantNotifier loads restaurants, filters by division, and toggles favorites', () async {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final notifier = container.read(restaurantProvider.notifier);
      final initial = container.read(restaurantProvider);

      expect(initial.allRestaurants.isNotEmpty, true);

      // Filter by division
      notifier.setDivision(BangladeshDivision.dhaka);
      expect(
        container.read(restaurantProvider).filteredRestaurants.every((r) => r.division == BangladeshDivision.dhaka),
        true,
      );

      // Clear filter
      notifier.resetFilters();
      expect(container.read(restaurantProvider).selectedDivision, null);

      // Toggle favorite
      final testRestId = initial.allRestaurants.first.id;
      final wasFav = container.read(restaurantProvider).favoriteIds.contains(testRestId);
      await notifier.toggleFavorite(testRestId);
      expect(container.read(restaurantProvider).favoriteIds.contains(testRestId), !wasFav);
    });

    test('ReservationNotifier creates online booking, prevents double booking, and updates status', () async {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final notifier = container.read(reservationProvider.notifier);
      final rest = MockData.restaurants.first;
      final table = MockData.tables.first;
      final customer = MockData.defaultCustomer;

      notifier.startDraft(rest);
      notifier.setSelectedTable(table);
      notifier.setTimeSlot('08:00 PM');
      notifier.setPartySize(2);

      // 1. Create booking
      final booking = await notifier.bookReservationOnline(user: customer);
      expect(booking.bookingRef.startsWith('TT-2026-'), true);
      expect(booking.tableId, table.id);
      expect(booking.status, ReservationStatus.confirmed);

      // 2. Atomic double booking prevention for same table and slot
      expect(
        () => notifier.bookReservationOnline(user: customer),
        throwsA(isA<StateError>()),
      );

      // 3. Status updates (Host check-in)
      notifier.updateStatus(booking.id, ReservationStatus.checkedIn);
      final updated = container.read(reservationProvider).reservations.firstWhere((r) => r.id == booking.id);
      expect(updated.status, ReservationStatus.checkedIn);

      // 4. Cancellation
      notifier.cancelReservation(booking.id);
      final cancelled = container.read(reservationProvider).reservations.firstWhere((r) => r.id == booking.id);
      expect(cancelled.status, ReservationStatus.cancelled);
    });

    test('QR Code verification enforces tenant isolation', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final notifier = container.read(reservationProvider.notifier);
      final res = container.read(reservationProvider).reservations.first;

      // Scanning with matching restaurant ID succeeds
      final validScan = notifier.verifyQrCode(res.qrCodeData, managerRestaurantId: res.restaurantId);
      expect(validScan, isNotNull);
      expect(validScan!.id, res.id);

      // Scanning with another restaurant ID fails (tenant isolation)
      final crossScan = notifier.verifyQrCode(res.qrCodeData, managerRestaurantId: 'other_forbidden_restaurant');
      expect(crossScan, isNull);
    });

    test('NotificationNotifier tracks unread alerts and marks them read', () async {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final notifier = container.read(notificationProvider.notifier);
      final state = container.read(notificationProvider);

      expect(state.notifications.isNotEmpty, true);
      expect(state.unreadCount > 0, true);

      await notifier.markAllAsRead();
      final afterMarkAll = container.read(notificationProvider);
      expect(afterMarkAll.unreadCount, 0);
    });

    test('RestaurantTablesNotifier loads tables and toggles status', () async {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final restId = MockData.restaurants.first.id;
      final notifier = container.read(restaurantTablesProvider(restId).notifier);
      final tables = container.read(restaurantTablesProvider(restId));

      expect(tables.isNotEmpty, true);
      final firstTable = tables.first;

      await notifier.toggleTableStatus(firstTable.id, TableStatus.occupied);
      final updatedTables = container.read(restaurantTablesProvider(restId));
      expect(updatedTables.firstWhere((t) => t.id == firstTable.id).status, TableStatus.occupied);
    });
  });
}
