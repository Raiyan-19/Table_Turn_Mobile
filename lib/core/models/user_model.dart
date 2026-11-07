enum UserRole {
  customer,
  manager,
  admin;

  String get displayName {
    switch (this) {
      case UserRole.customer:
        return 'Customer';
      case UserRole.manager:
        return 'Restaurant Manager';
      case UserRole.admin:
        return 'Administrator';
    }
  }

  static UserRole fromString(String? role) {
    switch (role?.toLowerCase()) {
      case 'manager':
        return UserRole.manager;
      case 'admin':
        return UserRole.admin;
      default:
        return UserRole.customer;
    }
  }
}

class UserModel {
  final String id;
  final String name;
  final String email;
  final String phone;
  final String? avatarUrl;
  final UserRole role;
  final String? managedRestaurantId;
  final List<String> favoriteRestaurantIds;
  final bool isPhoneVerified;
  final bool isEmailVerified;
  final DateTime createdAt;

  const UserModel({
    required this.id,
    required this.name,
    required this.email,
    required this.phone,
    this.avatarUrl,
    this.role = UserRole.customer,
    this.managedRestaurantId,
    this.favoriteRestaurantIds = const [],
    this.isPhoneVerified = false,
    this.isEmailVerified = false,
    required this.createdAt,
  });

  UserModel copyWith({
    String? id,
    String? name,
    String? email,
    String? phone,
    String? avatarUrl,
    UserRole? role,
    String? managedRestaurantId,
    List<String>? favoriteRestaurantIds,
    bool? isPhoneVerified,
    bool? isEmailVerified,
    DateTime? createdAt,
  }) {
    return UserModel(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      role: role ?? this.role,
      managedRestaurantId: managedRestaurantId ?? this.managedRestaurantId,
      favoriteRestaurantIds: favoriteRestaurantIds ?? this.favoriteRestaurantIds,
      isPhoneVerified: isPhoneVerified ?? this.isPhoneVerified,
      isEmailVerified: isEmailVerified ?? this.isEmailVerified,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'phone': phone,
      'avatarUrl': avatarUrl,
      'role': role.name,
      'managedRestaurantId': managedRestaurantId,
      'favoriteRestaurantIds': favoriteRestaurantIds,
      'isPhoneVerified': isPhoneVerified,
      'isEmailVerified': isEmailVerified,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] ?? json['_id'] ?? '',
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      phone: json['phone'] ?? '',
      avatarUrl: json['avatarUrl'],
      role: UserRole.fromString(json['role']),
      managedRestaurantId: json['managedRestaurantId'],
      favoriteRestaurantIds: List<String>.from(json['favoriteRestaurantIds'] ?? []),
      isPhoneVerified: json['isPhoneVerified'] ?? false,
      isEmailVerified: json['isEmailVerified'] ?? false,
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'])
          : DateTime.now(),
    );
  }
}

