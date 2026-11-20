import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/mock/mock_data.dart';
import '../../../core/models/menu_item_model.dart';
import '../../../core/models/review_model.dart';
import '../../../core/models/table_model.dart';
import '../../../core/services/api_service.dart';

/// Provider for restaurant menu items
final restaurantMenuProvider =
    FutureProvider.family<List<MenuItemModel>, String>((ref, restaurantId) async {
  try {
    final res = await ApiService.get('/restaurants/$restaurantId/menu');
    if (res['success'] == true && res['data'] is List) {
      final list = (res['data'] as List)
          .map((item) => MenuItemModel.fromJson(Map<String, dynamic>.from(item)))
          .toList();
      if (list.isNotEmpty) return list;
    }
  } catch (_) {}

  // Fallback to local mock data
  return MockData.menuItems.where((m) => m.restaurantId == restaurantId).toList();
});

/// Provider for restaurant reviews
final restaurantReviewsProvider =
    FutureProvider.family<List<ReviewModel>, String>((ref, restaurantId) async {
  try {
    final res = await ApiService.get('/restaurants/$restaurantId/reviews');
    if (res['success'] == true && res['data'] is List) {
      final list = (res['data'] as List)
          .map((item) => ReviewModel.fromJson(Map<String, dynamic>.from(item)))
          .toList();
      if (list.isNotEmpty) return list;
    }
  } catch (_) {}

  // Fallback to local mock data
  return MockData.reviews.where((r) => r.restaurantId == restaurantId).toList();
});

/// StateNotifier for managing tables for a restaurant (used by both reservation booking and manager table management)
class RestaurantTablesNotifier extends StateNotifier<List<TableModel>> {
  final String restaurantId;

  RestaurantTablesNotifier(this.restaurantId)
      : super(
          MockData.tables.where((t) => t.restaurantId == restaurantId).toList().isNotEmpty
              ? MockData.tables.where((t) => t.restaurantId == restaurantId).toList()
              : MockData.tables,
        ) {
    loadTables();
  }

  Future<void> loadTables() async {
    try {
      final res = await ApiService.get('/restaurants/$restaurantId/tables');
      if (res['success'] == true && res['data'] is List) {
        final list = (res['data'] as List)
            .map((item) => TableModel.fromJson(Map<String, dynamic>.from(item)))
            .toList();
        if (list.isNotEmpty) {
          state = list;
        }
      }
    } catch (_) {}
  }

  Future<void> toggleTableStatus(String tableId, TableStatus newStatus) async {
    state = state.map((t) {
      if (t.id == tableId) {
        return TableModel(
          id: t.id,
          restaurantId: t.restaurantId,
          tableNumber: t.tableNumber,
          section: t.section,
          capacity: t.capacity,
          status: newStatus,
          nextAvailableTime: t.nextAvailableTime,
          minimumSpend: t.minimumSpend,
          features: t.features,
        );
      }
      return t;
    }).toList();

    try {
      await ApiService.patch(
        '/tables/$tableId/status',
        requireAuth: true,
        body: {'status': newStatus.name},
      );
    } catch (_) {}
  }
}

final restaurantTablesProvider =
    StateNotifierProvider.family<RestaurantTablesNotifier, List<TableModel>, String>(
  (ref, restaurantId) => RestaurantTablesNotifier(restaurantId),
);
