// Path: lib/data/models/notifications/notification_model.dart

import 'dart:convert';

import '../../../domain/entities/notifications/notification_entity.dart';

/// Data model for a notification coming from the API.
///
/// Responsibilities:
///   1. Parse raw JSON from GET /notifications into a typed object.
///   2. Convert to [NotificationEntity] for the domain/presentation layers.
///
/// Key parsing notes:
///   - [readAt]  → comes as ISO-8601 string or null.  No 'is_read' field.
///   - [sentAt]  → comes as ISO-8601 string or null.
///   - [data]    → comes as a JSON object (Map) or null.
///   - [isRead]  → NOT in the JSON; derived in the entity from [readAt].
class NotificationModel {
  final int id;
  final String title;
  final String message;
  final String type;
  final String? target;
  final Map<String, dynamic>? data;
  final DateTime? readAt;
  final DateTime? sentAt;
  final DateTime createdAt;

  const NotificationModel({
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

  /// Parses a single notification object from the API response.
  ///
  /// Example JSON shape (from GET /notifications):
  /// {
  ///   "id": 12,
  ///   "title": "طالب جديد في حلقتك",
  ///   "message": "تمت إضافة الطالب محمد إلى مجموعة الفجر",
  ///   "type": "new_student",
  ///   "target": "individual",
  ///   "data": { "group_id": 3, "group_name": "الفجر", "student_name": "محمد" },
  ///   "read_at": null,
  ///   "sent_at": "2024-04-01T08:30:00.000000Z",
  ///   "created_at": "2024-04-01T08:29:55.000000Z"
  /// }
  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    return NotificationModel(
      id: _parseInt(json['id']),
      title: json['title']?.toString() ?? '',
      message: json['message']?.toString() ?? '',
      type: json['type']?.toString() ?? 'custom_broadcast',
      target: json['target']?.toString(),
      // The data field can arrive as a Map (already decoded by Dio)
      // or occasionally as a JSON string — handle both.
      data: _parseDataField(json['data']),
      readAt: _parseDateTime(json['read_at']),
      sentAt: _parseDateTime(json['sent_at']),
      createdAt: _parseDateTime(json['created_at']) ?? DateTime.now(),
    );
  }

  /// Converts this model into a domain [NotificationEntity].
  /// The domain layer never imports this model — conversion is one-way.
  NotificationEntity toEntity() {
    return NotificationEntity(
      id: id,
      title: title,
      message: message,
      type: type,
      target: target,
      data: data,
      readAt: readAt,
      sentAt: sentAt,
      createdAt: createdAt,
    );
  }

  // ── Private helpers ────────────────────────────────────────────────────────

  static int _parseInt(dynamic value) {
    if (value == null) return 0;
    if (value is int) return value;
    if (value is String) return int.tryParse(value) ?? 0;
    return 0;
  }

  static DateTime? _parseDateTime(dynamic value) {
    if (value == null) return null;
    if (value is String && value.isNotEmpty) {
      return DateTime.tryParse(value);
    }
    return null;
  }

  static Map<String, dynamic>? _parseDataField(dynamic value) {
    if (value == null) return null;
    if (value is Map<String, dynamic>) return value;
    // Sometimes arrives as a JSON-encoded string
    if (value is String && value.isNotEmpty) {
      try {
        final decoded = jsonDecode(value);
        if (decoded is Map<String, dynamic>) return decoded;
      } catch (_) {
        // Ignore — return null if unparseable
      }
    }
    return null;
  }
}
