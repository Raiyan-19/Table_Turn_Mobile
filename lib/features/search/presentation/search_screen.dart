import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/models/restaurant_model.dart';
import '../../../core/widgets/app_header.dart';
import '../../../core/widgets/category_chip.dart';
import '../../../core/widgets/empty_state_widget.dart';
import '../../../core/widgets/restaurant_card.dart';
import '../../home/providers/restaurant_provider.dart';

class SearchScreen extends ConsumerStatefulWidget {
  const SearchScreen({super.key});

  @override
  ConsumerState<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends ConsumerState<SearchScreen> {
  final _searchController = TextEditingController();

  final List<String> _cuisines = [
    'All',
    'Continental',
    'Steakhouse',
    'Italian',
    'Pan-Asian',
    'Japanese',
    'Traditional Bengali',
    'Mezbani',
    'Seafood',
  ];

  @override
  void initState() {
    super.initState();
    _searchController.text = ref.read(restaurantProvider).searchQuery;
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _showFilterModal() {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.backgroundWarm,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return Consumer(
          builder: (context, ref, _) {
            final state = ref.watch(restaurantProvider);
            final notifier = ref.read(restaurantProvider.notifier);

            return Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 32),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Filter Restaurants',
                        style: GoogleFonts.poppins(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      TextButton(
                        onPressed: () {
                          notifier.resetFilters();
                          Navigator.pop(context);
                        },
                        child: Text(
                          'Reset All',
                          style: GoogleFonts.poppins(
                            color: AppColors.primaryGreen,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const Divider(),
                  const SizedBox(height: 8),

                  // Division Section
                  Text(
                    'Administrative Division',
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: BangladeshDivision.values.map((div) {
                      final isSelected = state.selectedDivision == div;
                      return CategoryChip(
                        label: div.label,
                        isSelected: isSelected,
                        onTap: () => notifier.setDivision(div),
                      );
                    }).toList(),
                  ),

                  const SizedBox(height: 18),

                  // Price Section
                  Text(
                    'Price Tier',
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Wrap(
                    spacing: 8,
                    children: PriceCategory.values.map((price) {
                      final isSelected = state.selectedPrice == price;
                      return CategoryChip(
                        label: '${price.symbol} (${price.label})',
                        isSelected: isSelected,
                        onTap: () => notifier.setPrice(price),
                      );
                    }).toList(),
                  ),

                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primaryGreen,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      onPressed: () => Navigator.pop(context),
                      child: Text(
                        'Apply Filters (${state.filteredRestaurants.length} Results)',
                        style: GoogleFonts.poppins(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final restaurantState = ref.watch(restaurantProvider);
    final restaurantNotifier = ref.read(restaurantProvider.notifier);
    final results = restaurantState.filteredRestaurants;

    return Scaffold(
      backgroundColor: AppColors.backgroundWarm,
      appBar: AppHeader(
        title: 'Explore & Search',
        showBackButton: false,
        actions: [
          IconButton(
            icon: Stack(
              children: [
                const Icon(Icons.tune_rounded, color: AppColors.darkGreen),
                if (restaurantState.selectedDivision != null ||
                    restaurantState.selectedPrice != null)
                  Positioned(
                    right: 0,
                    top: 0,
                    child: Container(
                      width: 8,
                      height: 8,
                      decoration: const BoxDecoration(
                        color: AppColors.accentGold,
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
              ],
            ),
            onPressed: _showFilterModal,
          ),
        ],
      ),
      body: Column(
        children: [
          // Search Input Bar
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 8.0),
            child: TextField(
              controller: _searchController,
              onChanged: (val) => restaurantNotifier.setSearchQuery(val),
              decoration: InputDecoration(
                hintText: 'Search by restaurant name, city, cuisine...',
                prefixIcon: const Icon(Icons.search, color: AppColors.primaryGreen),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear, size: 18),
                        onPressed: () {
                          _searchController.clear();
                          restaurantNotifier.setSearchQuery('');
                        },
                      )
                    : null,
              ),
            ),
          ),

          // Cuisine Pills
          SizedBox(
            height: 40,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 20),
              itemCount: _cuisines.length,
              separatorBuilder: (_, __) => const SizedBox(width: 8),
              itemBuilder: (context, index) {
                final cuisine = _cuisines[index];
                final isSelected = (restaurantState.selectedCuisine == null &&
                        cuisine == 'All') ||
                    restaurantState.selectedCuisine == cuisine;
                return CategoryChip(
                  label: cuisine,
                  isSelected: isSelected,
                  onTap: () => restaurantNotifier.setCuisine(cuisine),
                );
              },
            ),
          ),

          const SizedBox(height: 12),

          // Results Header
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 6.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '${results.length} Restaurants Found',
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
                if (restaurantState.selectedDivision != null ||
                    restaurantState.selectedPrice != null ||
                    restaurantState.selectedCuisine != null)
                  GestureDetector(
                    onTap: () {
                      _searchController.clear();
                      restaurantNotifier.resetFilters();
                    },
                    child: Text(
                      'Clear Filters',
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        color: AppColors.primaryGreen,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
              ],
            ),
          ),

          // Search Results List
          Expanded(
            child: results.isEmpty
                ? EmptyStateWidget(
                    icon: Icons.search_off_rounded,
                    title: 'No Restaurants Found',
                    message:
                        'We couldn\'t find any restaurants matching your current search or filters. Try adjusting your division or cuisine.',
                    buttonText: 'Reset Filters',
                    onButtonPressed: () {
                      _searchController.clear();
                      restaurantNotifier.resetFilters();
                    },
                  )
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                    itemCount: results.length,
                    itemBuilder: (context, index) {
                      final restaurant = results[index];
                      final isFav =
                          restaurantState.favoriteIds.contains(restaurant.id);
                      return RestaurantCard(
                        restaurant: restaurant,
                        isFavorite: isFav,
                        onFavoriteToggle: () =>
                            restaurantNotifier.toggleFavorite(restaurant.id),
                        onTap: () {
                          restaurantNotifier.selectRestaurant(restaurant.id);
                          context.push('/restaurant/${restaurant.id}');
                        },
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}

