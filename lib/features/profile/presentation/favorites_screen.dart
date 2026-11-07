import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/widgets/app_header.dart';
import '../../../core/widgets/empty_state_widget.dart';
import '../../../core/widgets/restaurant_card.dart';
import '../../home/providers/restaurant_provider.dart';

class FavoritesScreen extends ConsumerWidget {
  const FavoritesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final restaurantState = ref.watch(restaurantProvider);
    final restaurantNotifier = ref.read(restaurantProvider.notifier);
    final favorites = restaurantState.favoriteRestaurants;

    return Scaffold(
      backgroundColor: AppColors.backgroundWarm,
      appBar: const AppHeader(
        title: 'Saved Restaurants',
        subtitle: 'Your favorite dining places',
      ),
      body: favorites.isEmpty
          ? EmptyStateWidget(
              icon: Icons.favorite_border_rounded,
              title: 'No Favorites Yet',
              message:
                  'Tap the heart icon on any restaurant card to save your top dining venues here for quick reservations.',
              buttonText: 'Discover Restaurants',
              onButtonPressed: () => context.go('/home'),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(20),
              itemCount: favorites.length,
              itemBuilder: (context, index) {
                final restaurant = favorites[index];
                return RestaurantCard(
                  restaurant: restaurant,
                  isFavorite: true,
                  onFavoriteToggle: () =>
                      restaurantNotifier.toggleFavorite(restaurant.id),
                  onTap: () {
                    restaurantNotifier.selectRestaurant(restaurant.id);
                    context.push('/restaurant/${restaurant.id}');
                  },
                );
              },
            ),
    );
  }
}
