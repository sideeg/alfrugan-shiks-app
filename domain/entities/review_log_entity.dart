// lib/domain/entities/review_log_entity.dart
class ReviewLogEntity {
  final int id;
  final int studentId;
  final int groupId;
  final int? courseId;
  final String startSurah;
  final String endSurah;
  final int startAyah;
  final int endAyah;
  final String evaluation;
  final String notes;
  final DateTime date;
  final String? courseName;

  ReviewLogEntity({
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

  factory ReviewLogEntity.fromJson(Map<String, dynamic> json) =>
      ReviewLogEntity(
        id: json['id'],
        studentId: json['student_id'],
        groupId: json['group_id'],
        courseId: json['course_id'],
        startSurah: json['start_surah'],
        endSurah: json['end_surah'],
        startAyah: json['start_ayah'],
        endAyah: json['end_ayah'],
        evaluation: json['evaluation'],
        notes: json['notes'] ?? '',
        date: DateTime.parse(json['created_at']),
      );
}
