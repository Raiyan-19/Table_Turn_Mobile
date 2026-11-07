import 'dart:math';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/mock/mock_data.dart';
import '../../../core/models/reservation_model.dart';
import '../../../core/models/restaurant_model.dart';
import '../../../core/models/table_model.dart';

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
        );

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

  ReservationModel createReservation() {
    final randomNum = 1000 + Random().nextInt(9000);
    final bookingRef = 'TT-2026-$randomNum';
    final id = 'res_$bookingRef';

    final restaurant = state.draft.restaurant ?? MockData.restaurants.first;
    final table = state.draft.selectedTable ?? MockData.tables.first;

    final newReservation = ReservationModel(
      id: id,
      bookingRef: bookingRef,
      userId: 'user_01',
      userName: 'Sultan Md. Raiyan',
      userPhone: '+8801571284636',
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
      qrCodeData: '$bookingRef:${restaurant.id}:${table.id}:user_01',
      createdAt: DateTime.now(),
    );

    state = state.copyWith(
      reservations: [newReservation, ...state.reservations],
      lastCreatedBookingId: id,
    );

    return newReservation;
  }

  void cancelReservation(String reservationId) {
    final updated = state.reservations.map((r) {
      if (r.id == reservationId) {
        return r.copyWith(status: ReservationStatus.cancelled);
      }
      return r;
    }).toList();

    state = state.copyWith(reservations: updated);
  }

  void updateStatus(String reservationId, ReservationStatus newStatus) {
    final updated = state.reservations.map((r) {
      if (r.id == reservationId) {
        return r.copyWith(status: newStatus);
      }
      return r;
    }).toList();

    state = state.copyWith(reservations: updated);
  }

  ReservationModel? verifyQrCode(String qrData) {
    try {
      final ref = qrData.split(':').first;
      return state.reservations.firstWhere((r) => r.bookingRef == ref);
    } catch (_) {
      return null;
    }
  }
}

final reservationProvider =
    StateNotifierProvider<ReservationNotifier, ReservationState>((ref) {
  return ReservationNotifier();
});
