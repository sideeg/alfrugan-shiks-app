// Path: lib/core/constants/route_constants.dart
class RouteConstants {
  static const String SPLASH = "/";
  static const String LOGIN = "/login";
  static const String DASHBOARD = "/dashboard";
  static const String COURSES = "/courses";
  static const String COURSE_DETAILS = "/course-details";
  static const String STUDENTS = "/students";
  static const String STUDENT_DETAILS = "/student-details";
  static const String LOGS = "/logs";
  static const String CREATE_HIFZ_LOG = "/create-hifz-log";
  static const String CREATE_REVIEW_LOG = "/create-review-log";
  static const String PROFILE = "/profile";
  static const String NOTIFICATIONS = "/notifications";

  // ── Deep Link Destinations (above shell) ─────────────────────────────────
  // Used by FcmService and NotificationHelper to navigate from push taps.

  // 'new_student' notification → /groups/{groupId}/students
  static const String groups = '/groups';

  // 'course_start' / 'course_end' → /courses/{courseId}  (nested in courses)
  // 'enrollment'                  → /students
  // 'custom_broadcast'            → /notifications
}
