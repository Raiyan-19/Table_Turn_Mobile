import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/mock/mock_data.dart';
import '../../../core/models/restaurant_model.dart';

class RestaurantState {
  final List<RestaurantModel> allRestaurants;
  final BangladeshDivision? selectedDivision;
  final String? selectedCuisine;
  final PriceCategory? selectedPrice;
  final String searchQuery;
  final Set<String> favoriteIds;
  final String? selectedRestaurantId;

  const RestaurantState({
    this.allRestaurants = const [],
    this.selectedDivision,
    this.selectedCuisine,
    this.selectedPrice,
    this.searchQuery = '',
    this.favoriteIds = const {},
    this.selectedRestaurantId,
  });

  List<RestaurantModel> get filteredRestaurants {
    return allRestaurants.where((restaurant) {
      // Division filter
      if (selectedDivision != null && restaurant.division != selectedDivision) {
        return false;
      }
      // Cuisine filter
      if (selectedCuisine != null &&
          selectedCuisine != 'All' &&
          !restaurant.cuisineTypes.any(
            (c) => c.toLowerCase().contains(selectedCuisine!.toLowerCase()),
          )) {
        return false;
      }
      // Price filter
      if (selectedPrice != null && restaurant.priceCategory != selectedPrice) {
        return false;
      }
      // Search query filter (matches name, city, address, or cuisine)
      if (searchQuery.isNotEmpty) {
        final query = searchQuery.toLowerCase();
        final matchesName = restaurant.name.toLowerCase().contains(query);
        final matchesCity = restaurant.city.toLowerCase().contains(query);
        final matchesAddress = restaurant.address.toLowerCase().contains(query);
        final matchesCuisine = restaurant.cuisineTypes.any(
          (c) => c.toLowerCase().contains(query),
        );
        if (!matchesName && !matchesCity && !matchesAddress && !matchesCuisine) {
          return false;
        }
      }
      return true;
    }).toList();
  }

  List<RestaurantModel> get featuredRestaurants {
    return allRestaurants.where((r) => r.isFeatured).toList();
  }

  List<RestaurantModel> get favoriteRestaurants {
    return allRestaurants.where((r) => favoriteIds.contains(r.id)).toList();
  }

  RestaurantModel? get selectedRestaurant {
    if (selectedRestaurantId == null) return null;
    return allRestaurants.firstWhere(
      (r) => r.id == selectedRestaurantId,
      orElse: () => allRestaurants.first,
    );
  }

  RestaurantState copyWith({
    List<RestaurantModel>? allRestaurants,
    BangladeshDivision? selectedDivision,
    bool clearDivision = false,
    String? selectedCuisine,
    bool clearCuisine = false,
    PriceCategory? selectedPrice,
    bool clearPrice = false,
    String? searchQuery,
    Set<String>? favoriteIds,
    String? selectedRestaurantId,
  }) {
    return RestaurantState(
      allRestaurants: allRestaurants ?? this.allRestaurants,
      selectedDivision: clearDivision ? null : (selectedDivision ?? this.selectedDivision),
      selectedCuisine: clearCuisine ? null : (selectedCuisine ?? this.selectedCuisine),
      selectedPrice: clearPrice ? null : (selectedPrice ?? this.selectedPrice),
      searchQuery: searchQuery ?? this.searchQuery,
      favoriteIds: favoriteIds ?? this.favoriteIds,
      selectedRestaurantId: selectedRestaurantId ?? this.selectedRestaurantId,
    );
  }
}

class RestaurantNotifier extends StateNotifier<RestaurantState> {
  RestaurantNotifier()
      : super(
          RestaurantState(
            allRestaurants: MockData.restaurants,
            favoriteIds: {'rest_01', 'rest_03'},
          ),
        );

  void setDivision(BangladeshDivision? division) {
    if (state.selectedDivision == division) {
      state = state.copyWith(clearDivision: true);
    } else {
      state = state.copyWith(selectedDivision: division);
    }
  }

  void setCuisine(String? cuisine) {
    if (cuisine == null || cuisine == 'All' || state.selectedCuisine == cuisine) {
      state = state.copyWith(clearCuisine: true);
    } else {
      state = state.copyWith(selectedCuisine: cuisine);
    }
  }

  void setPrice(PriceCategory? price) {
    if (state.selectedPrice == price) {
      state = state.copyWith(clearPrice: true);
    } else {
      state = state.copyWith(selectedPrice: price);
    }
  }

  void setSearchQuery(String query) {
    state = state.copyWith(searchQuery: query);
  }

  void selectRestaurant(String id) {
    state = state.copyWith(selectedRestaurantId: id);
  }

  void toggleFavorite(String restaurantId) {
    final updated = Set<String>.from(state.favoriteIds);
    if (updated.contains(restaurantId)) {
      updated.remove(restaurantId);
    } else {
      updated.add(restaurantId);
    }
    state = state.copyWith(favoriteIds: updated);
  }

  void resetFilters() {
    state = state.copyWith(
      clearDivision: true,
      clearCuisine: true,
      clearPrice: true,
      searchQuery: '',
    );
  }
}

final restaurantProvider =
    StateNotifierProvider<RestaurantNotifier, RestaurantState>((ref) {
  return RestaurantNotifier();
});
