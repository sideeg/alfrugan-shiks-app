// Path: lib/services/fcm_service.dart

import 'dart:io';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/constants/app_constants.dart';
import '../core/utils/notification_helper.dart';
import '../core/utils/permission_helper.dart';
import '../data/datasources/local/auth_local_datasource.dart';
import '../data/datasources/remote/notifications_remote_datasource.dart';
import '../domain/entities/notifications/notification_entity.dart';
import '../data/models/notifications/notification_model.dart';
import '../presentation/providers/notifications_provider.dart';

// ─────────────────────────────────────────────────────────────────────────────
// BACKGROUND MESSAGE HANDLER
//
// CRITICAL: This function MUST be a top-level function (not a method, not a
// closure). Firebase runs it in a separate Dart isolate when the app is in
// the background. GetIt, Riverpod, and SharedPreferences are NOT accessible
// from this isolate — keep it minimal.
// ─────────────────────────────────────────────────────────────────────────────
@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  // Nothing to do here — the OS already shows the system notification tray
  // banner automatically when the app is in the background. We handle the
  // tap in FcmService.onMessageOpenedApp instead.
  debugPrint('[FCM Background] Received: ${message.messageId}');
}

// ─────────────────────────────────────────────────────────────────────────────
// FCM SERVICE
// ─────────────────────────────────────────────────────────────────────────────

class FcmService {
  FcmService._();
  static final FcmService instance = FcmService._();

  final FirebaseMessaging _fcm = FirebaseMessaging.instance;

  // Holds a reference to the Riverpod container for updating providers
  // from outside the widget tree (FCM callbacks are not in widget context).
  ProviderContainer? _container;

  void setContainer(ProviderContainer container) {
    _container = container;
  }

  // ── Initialize (called after login) ────────────────────────────────────────

  /// Call this once after a successful login.
  /// Order matters:
  ///   1. Request permission (Android 13+ / iOS)
  ///   2. Get FCM token
  ///   3. Register token with backend
  ///   4. Subscribe to teacher topic
  ///   5. Wire up message handlers
  Future<void> initialize({
    required AuthLocalDataSource localDataSource,
    required NotificationsRemoteDataSource remoteDataSource,
  }) async {
    // TEMPORARY — remove after confirming token
    await localDataSource.clearFcmToken();

    debugPrint('[FCM] ══════════ initialize() called ══════════');
    // 1. Request permission ─────────────────────────────────────────────────
    // On Android: permission_handler manages the runtime POST_NOTIFICATIONS
    // dialog (Android 13+). Call it first to avoid a double-dialog scenario.
    await PermissionHelper.requestNotificationPermission();

    // On iOS: Firebase's own requestPermission() triggers the APNs dialog.
    // This is a no-op on Android — harmless to always call.
    await _fcm.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    // 2. Get FCM token ──────────────────────────────────────────────────────
    // getToken() returns null if permission was denied or device is not
    // registered with FCM yet. Always null-check.
    final token = await _fcm.getToken();
    debugPrint("FCM token  $token");
    if (token != null) {
      await _registerToken(
        token: token,
        localDataSource: localDataSource,
        remoteDataSource: remoteDataSource,
      );
    }
    debugPrint("FCM full token : $token");
    // 3. Subscribe to topic ────────────────────────────────────────────────
    // Do this AFTER confirming a valid token exists.
    // Admin broadcasts to 'teachers' → FCM delivers to this topic.
    await _fcm.subscribeToTopic(AppConstants.FCM_TOPIC_TEACHERS);
    debugPrint('[FCM] Subscribed to topic: ${AppConstants.FCM_TOPIC_TEACHERS}');

    // 4. Listen for token rotation ──────────────────────────────────────────
    // Firebase rotates the FCM token periodically. We must update the backend
    // with the new token, otherwise pushes stop working silently.
    _fcm.onTokenRefresh.listen((newToken) async {
      debugPrint('[FCM] Token refreshed — re-registering...');
      debugPrint("NEW TOKEN: $newToken");
      await _registerToken(
        token: newToken,
        localDataSource: localDataSource,
        remoteDataSource: remoteDataSource,
      );
    });

    // 5. Wire up message handlers ────────────────────────────────────────────
    _setupForegroundHandler();
    _setupBackgroundTapHandler();

    // 6. Handle terminated-state tap ────────────────────────────────────────
    // getInitialMessage() returns the FCM message that launched the app if
    // the user tapped a notification while the app was fully terminated.
    // Must be called early — the message is consumed after the first read.
    final initialMessage = await _fcm.getInitialMessage();
    if (initialMessage != null) {
      // Delay to let the widget tree and router fully initialize before
      // attempting navigation. Without this, GoRouter context isn't ready.
      Future.delayed(const Duration(milliseconds: 600), () {
        _handleMessageTap(initialMessage);
      });
    }
  }

  // ── Token Registration ─────────────────────────────────────────────────────

  Future<void> _registerToken({
    required String token,
    required AuthLocalDataSource localDataSource,
    required NotificationsRemoteDataSource remoteDataSource,
  }) async {
    try {
      // Check if the token is the same as the one we already registered.
      // Avoids an unnecessary network call on every app launch.
      final cachedToken = await localDataSource.getFcmToken();
      if (cachedToken == token) {
        debugPrint('[FCM] Token unchanged — skipping registration');
        return;
      }

      final deviceType = Platform.isIOS ? 'ios' : 'android';

      // Register with backend
      await remoteDataSource.storeDeviceToken(
        fcmToken: token,
        deviceType: deviceType,
      );

      // Cache locally
      await localDataSource.saveFcmToken(token);

      debugPrint('[FCM] Token registered: ${token.substring(0, 20)}...');
    } catch (e) {
      // Token registration failure is non-fatal. The sheikh can still use
      // the app — they just won't receive direct pushes until next launch.
      debugPrint('[FCM] Token registration failed: $e');
    }
  }

  // ── Foreground Handler ─────────────────────────────────────────────────────

  void _setupForegroundHandler() {
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      debugPrint('[FCM Foreground] Received: ${message.notification?.title}');

      final notification = message.notification;
      if (notification == null) return;

      final data = message.data;

      // Show a heads-up local notification banner (FCM doesn't show system UI
      // when the app is in the foreground).
      NotificationHelper.showNotification(
        // Use hashCode of messageId as int ID — avoids duplicate IDs
        id: message.messageId?.hashCode ??
            DateTime.now().millisecondsSinceEpoch,
        title: notification.title ?? '',
        body: notification.body ?? '',
        payload: NotificationHelper.buildPayload(data),
      );

      // Update the unread badge count immediately
      _container?.read(unreadCountProvider.notifier).increment();

      // Prepend the new notification to the list if the screen is open
      // Construct a minimal entity from the FCM payload
      final entity = _buildEntityFromMessage(message);
      if (entity != null) {
        _container
            ?.read(notificationsProvider.notifier)
            .addIncomingNotification(entity);
      }
    });
  }

  // ── Background Tap Handler ─────────────────────────────────────────────────

  void _setupBackgroundTapHandler() {
    // Fires when the user taps a system notification while the app is
    // in the background (not terminated). App is already running.
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      debugPrint('[FCM] Background tap: ${message.notification?.title}');
      _handleMessageTap(message);
    });
  }

  // ── Deep Link Navigation ───────────────────────────────────────────────────

  void _handleMessageTap(RemoteMessage message) {
    final data = message.data;
    final type = data['type']?.toString() ?? '';
    final groupId = int.tryParse(data['group_id']?.toString() ?? '');
    final courseId = int.tryParse(data['course_id']?.toString() ?? '');

    NotificationHelper.routeFromNotification(
      type: type,
      groupId: groupId,
      courseId: courseId,
    );
  }

  // ── Build Entity from FCM Message ──────────────────────────────────────────

  NotificationEntity? _buildEntityFromMessage(RemoteMessage message) {
    try {
      final notification = message.notification;
      if (notification == null) return null;

      final data = message.data;
      // FCM data values are always strings — parse the data map types
      final typedData = <String, dynamic>{...data};

      return NotificationEntity(
        // Use hashCode as a temporary ID — it will be replaced when the
        // notifications list is refreshed from the API
        id: message.messageId?.hashCode ??
            DateTime.now().millisecondsSinceEpoch,
        title: notification.title ?? '',
        message: notification.body ?? '',
        type: data['type'] ?? 'custom_broadcast',
        data: typedData,
        createdAt: DateTime.now(),
        sentAt: DateTime.now(),
      );
    } catch (_) {
      return null;
    }
  }

  // ── Dispose (called on logout) ─────────────────────────────────────────────

  /// Clean up when the sheikh logs out.
  /// Unsubscribes from topic and removes the local token cache.
  /// The backend token record will be invalidated naturally when the user
  /// logs back in with a potentially new token.
  Future<void> dispose({
    required AuthLocalDataSource localDataSource,
  }) async {
    try {
      // Unsubscribe from broadcast topic
      await _fcm.unsubscribeFromTopic(AppConstants.FCM_TOPIC_TEACHERS);
      debugPrint(
          '[FCM] Unsubscribed from topic: ${AppConstants.FCM_TOPIC_TEACHERS}');

      // Remove the locally cached FCM token
      await localDataSource.clearFcmToken();

      // Clear any displayed local notifications
      await NotificationHelper.cancelAll();

      debugPrint('[FCM] Disposed successfully');
    } catch (e) {
      debugPrint('[FCM] Dispose error: $e');
    }
  }
}
