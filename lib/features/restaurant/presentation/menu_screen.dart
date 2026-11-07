import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/mock/mock_data.dart';
import '../../../core/widgets/app_header.dart';
import '../../../core/widgets/empty_state_widget.dart';

class MenuScreen extends StatelessWidget {
  final String restaurantId;

  const MenuScreen({
    super.key,
    required this.restaurantId,
  });

  @override
  Widget build(BuildContext context) {
    final restaurant = MockData.restaurants.firstWhere(
      (r) => r.id == restaurantId,
      orElse: () => MockData.restaurants.first,
    );

    final items = MockData.menuItems
        .where((m) => m.restaurantId == restaurant.id)
        .toList();

    return Scaffold(
      backgroundColor: AppColors.backgroundWarm,
      appBar: AppHeader(
        title: '${restaurant.name} Menu',
        subtitle: 'Authentic gourmet offerings in BDT (৳)',
      ),
      body: items.isEmpty
          ? const EmptyStateWidget(
              icon: Icons.menu_book_rounded,
              title: 'Menu Updating',
              message: 'The restaurant staff is currently updating their seasonal menu catalog.',
            )
          : ListView.separated(
              padding: const EdgeInsets.all(20),
              itemCount: items.length,
              separatorBuilder: (_, __) => const SizedBox(height: 14),
              itemBuilder: (context, index) {
                final item = items[index];
                return Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(14),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.03),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: SizedBox(
                          width: 85,
                          height: 85,
                          child: Image.network(
                            item.imageUrl,
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) => Container(
                              color: AppColors.inputBackground,
                              child: const Icon(Icons.fastfood, color: AppColors.textSecondary),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: AppColors.lightGreen,
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: Text(
                                    item.category,
                                    style: GoogleFonts.inter(
                                      fontSize: 10,
                                      fontWeight: FontWeight.w600,
                                      color: AppColors.primaryGreen,
                                    ),
                                  ),
                                ),
                                if (item.isVegetarian) ...[
                                  const SizedBox(width: 6),
                                  const Icon(Icons.eco, size: 14, color: Colors.green),
                                ],
                              ],
                            ),
                            const SizedBox(height: 4),
                            Text(
                              item.name,
                              style: GoogleFonts.poppins(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: AppColors.textPrimary,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 2),
                            Text(
                              item.description,
                              style: GoogleFonts.poppins(
                                fontSize: 11,
                                color: AppColors.textSecondary,
                                height: 1.3,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 6),
                            Text(
                              '৳${item.price.toStringAsFixed(0)}',
                              style: GoogleFonts.inter(
                                fontSize: 15,
                                fontWeight: FontWeight.w700,
                                color: AppColors.primaryGreen,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
    );
  }
}
