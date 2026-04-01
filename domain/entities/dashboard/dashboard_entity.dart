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
      surahName: json['surah_name'] ?? '', // This comes from start_sura
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

  DashboardEntity({
    required this.stats,
    required this.recentHifzLogs,
    required this.recentReviewLogs,
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
    );
  }
}
