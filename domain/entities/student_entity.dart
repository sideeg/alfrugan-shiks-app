// lib/domain/entities/student_entity.dart
class StudentEntity {
  final int id;
  final String name;
  final String email;
  final String? phone;
  final DateTime createdAt;
  final GroupInfo group;
  final CourseInfo course;

  StudentEntity({
    required this.id,
    required this.name,
    required this.email,
    this.phone,
    required this.createdAt,
    required this.group,
    required this.course,
  });

  factory StudentEntity.fromJson(Map<String, dynamic> json) {
    return StudentEntity(
      id: json['id'],
      name: json['name'],
      email: json['email'],
      phone: json['phone'],
      createdAt: DateTime.parse(json['created_at']),
      group: GroupInfo.fromJson(json['group']),
      course: CourseInfo.fromJson(json['course']),
    );
  }
}

class GroupInfo {
  final int id;
  final String name;
  final String? description;

  GroupInfo({
    required this.id,
    required this.name,
    this.description,
  });

  factory GroupInfo.fromJson(Map<String, dynamic> json) {
    return GroupInfo(
      id: json['id'],
      name: json['name'],
      description: json['description'],
    );
  }
}

class CourseInfo {
  final int id;
  final String name;
  final String? description;

  CourseInfo({
    required this.id,
    required this.name,
    this.description,
  });

  factory CourseInfo.fromJson(Map<String, dynamic> json) {
    return CourseInfo(
      id: json['id'],
      name: json['name'],
      description: json['description'],
    );
  }
}
