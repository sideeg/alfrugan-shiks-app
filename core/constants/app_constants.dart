// Path: lib/core/constants/app_constants.dart
class AppConstants {
  static const String APP_NAME = "Quran Sheikh App";
  static const String TOKEN_KEY = "auth_token";
  static const String USER_KEY = "user_data";
  static const String VERSION_KEY = 'minimum_required_version';
  static const int CONNECTION_TIMEOUT = 30000;
  static const int RECEIVE_TIMEOUT = 30000;

  // Stored locally so we can:
  //   - Skip re-registration if the token hasn't changed since last launch
  //   - Know what token to ask the backend to delete on logout
  static const String FCM_TOKEN_KEY = 'fcm_token';

  // ── FCM Topics ─────────────────────────────────────────────────────────────
  // The sheikh app subscribes to this topic after login.
  // Admin broadcasts to 'teachers' target on the backend → FCM topic_teachers.
  // The backend strips 'topic_' prefix, so topic name must match exactly.
  static const String FCM_TOPIC_TEACHERS = 'teachers';

  // ── Pagination ─────────────────────────────────────────────────────────────
  static const int NOTIFICATIONS_PAGE_SIZE = 15;

  // ── Timeouts ───────────────────────────────────────────────────────────────
  static const int CONNECTION_TIMEOUT_SECONDS = 30;
  static const int RECEIVE_TIMEOUT_SECONDS = 30;
}
