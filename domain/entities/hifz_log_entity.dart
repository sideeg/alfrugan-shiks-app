// lib/domain/entities/hifz_log_entity.dart

class HifzLogEntity {
  final int id;
  final int studentId;
  final int groupId;
  final int? courseId; // ✅ NULLABLE - might be deleted
  final String startSurah;
  final String endSurah;
  final int startAyah;
  final int endAyah;
  final String evaluation;
  final String notes;
  final DateTime date;
  final String? courseName; // ✅ NEW - for display

  HifzLogEntity({
    required this.id,
    required this.studentId,
    required this.groupId,
    required this.courseId,
    required this.startSurah,
    required this.endSurah,
    required this.startAyah,
    required this.endAyah,
    required this.evaluation,
    required this.notes,
    required this.date,
    this.courseName,
  });

  factory HifzLogEntity.fromJson(Map<String, dynamic> json) => HifzLogEntity(
        id: json['id'],
        studentId: json['student_id'],
        groupId: json['group_id'],
        courseId: json['course_id'], // Can be null
        startSurah: json['start_surah'],
        endSurah: json['end_surah'],
        startAyah: json['start_ayah'],
        endAyah: json['end_ayah'],
        evaluation: json['evaluation'],
        notes: json['notes'] ?? '',
        date: DateTime.parse(json['created_at']),
        courseName: json['course_name'], // NEW
      );
}
