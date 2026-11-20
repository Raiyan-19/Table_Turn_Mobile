import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/models/notification_model.dart';
import '../../../core/services/api_service.dart';

class NotificationState {
  final List<NotificationModel> notifications;
  final bool isLoading;
  final String? errorMessage;

  const NotificationState({
    this.notifications = const [],
    this.isLoading = false,
    this.errorMessage,
  });

  int get unreadCount => notifications.where((n) => !n.isRead).length;

  NotificationState copyWith({
    List<NotificationModel>? notifications,
    bool? isLoading,
    String? errorMessage,
  }) {
    return NotificationState(
      notifications: notifications ?? this.notifications,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}

class NotificationNotifier extends StateNotifier<NotificationState> {
  NotificationNotifier()
      : super(
          NotificationState(
            notifications: [
              NotificationModel(
                id: 'notif_01',
                userId: 'user_01',
                title: 'Reservation Confirmed',
                body:
                    'Your table for 2 at The Forest Lounge (Gulshan-2) is confirmed for tomorrow at 07:30 PM.',
                type: 'booking_confirmed',
                isRead: false,
                createdAt: DateTime.now().subtract(const Duration(hours: 2)),
              ),
              NotificationModel(
                id: 'notif_02',
                userId: 'user_01',
                title: 'Upcoming Dining Reminder',
                body:
                    'Reminder: Your reservation at Skyline Terrace Dining starts in 2 hours. Have your QR pass ready.',
                type: 'booking_reminder',
                isRead: true,
                createdAt: DateTime.now().subtract(const Duration(days: 1)),
              ),
              NotificationModel(
                id: 'notif_03',
                userId: 'user_01',
                title: 'New Restaurant Added',
                body:
                    'Seven Layer Green Garden is now open for instant table reservations in Sylhet.',
                type: 'system',
                isRead: true,
                createdAt: DateTime.now().subtract(const Duration(days: 3)),
              ),
            ],
          ),
        ) {
    loadNotifications();
  }

  Future<void> loadNotifications() async {
    try {
      final res = await ApiService.get('/notifications', requireAuth: true);
      if (res['success'] == true && res['data'] is List) {
        final list = (res['data'] as List)
            .map((item) => NotificationModel.fromJson(Map<String, dynamic>.from(item)))
            .toList();
        if (list.isNotEmpty) {
          state = state.copyWith(notifications: list, errorMessage: null);
        }
      }
    } catch (_) {
      // Keep initial fallback notifications if offline or in test
    }
  }

  Future<void> markAsRead(String id) async {
    final updated = state.notifications.map((n) {
      if (n.id == id) {
        return NotificationModel(
          id: n.id,
          userId: n.userId,
          title: n.title,
          body: n.body,
          type: n.type,
          isRead: true,
          createdAt: n.createdAt,
        );
      }
      return n;
    }).toList();

    state = state.copyWith(notifications: updated);

    try {
      await ApiService.patch('/notifications/$id/read', requireAuth: true);
    } catch (_) {}
  }

  Future<void> markAllAsRead() async {
    final updated = state.notifications.map((n) {
      return NotificationModel(
        id: n.id,
        userId: n.userId,
        title: n.title,
        body: n.body,
        type: n.type,
        isRead: true,
        createdAt: n.createdAt,
      );
    }).toList();

    state = state.copyWith(notifications: updated);

    try {
      await ApiService.patch('/notifications/read-all', requireAuth: true);
    } catch (_) {}
  }
}

final notificationProvider =
    StateNotifierProvider<NotificationNotifier, NotificationState>((ref) {
  return NotificationNotifier();
});
