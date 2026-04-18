// Path: lib/core/utils/notification_helper.dart

import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:go_router/go_router.dart';
import 'package:quran_sheikh_app/core/constants/route_constants.dart';
import 'package:quran_sheikh_app/presentation/navigation/app_router.dart';

class NotificationHelper {
  NotificationHelper._();

  static final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();

  static const _channelId = 'sheikh_alerts';
  static const _channelName = 'تنبيهات الشيخ';
  static const _channelDescription = 'إشعارات الطلاب والدورات والمجموعات';

  // ── Initialize ──────────────────────────────────────────────────────────────

  static Future<void> initialize() async {
    const androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: false,
      requestBadgePermission: false,
      requestSoundPermission: false,
    );
    await _plugin.initialize(
      const InitializationSettings(android: androidSettings, iOS: iosSettings),
      onDidReceiveNotificationResponse: _onNotificationTapped,
    );
    await _createAndroidChannel();
  }

  static Future<void> _createAndroidChannel() async {
    const channel = AndroidNotificationChannel(
      _channelId,
      _channelName,
      description: _channelDescription,
      importance: Importance.max,
      playSound: true,
      enableVibration: true,
      showBadge: true,
    );
    await _plugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(channel);
  }

  // ── Show foreground notification ────────────────────────────────────────────

  static Future<void> showNotification({
    required int id,
    required String title,
    required String body,
    String? payload,
  }) async {
    const androidDetails = AndroidNotificationDetails(
      _channelId,
      _channelName,
      channelDescription: _channelDescription,
      importance: Importance.max,
      priority: Priority.high,
      showWhen: true,
      color: Color(0xFFD4A843), // gold
    );
    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );
    await _plugin.show(
      id,
      title,
      body,
      const NotificationDetails(android: androidDetails, iOS: iosDetails),
      payload: payload,
    );
  }

  // ── Build payload ───────────────────────────────────────────────────────────

  static String buildPayload(Map<String, dynamic> data) {
    final type = data['type']?.toString() ?? '';
    final groupId = data['group_id']?.toString() ?? '';
    final courseId = data['course_id']?.toString() ?? '';
    return '$type|$groupId|$courseId';
  }

  // ── Tap handling ────────────────────────────────────────────────────────────

  static void _onNotificationTapped(NotificationResponse response) {
    final payload = response.payload;
    if (payload == null || payload.isEmpty) {
      _navigateTo(RouteConstants.NOTIFICATIONS);
      return;
    }
    final parts = payload.split('|');
    final type = parts.isNotEmpty ? parts[0] : '';
    final groupId =
        parts.length > 1 && parts[1].isNotEmpty ? int.tryParse(parts[1]) : null;
    final courseId =
        parts.length > 2 && parts[2].isNotEmpty ? int.tryParse(parts[2]) : null;
    _routeFromPayload(type: type, groupId: groupId, courseId: courseId);
  }

  /// Called by FcmService for background / terminated taps.
  static void routeFromNotification({
    required String type,
    int? groupId,
    int? courseId,
  }) {
    _routeFromPayload(type: type, groupId: groupId, courseId: courseId);
  }

  // ── Routing logic ───────────────────────────────────────────────────────────
  // FIX: new_student and enrollment notifications now route to /students
  // instead of defaulting to dashboard.

  static void _routeFromPayload({
    required String type,
    int? groupId,
    int? courseId,
  }) {
    switch (type) {
      // New student added to group → show students list
      case 'new_student':
        _navigateTo(RouteConstants.STUDENTS);
        break;

      // Enrollment / withdrawal / removal → show students list
      case 'enrollment':
        _navigateTo(RouteConstants.STUDENTS);
        break;

      // Course notifications → show courses screen
      case 'course_start':
      case 'course_end':
        _navigateTo(RouteConstants.COURSES);
        break;

      // Admin broadcast or unknown → open notification list
      case 'custom_broadcast':
      default:
        _navigateTo(RouteConstants.NOTIFICATIONS);
        break;
    }
  }

  static void _navigateTo(String path) {
    final context = AppRouter.navigatorKey.currentContext;
    if (context != null && context.mounted) {
      GoRouter.of(context).go(path);
    } else {
      debugPrint(
          '[NotificationHelper] ⚠️ Navigator context null — cannot navigate to $path');
    }
  }

  // ── Cancel ──────────────────────────────────────────────────────────────────

  static Future<void> cancelAll() async => _plugin.cancelAll();
}
