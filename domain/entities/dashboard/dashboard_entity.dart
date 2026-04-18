// Path: lib/domain/entities/dashboard/dashboard_entity.dart

class DashboardStatsEntity {
  final int totalStudents;
  final int totalCourses;
  final int totalGroups;

  DashboardStatsEntity({
    required this.totalStudents,
    required this.totalCourses,
    required this.totalGroups,
  });
}

class RecentHifzLogEntity {
  final int id;
  final String studentName;
  final String courseName;
  final String surahName;
  final int fromAyah;
  final int toAyah;
  final String date;

  RecentHifzLogEntity({
    required this.id,
    required this.studentName,
    required this.courseName,
    required this.surahName,
    required this.fromAyah,
    required this.toAyah,
    required this.date,
  });

  factory RecentHifzLogEntity.fromJson(Map<String, dynamic> json) {
    return RecentHifzLogEntity(
      id: json['id'],
      studentName: json['student']['name'] ?? 'طالب',
      courseName: json['course']['name'] ?? 'دورة',
      surahName: json['surah_name'] ?? '',
      fromAyah: json['from_ayah'] ?? 0,
      toAyah: json['to_ayah'] ?? 0,
      date: json['date'] ?? json['created_at'] ?? '',
    );
  }
}

class RecentReviewLogEntity {
  final int id;
  final String studentName;
  final String courseName;
  final String surahName;
  final int fromAyah;
  final int toAyah;
  final String date;

  RecentReviewLogEntity({
    required this.id,
    required this.studentName,
    required this.courseName,
    required this.surahName,
    required this.fromAyah,
    required this.toAyah,
    required this.date,
  });

  factory RecentReviewLogEntity.fromJson(Map<String, dynamic> json) {
    return RecentReviewLogEntity(
      id: json['id'],
      studentName: json['student']['name'] ?? 'طالب',
      courseName: json['course']['name'] ?? 'دورة',
      surahName: json['surah_name'] ?? '',
      fromAyah: json['from_ayah'] ?? 0,
      toAyah: json['to_ayah'] ?? 0,
      date: json['date'] ?? json['created_at'] ?? '',
    );
  }
}

class DashboardEntity {
  final DashboardStatsEntity stats;
  final List<RecentHifzLogEntity> recentHifzLogs;
  final List<RecentReviewLogEntity> recentReviewLogs;

  // NEW: unread notification count piggybacked on the dashboard response.
  // Saves a separate API call — the backend calculates it in getDashboard().
  // Defaults to 0 so the app works even if the backend hasn't been updated yet.
  final int unreadNotificationsCount;

  DashboardEntity({
    required this.stats,
    required this.recentHifzLogs,
    required this.recentReviewLogs,
    this.unreadNotificationsCount = 0, // ← default 0, not required
  });

  factory DashboardEntity.fromJson(Map<String, dynamic> json) {
    final data = json['data'];
    return DashboardEntity(
      stats: DashboardStatsEntity(
        totalStudents: data['stats']['total_students'] ?? 0,
        totalCourses: data['stats']['total_courses'] ?? 0,
        totalGroups: data['stats']['total_groups'] ?? 0,
      ),
      recentHifzLogs: (data['recent_hifz_logs'] as List?)
              ?.map((log) => RecentHifzLogEntity.fromJson(log))
              .toList() ??
          [],
      recentReviewLogs: (data['recent_review_logs'] as List?)
              ?.map((log) => RecentReviewLogEntity.fromJson(log))
              .toList() ??
          [],
      // NEW: parse unread_notifications_count from the dashboard response.
      // The ?? 0 fallback means the app won't break if the backend key is missing.
      unreadNotificationsCount: data['unread_notifications_count'] as int? ?? 0,
    );
  }
}
