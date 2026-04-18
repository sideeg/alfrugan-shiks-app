// Path: lib/domain/entities/notifications/notification_entity.dart

import 'package:equatable/equatable.dart';

/// Core domain object for a notification.
///
/// This is the single source of truth the rest of the app works with.
/// It has no dependency on JSON, Dio, or any framework — pure Dart.
///
/// [isRead] is DERIVED from [readAt] — if [readAt] is non-null, the
/// notification has been read. The backend does not send an `is_read`
/// boolean; we compute it here so the UI never has to worry about it.
class NotificationEntity extends Equatable {
  final int id;
  final String title;
  final String message;

  /// Notification type — drives icon, color, and deep-link destination.
  /// Known values from the backend:
  ///   'new_student'      → student added to sheikh's group
  ///   'enrollment'       → enrollment approved / rejected / withdrawn
  ///   'course_start'     → course is starting
  ///   'course_end'       → course has ended
  ///   'custom_broadcast' → admin manual broadcast
  final String type;

  /// Who the notification was sent to: 'students', 'teachers', 'both', or null.
  final String? target;

  /// Contextual payload from the backend's `data` JSON column.
  /// May contain: group_id, course_id, student_name, course_name, status, etc.
  /// Always access with null-safety: entity.data?['group_id']
  final Map<String, dynamic>? data;

  /// If non-null, this notification has been read by the current sheikh.
  /// Derived [isRead] getter uses this field.
  final DateTime? readAt;

  /// When the notification was dispatched/sent. Used for display ordering.
  final DateTime? sentAt;

  final DateTime createdAt;

  const NotificationEntity({
    required this.id,
    required this.title,
    required this.message,
    required this.type,
    required this.createdAt,
    this.target,
    this.data,
    this.readAt,
    this.sentAt,
  });

  /// True if the sheikh has already read this notification.
  /// Derived from [readAt] — no need to store a separate boolean.
  bool get isRead => readAt != null;

  /// True if the notification has not been read yet.
  bool get isUnread => readAt == null;

  /// Helper to safely extract an int from the data payload.
  /// Example: entity.dataInt('group_id')
  int? dataInt(String key) {
    final val = data?[key];
    if (val == null) return null;
    if (val is int) return val;
    if (val is String) return int.tryParse(val);
    return null;
  }

  /// Helper to safely extract a String from the data payload.
  String? dataString(String key) {
    final val = data?[key];
    if (val == null) return null;
    return val.toString();
  }

  /// Returns a copy of this entity with updated fields.
  /// Used for optimistic UI updates (mark as read without waiting for API).
  NotificationEntity copyWith({
    int? id,
    String? title,
    String? message,
    String? type,
    String? target,
    Map<String, dynamic>? data,
    DateTime? readAt,
    DateTime? sentAt,
    DateTime? createdAt,
  }) {
    return NotificationEntity(
      id: id ?? this.id,
      title: title ?? this.title,
      message: message ?? this.message,
      type: type ?? this.type,
      target: target ?? this.target,
      data: data ?? this.data,
      readAt: readAt ?? this.readAt,
      sentAt: sentAt ?? this.sentAt,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  /// Creates a marked-as-read copy of this entity.
  /// Called immediately on tap for optimistic UI update.
  NotificationEntity markAsRead() {
    return copyWith(readAt: DateTime.now());
  }

  @override
  List<Object?> get props => [
        id,
        title,
        message,
        type,
        target,
        data,
        readAt,
        sentAt,
        createdAt,
      ];

  @override
  String toString() =>
      'NotificationEntity(id: $id, type: $type, isRead: $isRead, title: $title)';
}
