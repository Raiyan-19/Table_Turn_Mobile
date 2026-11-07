class MenuItemModel {
  final String id;
  final String restaurantId;
  final String name;
  final String description;
  final String category; // Starters, Main Course, Desserts, Beverages, Chef Specials
  final double price; // In BDT (৳)
  final String imageUrl;
  final bool isAvailable;
  final bool isSpicy;
  final bool isVegetarian;
  final double rating;

  const MenuItemModel({
    required this.id,
    required this.restaurantId,
    required this.name,
    required this.description,
    required this.category,
    required this.price,
    required this.imageUrl,
    this.isAvailable = true,
    this.isSpicy = false,
    this.isVegetarian = false,
    this.rating = 4.8,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'restaurantId': restaurantId,
      'name': name,
      'description': description,
      'category': category,
      'price': price,
      'imageUrl': imageUrl,
      'isAvailable': isAvailable,
      'isSpicy': isSpicy,
      'isVegetarian': isVegetarian,
      'rating': rating,
    };
  }

  factory MenuItemModel.fromJson(Map<String, dynamic> json) {
    return MenuItemModel(
      id: json['id'] ?? json['_id'] ?? '',
      restaurantId: json['restaurantId'] ?? '',
      name: json['name'] ?? '',
      description: json['description'] ?? '',
      category: json['category'] ?? 'Main Course',
      price: (json['price'] as num?)?.toDouble() ?? 0.0,
      imageUrl: json['imageUrl'] ?? '',
      isAvailable: json['isAvailable'] ?? true,
      isSpicy: json['isSpicy'] ?? false,
      isVegetarian: json['isVegetarian'] ?? false,
      rating: (json['rating'] as num?)?.toDouble() ?? 4.5,
    );
  }
}

