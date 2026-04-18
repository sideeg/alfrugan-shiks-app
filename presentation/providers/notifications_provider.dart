// Path: lib/presentation/providers/notifications_provider.dart

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:get_it/get_it.dart';

import '../../domain/entities/notifications/notification_entity.dart';
import '../../domain/usecases/notifications/get_notifications_usecase.dart';
import '../../domain/usecases/notifications/mark_all_as_read_usecase.dart';
import '../../domain/usecases/notifications/mark_notification_read_usecase.dart';

// ═════════════════════════════════════════════════════════════════════════════
// UNREAD COUNT — simple StateProvider driven by dashboard response
// ═════════════════════════════════════════════════════════════════════════════

final unreadCountProvider = StateProvider<int>((ref) => 0);

extension UnreadCountNotifierX on StateController<int> {
  void increment() => state = state + 1;
  void decrementBy(int amount) => state = (state - amount).clamp(0, 999);
  void reset() => state = 0;
  Future<void> refresh() async {} // no-op — dashboard drives the count
}

// ═════════════════════════════════════════════════════════════════════════════
// STATE
// ═════════════════════════════════════════════════════════════════════════════

class NotificationsState {
  final List<NotificationEntity> notifications;
  final bool isLoading;
  final bool isLoadingMore;
  final String? errorMessage;
  final int currentPage;
  final bool hasMore;

  const NotificationsState({
    this.notifications = const [],
    this.isLoading = false,
    this.isLoadingMore = false,
    this.errorMessage,
    this.currentPage = 1,
    this.hasMore = true,
  });

  NotificationsState copyWith({
    List<NotificationEntity>? notifications,
    bool? isLoading,
    bool? isLoadingMore,
    String? errorMessage,
    int? currentPage,
    bool? hasMore,
    bool clearError = false,
  }) {
    return NotificationsState(
      notifications: notifications ?? this.notifications,
      isLoading: isLoading ?? this.isLoading,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      currentPage: currentPage ?? this.currentPage,
      hasMore: hasMore ?? this.hasMore,
    );
  }
}

// ═════════════════════════════════════════════════════════════════════════════
// NOTIFIER
// ═════════════════════════════════════════════════════════════════════════════

class NotificationsNotifier extends StateNotifier<NotificationsState> {
  final GetNotificationsUseCase _getNotifications;
  final MarkNotificationReadUseCase _markRead;
  final MarkAllAsReadUseCase _markAllRead;

  NotificationsNotifier({
    required GetNotificationsUseCase getNotifications,
    required MarkNotificationReadUseCase markRead,
    required MarkAllAsReadUseCase markAllRead,
  })  : _getNotifications = getNotifications,
        _markRead = markRead,
        _markAllRead = markAllRead,
        super(const NotificationsState());

  // ── Load first page ────────────────────────────────────────────────────────

  Future<void> loadNotifications() async {
    if (state.isLoading) return;
    state = state.copyWith(
        isLoading: true, clearError: true, currentPage: 1, hasMore: true);

    final result =
        await _getNotifications(const GetNotificationsParams(page: 1));

    result.fold(
      (failure) => state =
          state.copyWith(isLoading: false, errorMessage: failure.message),
      (notifications) => state = state.copyWith(
        isLoading: false,
        notifications: notifications,
        currentPage: 1,
        hasMore: notifications.length >= 15,
      ),
    );
  }

  // ── Load next page ─────────────────────────────────────────────────────────

  Future<void> loadMore() async {
    if (state.isLoadingMore || !state.hasMore || state.isLoading) return;

    final nextPage = state.currentPage + 1;
    state = state.copyWith(isLoadingMore: true);

    final result =
        await _getNotifications(GetNotificationsParams(page: nextPage));

    result.fold(
      (failure) => state =
          state.copyWith(isLoadingMore: false, errorMessage: failure.message),
      (newNotifications) {
        if (newNotifications.isEmpty) {
          state = state.copyWith(isLoadingMore: false, hasMore: false);
          return;
        }
        state = state.copyWith(
          isLoadingMore: false,
          currentPage: nextPage,
          hasMore: newNotifications.length >= 15,
          notifications: [...state.notifications, ...newNotifications],
        );
      },
    );
  }

  Future<void> refresh() => loadNotifications();

  // ── Mark single notification as read ──────────────────────────────────────
  // Optimistic update first, then API call. The next refresh from the backend
  // will confirm the state because the controller now returns read_at per user.

  Future<void> markAsRead(int notificationId) async {
    // Optimistic local update
    state = state.copyWith(
      notifications: state.notifications.map((n) {
        if (n.id == notificationId && n.isUnread) return n.markAsRead();
        return n;
      }).toList(),
    );
    // Fire API — no need to handle failure, optimistic is fine here
    await _markRead(notificationId);
  }

  // ── Mark ALL as read ───────────────────────────────────────────────────────
  // Calls the single backend endpoint, then updates local state atomically.
  // Previously this looped individual markAsRead calls — incorrect and slow.

  Future<void> markAllAsRead() async {
    // Optimistic: mark everything as read locally
    state = state.copyWith(
      notifications: state.notifications.map((n) {
        if (n.isUnread) return n.markAsRead();
        return n;
      }).toList(),
    );

    // Single backend call for all — atomically updates DB
    await _markAllRead();
  }

  // ── Add incoming FCM notification ──────────────────────────────────────────

  void addIncomingNotification(NotificationEntity notification) {
    final exists = state.notifications.any((n) => n.id == notification.id);
    if (exists) return;
    state =
        state.copyWith(notifications: [notification, ...state.notifications]);
  }
}

// ═════════════════════════════════════════════════════════════════════════════
// PROVIDER
// ═════════════════════════════════════════════════════════════════════════════

final notificationsProvider =
    StateNotifierProvider<NotificationsNotifier, NotificationsState>((ref) {
  return NotificationsNotifier(
    getNotifications: GetIt.instance<GetNotificationsUseCase>(),
    markRead: GetIt.instance<MarkNotificationReadUseCase>(),
    markAllRead: GetIt.instance<MarkAllAsReadUseCase>(),
  );
});
