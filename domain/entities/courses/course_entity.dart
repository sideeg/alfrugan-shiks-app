// lib/domain/entities/course_entity.dart
class CourseEntity {
  final int id;
  final String name;
  final String description;
  final String startDate;
  final String endDate;
  final String typeDisplayName;
  final int currentStudents;
  final int maxStudents;
  final bool isRegistrationOpen;

  CourseEntity({
    required this.id,
    required this.name,
    required this.description,
    required this.startDate,
    required this.endDate,
    required this.typeDisplayName,
    required this.currentStudents,
    required this.maxStudents,
    required this.isRegistrationOpen,
  });

  factory CourseEntity.fromJson(Map<String, dynamic> json) => CourseEntity(
        id: json['id'],
        name: json['name'],
        description: json['description'],
        startDate: json['start_date'],
        endDate: json['end_date'],
        typeDisplayName: json['type_display_name'],
        currentStudents: json['current_students'],
        maxStudents: json['max_students'],
        isRegistrationOpen: json['is_registration_open'],
      );
}
