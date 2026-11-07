import 'package:flutter_test/flutter_test.dart';
import 'package:table_turn/core/mock/mock_data.dart';
import 'package:table_turn/core/models/user_model.dart';
import 'package:table_turn/features/reservation/providers/reservation_provider.dart';

void main() {
  group('Phase 1 Security & Business Logic Verification', () {
    test('SEC-09: Generates cryptographically secure booking reference', () {
      final ref1 = ReservationNotifier.generateSecureBookingRef();
      final ref2 = ReservationNotifier.generateSecureBookingRef();

      expect(ref1.startsWith('TT-2026-'), isTrue);
      expect(ref2.startsWith('TT-2026-'), isTrue);
      expect(ref1.length, 14); // 'TT-2026-' (8 chars) + 6 chars
      expect(ref1, isNot(equals(ref2)));
    });

    test('SEC-03 & FUNC-02: createReservation uses dynamic user and blocks double-booking', () {
      final notifier = ReservationNotifier();
      final testCustomer = UserModel(
        id: 'user_custom_99',
        name: 'Fatima Rahman',
        email: 'fatima@tableturn.app',
        phone: '+8801811223344',
        role: UserRole.customer,
        createdAt: DateTime.now(),
      );

      final restaurant = MockData.restaurants.first;
      notifier.startDraft(restaurant);
      // Select an unbooked date in the future to avoid colliding with initial mock reservations
      final availableDate = DateTime.now().add(const Duration(days: 5));
      notifier.setDate(availableDate);
      notifier.setTimeSlot('08:30 PM');

      // First reservation should succeed with dynamic user data
      final booking1 = notifier.createReservation(user: testCustomer);
      expect(booking1.userId, testCustomer.id);
      expect(booking1.userName, testCustomer.name);
      expect(booking1.userPhone, testCustomer.phone);
      expect(booking1.qrCodeData, contains(testCustomer.id));

      // Attempting to reserve the exact same table on the exact same date & slot must fail
      expect(
        () => notifier.createReservation(user: testCustomer),
        throwsA(isA<StateError>()),
      );
    });

    test('SEC-04: Tenant isolation prevents cross-restaurant QR check-in', () {
      final notifier = ReservationNotifier();
      final reservations = notifier.state.reservations;

      // Find reservation from rest_01
      final bookingRest1 = reservations.firstWhere((r) => r.restaurantId == 'rest_01');

      // Manager for rest_01 verifies -> Success
      final matchValid = notifier.verifyQrCode(
        bookingRest1.bookingRef,
        managerRestaurantId: 'rest_01',
      );
      expect(matchValid, isNotNull);
      expect(matchValid!.id, bookingRest1.id);

      // Manager for rest_02 (different restaurant) verifies -> Denied (null)
      final matchDenied = notifier.verifyQrCode(
        bookingRest1.bookingRef,
        managerRestaurantId: 'rest_02',
      );
      expect(matchDenied, isNull);
    });
  });
}
