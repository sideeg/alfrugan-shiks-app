// Path: lib/core/constants/api_constants.dart
class ApiConstants {
  static const String BASE_URL = "http://192.168.18.4:8000/api/v1";
  static const String LOGIN_ENDPOINT = "/sheikh/login";
  static const String COURSES_ENDPOINT = "/sheikh/courses";
  static const String COURSE_GROUPS_ENDPOINT =
      "/sheikh/courses/{courseId}/groups";
  static const String PROFILE_ENDPOINT = '/sheikh/profile';
  // ── Device Token ──────────────────────────────────────────────────────────
  // POST   /store-token   body: { fcm_token, device_type }
  // Called after login and on FCM token refresh.
  // Uses updateOrCreate on the backend so safe to call multiple times.
  static const String STORE_DEVICE_TOKEN = '/store-token';

  // ── Notifications ─────────────────────────────────────────────────────────
  // GET    /notifications
  // Returns paginated list of notifications for the authenticated sheikh.
  // Query params: page (int)
  static const String NOTIFICATIONS_ENDPOINT = '/notifications';

  // GET    /notifications/unread/count
  // Returns: { "count": int }
  // Lightweight — safe to poll on app resume and after each push arrives.
  static const String NOTIFICATIONS_UNREAD_COUNT =
      '/notifications/unread/count';

  // POST   /notifications/{id}/read
  // Marks a single notification as read for the authenticated user.
  // No request body needed. Returns 200 on success.
  // Usage: build the URL with notificationMarkReadUrl(id)
  static String notificationMarkReadUrl(int id) => '/notifications/$id/read';

  static const String NOTIFICATIONS_MARK_ALL_READ =
      '/notifications/mark-all-read';
}
