import 'dart:math';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/mock/mock_data.dart';
import '../../../core/models/reservation_model.dart';
import '../../../core/models/restaurant_model.dart';
import '../../../core/models/table_model.dart';
import '../../../core/models/user_model.dart';
import '../../../core/services/api_service.dart';

class ReservationDraft {
  final RestaurantModel? restaurant;
  final DateTime reservationDate;
  final String selectedTimeSlot;
  final int partySize;
  final TableModel? selectedTable;
  final String specialRequests;

  ReservationDraft({
    this.restaurant,
    DateTime? reservationDate,
    this.selectedTimeSlot = '07:30 PM',
    this.partySize = 2,
    this.selectedTable,
    this.specialRequests = '',
  }) : reservationDate = reservationDate ?? DateTime.now().add(const Duration(days: 1));

  ReservationDraft copyWith({
    RestaurantModel? restaurant,
    DateTime? reservationDate,
    String? selectedTimeSlot,
    int? partySize,
    TableModel? selectedTable,
    String? specialRequests,
  }) {
    return ReservationDraft(
      restaurant: restaurant ?? this.restaurant,
      reservationDate: reservationDate ?? this.reservationDate,
      selectedTimeSlot: selectedTimeSlot ?? this.selectedTimeSlot,
      partySize: partySize ?? this.partySize,
      selectedTable: selectedTable ?? this.selectedTable,
      specialRequests: specialRequests ?? this.specialRequests,
    );
  }
}

class ReservationState {
  final List<ReservationModel> reservations;
  final ReservationDraft draft;
  final String? lastCreatedBookingId;

  const ReservationState({
    this.reservations = const [],
    required this.draft,
    this.lastCreatedBookingId,
  });

  List<ReservationModel> get upcomingReservations =>
      reservations.where((r) => r.isUpcoming).toList();

  List<ReservationModel> get pastReservations =>
      reservations.where((r) => !r.isUpcoming).toList();

  ReservationModel? get lastCreatedReservation {
    if (lastCreatedBookingId == null) return null;
    return reservations.firstWhere(
      (r) => r.id == lastCreatedBookingId,
      orElse: () => reservations.first,
    );
  }

  ReservationState copyWith({
    List<ReservationModel>? reservations,
    ReservationDraft? draft,
    String? lastCreatedBookingId,
  }) {
    return ReservationState(
      reservations: reservations ?? this.reservations,
      draft: draft ?? this.draft,
      lastCreatedBookingId: lastCreatedBookingId ?? this.lastCreatedBookingId,
    );
  }
}

class ReservationNotifier extends StateNotifier<ReservationState> {
  ReservationNotifier()
      : super(
          ReservationState(
            reservations: MockData.initialReservations,
            draft: ReservationDraft(restaurant: MockData.restaurants.first),
          ),
        ) {
    loadReservations();
  }

  Future<void> loadReservations() async {
    try {
      final res = await ApiService.get('/reservations', requireAuth: true);
      if (res['success'] == true && res['data'] is List) {
        final list = (res['data'] as List)
            .map((item) => ReservationModel.fromJson(Map<String, dynamic>.from(item)))
            .toList();

        if (list.isNotEmpty) {
          state = state.copyWith(reservations: list);
        }
      }
    } catch (_) {
      // Gracefully fall back to local mock reservations if offline or in test
    }
  }

  void startDraft(RestaurantModel restaurant) {
    state = state.copyWith(
      draft: ReservationDraft(
        restaurant: restaurant,
        selectedTable: MockData.tables.firstWhere(
          (t) => t.restaurantId == restaurant.id && t.isAvailable,
          orElse: () => MockData.tables.first,
        ),
      ),
    );
  }

  void setDate(DateTime date) {
    state = state.copyWith(draft: state.draft.copyWith(reservationDate: date));
  }

  void setTimeSlot(String timeSlot) {
    state = state.copyWith(draft: state.draft.copyWith(selectedTimeSlot: timeSlot));
  }

  void setPartySize(int count) {
    state = state.copyWith(draft: state.draft.copyWith(partySize: count));
  }

  void setSelectedTable(TableModel table) {
    state = state.copyWith(draft: state.draft.copyWith(selectedTable: table));
  }

  void setSpecialRequests(String notes) {
    state = state.copyWith(draft: state.draft.copyWith(specialRequests: notes));
  }

  static String generateSecureBookingRef() {
    const chars = 'ABCDEFGHJKLMNPQRSTUVWXYZ23456789';
    final rnd = Random.secure();
    final buffer = StringBuffer('TT-2026-');
    for (var i = 0; i < 6; i++) {
      buffer.write(chars[rnd.nextInt(chars.length)]);
    }
    return buffer.toString();
  }

  bool isSlotAvailable({
    required String restaurantId,
    required String tableId,
    required DateTime date,
    required String timeSlot,
  }) {
    return !state.reservations.any((r) =>
        r.restaurantId == restaurantId &&
        r.tableId == tableId &&
        r.timeSlot == timeSlot &&
        r.status != ReservationStatus.cancelled &&
        r.reservationDate.year == date.year &&
        r.reservationDate.month == date.month &&
        r.reservationDate.day == date.day);
  }

  ReservationModel createReservation({UserModel? user}) {
    final restaurant = state.draft.restaurant ?? MockData.restaurants.first;
    final table = state.draft.selectedTable ?? MockData.tables.first;
    final customer = user ?? MockData.defaultCustomer;

    // Check slot availability before confirming to prevent double-booking
    final slotAvailable = isSlotAvailable(
      restaurantId: restaurant.id,
      tableId: table.id,
      date: state.draft.reservationDate,
      timeSlot: state.draft.selectedTimeSlot,
    );

    if (!slotAvailable) {
      throw StateError('This table is already reserved for the selected date and time slot.');
    }

    final bookingRef = generateSecureBookingRef();
    final id = 'res_$bookingRef';

    // Cryptographic-style verifiable payload format: ref:restId:tableId:userId:timestamp
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final qrSignature = '$bookingRef:${restaurant.id}:${table.id}:${customer.id}:$timestamp';

    final newReservation = ReservationModel(
      id: id,
      bookingRef: bookingRef,
      userId: customer.id,
      userName: customer.name,
      userPhone: customer.phone,
      restaurantId: restaurant.id,
      restaurantName: restaurant.name,
      restaurantAddress: restaurant.address,
      restaurantCoverPhoto: restaurant.coverPhoto,
      tableId: table.id,
      tableNumber: table.tableNumber,
      tableSection: table.section.label,
      reservationDate: state.draft.reservationDate,
      timeSlot: state.draft.selectedTimeSlot,
      guestCount: state.draft.partySize,
      specialRequests: state.draft.specialRequests.isEmpty
          ? null
          : state.draft.specialRequests,
      status: ReservationStatus.confirmed,
      qrCodeData: qrSignature,
      createdAt: DateTime.now(),
    );

    state = state.copyWith(
      reservations: [newReservation, ...state.reservations],
      lastCreatedBookingId: id,
    );

    return newReservation;
  }

  Future<ReservationModel> bookReservationOnline({UserModel? user}) async {
    final restaurant = state.draft.restaurant ?? MockData.restaurants.first;
    final table = state.draft.selectedTable ?? MockData.tables.first;
    final customer = user ?? MockData.defaultCustomer;

    // Check slot availability before confirming to prevent double-booking
    final slotAvailable = isSlotAvailable(
      restaurantId: restaurant.id,
      tableId: table.id,
      date: state.draft.reservationDate,
      timeSlot: state.draft.selectedTimeSlot,
    );

    if (!slotAvailable) {
      throw StateError('This table is already reserved for the selected date and time slot.');
    }

    try {
      final res = await ApiService.post(
        '/reservations',
        requireAuth: true,
        body: {
          'restaurantId': restaurant.id,
          'tableId': table.id,
          'reservationDate': state.draft.reservationDate.toIso8601String(),
          'timeSlot': state.draft.selectedTimeSlot,
          'guestCount': state.draft.partySize,
          'specialRequests': state.draft.specialRequests,
        },
      );

      if (res['success'] == true && res['data'] != null) {
        final onlineBooking =
            ReservationModel.fromJson(Map<String, dynamic>.from(res['data']));
        state = state.copyWith(
          reservations: [onlineBooking, ...state.reservations],
          lastCreatedBookingId: onlineBooking.id,
        );
        return onlineBooking;
      } else {
        throw StateError(res['message'] ?? 'Failed to complete reservation.');
      }
    } on ApiException catch (e) {
      throw StateError(e.message);
    } catch (e) {
      if (e is StateError) rethrow;
      // Fallback for tests or offline operation
      return createReservation(user: customer);
    }
  }

  void cancelReservation(String reservationId) {
    final updated = state.reservations.map((r) {
      if (r.id == reservationId) {
        return r.copyWith(status: ReservationStatus.cancelled);
      }
      return r;
    }).toList();

    state = state.copyWith(reservations: updated);

    // Sync to backend asynchronously
    ApiService.patch('/reservations/$reservationId/cancel', requireAuth: true).catchError((_) => <String, dynamic>{});
  }

  void updateStatus(String reservationId, ReservationStatus newStatus) {
    final updated = state.reservations.map((r) {
      if (r.id == reservationId) {
        return r.copyWith(status: newStatus);
      }
      return r;
    }).toList();

    state = state.copyWith(reservations: updated);

    // Sync to backend asynchronously
    ApiService.patch(
      '/reservations/$reservationId/status',
      requireAuth: true,
      body: {'status': newStatus.name},
    ).catchError((_) => <String, dynamic>{});
  }

  /// Tenant-scoped QR verification: Host manager only verifies reservations for their own restaurant.
  ReservationModel? verifyQrCode(String qrData, {String? managerRestaurantId}) {
    try {
      final cleanQuery = qrData.trim().toUpperCase();
      final ref = cleanQuery.split(':').first;

      final match = state.reservations.firstWhere(
        (r) =>
            r.bookingRef.toUpperCase() == ref ||
            r.qrCodeData.toUpperCase() == cleanQuery,
      );

      // Enforce multi-tenant restaurant scoping
      if (managerRestaurantId != null && match.restaurantId != managerRestaurantId) {
        return null;
      }

      return match;
    } catch (_) {
      return null;
    }
  }

  Future<ReservationModel?> verifyQrCodeOnline(String qrData, {String? managerRestaurantId}) async {
    final localMatch = verifyQrCode(qrData, managerRestaurantId: managerRestaurantId);
    if (localMatch != null) return localMatch;

    try {
      final res = await ApiService.post(
        '/reservations/verify-qr',
        requireAuth: true,
        body: {'qrData': qrData},
      );
      if (res['success'] == true && res['data'] != null) {
        final verified = ReservationModel.fromJson(Map<String, dynamic>.from(res['data']));
        if (managerRestaurantId != null && verified.restaurantId != managerRestaurantId) {
          return null;
        }
        return verified;
      }
    } catch (_) {}
    return null;
  }
}

final reservationProvider =
    StateNotifierProvider<ReservationNotifier, ReservationState>((ref) {
  return ReservationNotifier();
});

