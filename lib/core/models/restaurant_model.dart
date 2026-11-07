enum BangladeshDivision {
  dhaka('Dhaka'),
  chittagong('Chittagong'),
  sylhet('Sylhet'),
  rajshahi('Rajshahi'),
  rangpur('Rangpur'),
  khulna('Khulna'),
  barishal('Barishal'),
  mymensingh('Mymensingh');

  final String label;
  const BangladeshDivision(this.label);

  static BangladeshDivision fromString(String? div) {
    if (div == null) return BangladeshDivision.dhaka;
    for (final d in BangladeshDivision.values) {
      if (d.name.toLowerCase() == div.toLowerCase() ||
          d.label.toLowerCase() == div.toLowerCase()) {
        return d;
      }
    }
    return BangladeshDivision.dhaka;
  }
}

enum PriceCategory {
  budget('৳', 'Budget Friendly'),
  moderate('৳৳', 'Moderate'),
  premium('৳৳৳', 'Fine Dining'),
  luxury('৳৳৳৳', 'Luxury');

  final String symbol;
  final String label;
  const PriceCategory(this.symbol, this.label);

  static PriceCategory fromString(String? val) {
    switch (val?.toLowerCase()) {
      case 'budget':
        return PriceCategory.budget;
      case 'premium':
        return PriceCategory.premium;
      case 'luxury':
        return PriceCategory.luxury;
      default:
        return PriceCategory.moderate;
    }
  }
}

class RestaurantModel {
  final String id;
  final String name;
  final String description;
  final BangladeshDivision division;
  final String city;
  final String address;
  final double latitude;
  final double longitude;
  final String phone;
  final String email;
  final List<String> photos;
  final String coverPhoto;
  final List<String> cuisineTypes;
  final PriceCategory priceCategory;
  final double rating;
  final int reviewCount;
  final String openingHours;
  final List<String> facilities;
  final bool isFeatured;
  final bool isOpenNow;
  final int availableTablesCount;

  const RestaurantModel({
    required this.id,
    required this.name,
    required this.description,
    required this.division,
    required this.city,
    required this.address,
    required this.latitude,
    required this.longitude,
    required this.phone,
    required this.email,
    required this.photos,
    required this.coverPhoto,
    required this.cuisineTypes,
    required this.priceCategory,
    required this.rating,
    required this.reviewCount,
    required this.openingHours,
    required this.facilities,
    this.isFeatured = false,
    this.isOpenNow = true,
    this.availableTablesCount = 4,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'division': division.name,
      'city': city,
      'address': address,
      'latitude': latitude,
      'longitude': longitude,
      'phone': phone,
      'email': email,
      'photos': photos,
      'coverPhoto': coverPhoto,
      'cuisineTypes': cuisineTypes,
      'priceCategory': priceCategory.name,
      'rating': rating,
      'reviewCount': reviewCount,
      'openingHours': openingHours,
      'facilities': facilities,
      'isFeatured': isFeatured,
      'isOpenNow': isOpenNow,
      'availableTablesCount': availableTablesCount,
    };
  }

  factory RestaurantModel.fromJson(Map<String, dynamic> json) {
    return RestaurantModel(
      id: json['id'] ?? json['_id'] ?? '',
      name: json['name'] ?? '',
      description: json['description'] ?? '',
      division: BangladeshDivision.fromString(json['division']),
      city: json['city'] ?? 'Dhaka',
      address: json['address'] ?? '',
      latitude: (json['latitude'] as num?)?.toDouble() ?? 23.8103,
      longitude: (json['longitude'] as num?)?.toDouble() ?? 90.4125,
      phone: json['phone'] ?? '',
      email: json['email'] ?? '',
      photos: List<String>.from(json['photos'] ?? []),
      coverPhoto: json['coverPhoto'] ?? '',
      cuisineTypes: List<String>.from(json['cuisineTypes'] ?? ['Continental']),
      priceCategory: PriceCategory.fromString(json['priceCategory']),
      rating: (json['rating'] as num?)?.toDouble() ?? 4.5,
      reviewCount: json['reviewCount'] ?? 0,
      openingHours: json['openingHours'] ?? '11:00 AM - 11:00 PM',
      facilities: List<String>.from(json['facilities'] ?? []),
      isFeatured: json['isFeatured'] ?? false,
      isOpenNow: json['isOpenNow'] ?? true,
      availableTablesCount: json['availableTablesCount'] ?? 0,
    );
  }
}

