// lib/domain/entities/course_group_entity.dart
class CourseGroupEntity {
  final int id;
  final String name;
  final String scheduleDetails;
  final int maxStudents;
  final int currentStudents;
  final List<Student> students;

  CourseGroupEntity({
    required this.id,
    required this.name,
    required this.scheduleDetails,
    required this.maxStudents,
    required this.currentStudents,
    required this.students,
  });

  factory CourseGroupEntity.fromJson(Map<String, dynamic> json) =>
      CourseGroupEntity(
        id: json['id'],
        name: json['name'] ?? '',
        scheduleDetails: json['schedule_details'] ?? '',
        maxStudents: json['max_students'],
        currentStudents: json['current_students'],
        students: (json['students'] as List? ?? [])
            .map((e) => Student.fromJson(e))
            .toList(),
      );
}

class Student {
  final int id;
  final String name;
  final String email;
  Student({required this.id, required this.name, required this.email});
  factory Student.fromJson(Map<String, dynamic> json) =>
      Student(id: json['id'], name: json['name'], email: json['email']);
}
