enum ReservationStatus {
  pending('Pending'),
  confirmed('Confirmed'),
  checkedIn('Checked In'),
  seated('Seated'),
  completed('Completed'),
  cancelled('Cancelled');

  final String label;
  const ReservationStatus(this.label);

  static ReservationStatus fromString(String? val) {
    switch (val?.toLowerCase()) {
      case 'confirmed':
        return ReservationStatus.confirmed;
      case 'checkedin':
      case 'checked-in':
      case 'checked_in':
        return ReservationStatus.checkedIn;
      case 'seated':
        return ReservationStatus.seated;
      case 'completed':
        return ReservationStatus.completed;
      case 'cancelled':
        return ReservationStatus.cancelled;
      default:
        return ReservationStatus.pending;
    }
  }
}

class ReservationModel {
  final String id;
  final String bookingRef;
  final String userId;
  final String userName;
  final String userPhone;
  final String restaurantId;
  final String restaurantName;
  final String restaurantAddress;
  final String restaurantCoverPhoto;
  final String tableId;
  final String tableNumber;
  final String tableSection;
  final DateTime reservationDate;
  final String timeSlot;
  final int guestCount;
  final String? specialRequests;
  final ReservationStatus status;
  final String qrCodeData;
  final DateTime createdAt;

  const ReservationModel({
    required this.id,
    required this.bookingRef,
    required this.userId,
    required this.userName,
    required this.userPhone,
    required this.restaurantId,
    required this.restaurantName,
    required this.restaurantAddress,
    required this.restaurantCoverPhoto,
    required this.tableId,
    required this.tableNumber,
    required this.tableSection,
    required this.reservationDate,
    required this.timeSlot,
    required this.guestCount,
    this.specialRequests,
    this.status = ReservationStatus.confirmed,
    required this.qrCodeData,
    required this.createdAt,
  });

  bool get isUpcoming =>
      status == ReservationStatus.confirmed ||
      status == ReservationStatus.pending ||
      status == ReservationStatus.checkedIn ||
      status == ReservationStatus.seated;

  bool get isCancellable =>
      status == ReservationStatus.confirmed || status == ReservationStatus.pending;

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'bookingRef': bookingRef,
      'userId': userId,
      'userName': userName,
      'userPhone': userPhone,
      'restaurantId': restaurantId,
      'restaurantName': restaurantName,
      'restaurantAddress': restaurantAddress,
      'restaurantCoverPhoto': restaurantCoverPhoto,
      'tableId': tableId,
      'tableNumber': tableNumber,
      'tableSection': tableSection,
      'reservationDate': reservationDate.toIso8601String(),
      'timeSlot': timeSlot,
      'guestCount': guestCount,
      'specialRequests': specialRequests,
      'status': status.name,
      'qrCodeData': qrCodeData,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory ReservationModel.fromJson(Map<String, dynamic> json) {
    return ReservationModel(
      id: json['id'] ?? json['_id'] ?? '',
      bookingRef: json['bookingRef'] ?? 'TT-000000',
      userId: json['userId'] ?? '',
      userName: json['userName'] ?? 'Diner',
      userPhone: json['userPhone'] ?? '',
      restaurantId: json['restaurantId'] ?? '',
      restaurantName: json['restaurantName'] ?? '',
      restaurantAddress: json['restaurantAddress'] ?? '',
      restaurantCoverPhoto: json['restaurantCoverPhoto'] ?? '',
      tableId: json['tableId'] ?? '',
      tableNumber: json['tableNumber'] ?? 'T-01',
      tableSection: json['tableSection'] ?? 'Indoor Dining',
      reservationDate: json['reservationDate'] != null
          ? DateTime.parse(json['reservationDate'])
          : DateTime.now(),
      timeSlot: json['timeSlot'] ?? '7:00 PM',
      guestCount: json['guestCount'] ?? 2,
      specialRequests: json['specialRequests'],
      status: ReservationStatus.fromString(json['status']),
      qrCodeData: json['qrCodeData'] ?? '',
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'])
          : DateTime.now(),
    );
  }

  ReservationModel copyWith({
    String? id,
    String? bookingRef,
    String? userId,
    String? userName,
    String? userPhone,
    String? restaurantId,
    String? restaurantName,
    String? restaurantAddress,
    String? restaurantCoverPhoto,
    String? tableId,
    String? tableNumber,
    String? tableSection,
    DateTime? reservationDate,
    String? timeSlot,
    int? guestCount,
    String? specialRequests,
    ReservationStatus? status,
    String? qrCodeData,
    DateTime? createdAt,
  }) {
    return ReservationModel(
      id: id ?? this.id,
      bookingRef: bookingRef ?? this.bookingRef,
      userId: userId ?? this.userId,
      userName: userName ?? this.userName,
      userPhone: userPhone ?? this.userPhone,
      restaurantId: restaurantId ?? this.restaurantId,
      restaurantName: restaurantName ?? this.restaurantName,
      restaurantAddress: restaurantAddress ?? this.restaurantAddress,
      restaurantCoverPhoto: restaurantCoverPhoto ?? this.restaurantCoverPhoto,
      tableId: tableId ?? this.tableId,
      tableNumber: tableNumber ?? this.tableNumber,
      tableSection: tableSection ?? this.tableSection,
      reservationDate: reservationDate ?? this.reservationDate,
      timeSlot: timeSlot ?? this.timeSlot,
      guestCount: guestCount ?? this.guestCount,
      specialRequests: specialRequests ?? this.specialRequests,
      status: status ?? this.status,
      qrCodeData: qrCodeData ?? this.qrCodeData,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}

