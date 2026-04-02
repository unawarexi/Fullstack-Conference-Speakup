import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:video_confrence_app/app/domain/models/notification_model.dart';
import 'package:video_confrence_app/app/domain/repositories/notification_repository.dart';
import 'package:video_confrence_app/core/services/websocket.dart';

final notificationRepositoryProvider = Provider<NotificationRepository>((ref) {
  return NotificationRepository();
});

/// Unread notification count (for badges).
final unreadNotificationCountProvider = StateProvider<int>((ref) => 0);

/// Notifications list with pagination.
final notificationsProvider = StateNotifierProvider<
    NotificationsNotifier, AsyncValue<List<NotificationModel>>>((ref) {
  return NotificationsNotifier(ref);
});

class NotificationsNotifier
    extends StateNotifier<AsyncValue<List<NotificationModel>>> {
  final Ref _ref;
  StreamSubscription? _wsSub;

  NotificationsNotifier(this._ref) : super(const AsyncValue.loading()) {
    fetch();
    _listenToWebSocket();
  }

  Future<void> fetch() async {
    try {
      final notifications =
          await _ref.read(notificationRepositoryProvider).getNotifications();
      state = AsyncValue.data(notifications);
      // Update unread count
      final count =
          await _ref.read(notificationRepositoryProvider).getUnreadCount();
      _ref.read(unreadNotificationCountProvider.notifier).state = count;
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> markAsRead(String id) async {
    await _ref.read(notificationRepositoryProvider).markAsRead(id);
    state.whenData((list) {
      state = AsyncValue.data(
        list.map((n) => n.id == id ? n.copyWith(isRead: true) : n).toList(),
      );
    });
    final count = _ref.read(unreadNotificationCountProvider);
    if (count > 0) {
      _ref.read(unreadNotificationCountProvider.notifier).state = count - 1;
    }
  }

  Future<void> markAllAsRead() async {
    await _ref.read(notificationRepositoryProvider).markAllAsRead();
    state.whenData((list) {
      state = AsyncValue.data(
        list.map((n) => n.copyWith(isRead: true)).toList(),
      );
    });
    _ref.read(unreadNotificationCountProvider.notifier).state = 0;
  }

  Future<void> delete(String id) async {
    await _ref.read(notificationRepositoryProvider).delete(id);
    state.whenData((list) {
      state = AsyncValue.data(list.where((n) => n.id != id).toList());
    });
  }

  void _listenToWebSocket() {
    _wsSub = WebSocketService().stream('notification').listen((data) {
      if (data is Map<String, dynamic>) {
        final notification = NotificationModel.fromJson(data);
        state.whenData((list) {
          state = AsyncValue.data([notification, ...list]);
        });
        _ref.read(unreadNotificationCountProvider.notifier).state++;
      }
    });
  }

  @override
  void dispose() {
    _wsSub?.cancel();
    super.dispose();
  }
}
