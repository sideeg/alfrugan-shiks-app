// Path: lib/data/datasources/remote/notifications_remote_datasource.dart

import 'package:dio/dio.dart';

import '../../../core/constants/api_constants.dart';
import '../../../core/errors/error_handler.dart';
import '../../../core/errors/exceptions.dart';
import '../../../core/network/api_client.dart';
import '../../models/notifications/notification_model.dart';

abstract class NotificationsRemoteDataSource {
  Future<List<NotificationModel>> getNotifications({int page = 1});
  Future<bool> markNotificationAsRead(int notificationId);
  Future<bool> markAllNotificationsAsRead(); // NEW
  Future<int> getUnreadCount();
  Future<void> storeDeviceToken({
    required String fcmToken,
    required String deviceType,
  });
}

class NotificationsRemoteDataSourceImpl
    implements NotificationsRemoteDataSource {
  final ApiClient apiClient;
  NotificationsRemoteDataSourceImpl({required this.apiClient});

  // ── GET /notifications ─────────────────────────────────────────────────────

  @override
  Future<List<NotificationModel>> getNotifications({int page = 1}) async {
    try {
      final response = await apiClient.get(
        ApiConstants.NOTIFICATIONS_ENDPOINT,
        queryParameters: {'page': page},
      );

      if (response.statusCode == 200) {
        final responseData = response.data;
        List<dynamic> notificationsJson;

        // Controller returns { success, data: [...], pagination: {...} }
        if (responseData['data'] is List) {
          notificationsJson = responseData['data'] as List<dynamic>;
        } else if (responseData['data'] is Map &&
            responseData['data']['data'] is List) {
          // Fallback for paginated wrapper
          notificationsJson = responseData['data']['data'] as List<dynamic>;
        } else {
          notificationsJson = [];
        }

        return notificationsJson
            .map((json) =>
                NotificationModel.fromJson(json as Map<String, dynamic>))
            .toList();
      } else {
        throw ServerException(
          message: response.data['message'] ?? 'فشل في جلب الإشعارات',
          statusCode: response.statusCode,
        );
      }
    } on DioException catch (e) {
      throw ErrorHandler.handleDioError(e);
    } catch (e) {
      if (e is ServerException) rethrow;
      throw ServerException(message: 'حدث خطأ غير متوقع أثناء جلب الإشعارات');
    }
  }

  // ── POST /notifications/{id}/read ──────────────────────────────────────────

  @override
  Future<bool> markNotificationAsRead(int notificationId) async {
    try {
      final response = await apiClient.post(
        ApiConstants.notificationMarkReadUrl(notificationId),
      );
      return response.statusCode == 200;
    } on DioException catch (e) {
      throw ErrorHandler.handleDioError(e);
    } catch (e) {
      if (e is ServerException) rethrow;
      throw ServerException(message: 'فشل في تحديث حالة الإشعار');
    }
  }

  // ── POST /notifications/read-all ──────────────────────────────────────────
  // NEW: calls the single backend endpoint to mark all as read atomically
  // instead of looping individual mark-as-read calls from Flutter.

  @override
  Future<bool> markAllNotificationsAsRead() async {
    try {
      final response = await apiClient.post(
        ApiConstants.NOTIFICATIONS_MARK_ALL_READ,
      );
      return response.statusCode == 200;
    } on DioException catch (e) {
      throw ErrorHandler.handleDioError(e);
    } catch (e) {
      if (e is ServerException) rethrow;
      throw ServerException(message: 'فشل في تحديث جميع الإشعارات');
    }
  }

  // ── GET /notifications/unread/count ───────────────────────────────────────

  @override
  Future<int> getUnreadCount() async {
    try {
      final response = await apiClient.get(
        ApiConstants.NOTIFICATIONS_UNREAD_COUNT,
      );

      if (response.statusCode == 200) {
        final data = response.data;
        if (data['unread_count'] != null)
          return _parseInt(data['unread_count']);
        if (data['data']?['unread_count'] != null)
          return _parseInt(data['data']['unread_count']);
        if (data['count'] != null) return _parseInt(data['count']);
        return 0;
      } else {
        throw ServerException(
          message: 'فشل في جلب عدد الإشعارات',
          statusCode: response.statusCode,
        );
      }
    } on DioException catch (e) {
      throw ErrorHandler.handleDioError(e);
    } catch (e) {
      if (e is ServerException) rethrow;
      throw ServerException(message: 'حدث خطأ أثناء جلب عدد الإشعارات');
    }
  }

  // ── POST /store-token ──────────────────────────────────────────────────────

  @override
  Future<void> storeDeviceToken({
    required String fcmToken,
    required String deviceType,
  }) async {
    try {
      await apiClient.post(
        ApiConstants.STORE_DEVICE_TOKEN,
        data: {'fcm_token': fcmToken, 'device_type': deviceType},
      );
    } on DioException catch (e) {
      throw ErrorHandler.handleDioError(e);
    } catch (e) {
      if (e is ServerException) rethrow;
      throw ServerException(message: 'فشل في تسجيل جهاز الإشعارات');
    }
  }

  static int _parseInt(dynamic value) {
    if (value == null) return 0;
    if (value is int) return value;
    if (value is String) return int.tryParse(value) ?? 0;
    return 0;
  }
}
