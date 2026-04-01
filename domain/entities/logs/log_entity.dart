// ─────────────────────────────────────────────────────────────────────────────
// lib/domain/entities/logs/log_entity.dart
// ─────────────────────────────────────────────────────────────────────────────
class LogSummaryEntity {
  final int hifzThisWeek;
  final int hifzThisMonth;
  final int reviewThisWeek;
  final int reviewThisMonth;
  final int totalThisWeek;
  final int totalThisMonth;

  const LogSummaryEntity({
    required this.hifzThisWeek,
    required this.hifzThisMonth,
    required this.reviewThisWeek,
    required this.reviewThisMonth,
    required this.totalThisWeek,
    required this.totalThisMonth,
  });
}

class LogEntryEntity {
  final int id;
  final String type; // 'hifz' | 'review'
  final int studentId;
  final String studentName;
  final String surahName;
  final int fromAyah;
  final int toAyah;
  final String date;
  final int courseId;
  final String courseName;
  final DateTime createdAt;

  const LogEntryEntity({
    required this.id,
    required this.type,
    required this.studentId,
    required this.studentName,
    required this.surahName,
    required this.fromAyah,
    required this.toAyah,
    required this.date,
    required this.courseId,
    required this.courseName,
    required this.createdAt,
  });

  bool get isHifz => type == 'hifz';
}

class LogsPageEntity {
  final LogSummaryEntity summary;
  final List<LogEntryEntity> logs;
  final int total;
  final int currentPage;
  final int lastPage;
  final bool hasMore;

  const LogsPageEntity({
    required this.summary,
    required this.logs,
    required this.total,
    required this.currentPage,
    required this.lastPage,
    required this.hasMore,
  });
}
