enum TableSection {
  indoor('Indoor Dining'),
  outdoor('Outdoor / Patio'),
  vip('VIP Booth'),
  rooftop('Rooftop Terrace'),
  window('Window View');

  final String label;
  const TableSection(this.label);

  static TableSection fromString(String? section) {
    switch (section?.toLowerCase()) {
      case 'outdoor':
      case 'patio':
        return TableSection.outdoor;
      case 'vip':
      case 'booth':
        return TableSection.vip;
      case 'rooftop':
        return TableSection.rooftop;
      case 'window':
        return TableSection.window;
      default:
        return TableSection.indoor;
    }
  }
}

enum TableStatus {
  available('Available'),
  reserved('Reserved'),
  occupied('Occupied');

  final String label;
  const TableStatus(this.label);
}

class TableModel {
  final String id;
  final String restaurantId;
  final String tableNumber;
  final TableSection section;
  final int capacity;
  final TableStatus status;
  final String? nextAvailableTime;
  final double minimumSpend;
  final List<String> features;

  const TableModel({
    required this.id,
    required this.restaurantId,
    required this.tableNumber,
    required this.section,
    required this.capacity,
    this.status = TableStatus.available,
    this.nextAvailableTime,
    this.minimumSpend = 0.0,
    this.features = const [],
  });

  bool get isAvailable => status == TableStatus.available;

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'restaurantId': restaurantId,
      'tableNumber': tableNumber,
      'section': section.name,
      'capacity': capacity,
      'status': status.name,
      'nextAvailableTime': nextAvailableTime,
      'minimumSpend': minimumSpend,
      'features': features,
    };
  }

  factory TableModel.fromJson(Map<String, dynamic> json) {
    return TableModel(
      id: json['id'] ?? json['_id'] ?? '',
      restaurantId: json['restaurantId'] ?? '',
      tableNumber: json['tableNumber'] ?? 'T-01',
      section: TableSection.fromString(json['section']),
      capacity: json['capacity'] ?? 4,
      status: TableStatus.values.firstWhere(
        (s) => s.name == json['status'],
        orElse: () => TableStatus.available,
      ),
      nextAvailableTime: json['nextAvailableTime'],
      minimumSpend: (json['minimumSpend'] as num?)?.toDouble() ?? 0.0,
      features: List<String>.from(json['features'] ?? []),
    );
  }
}
