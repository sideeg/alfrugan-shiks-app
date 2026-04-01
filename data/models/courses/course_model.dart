// Path: lib/data/models/courses/course_model.dart
import '../../../domain/entities/courses/course_entity.dart';

class CourseModel extends CourseEntity {
  CourseModel({
    required int id,
    required String name,
    required String description,
    required DateTime startDate,
    required DateTime endDate,
    required String type,
    required String typeDisplayName,
    String? imageUrl,
    required int maxStudents,
    required int currentStudents,
    required bool isActive,
    required bool isRegistrationOpen,
    String? scheduleDetails,
    required int groupsCount,
    required double enrollmentPercentage,
    required int availableSlots,
    required bool canEnroll,
    String? mosque,
    required int createdBy,
    required DateTime createdAt,
    required DateTime updatedAt,
  }) : super(
          id: id,
          name: name,
          description: description,
          startDate: startDate.toString(),
          endDate: endDate.toString(),
          typeDisplayName: typeDisplayName,
          maxStudents: maxStudents,
          currentStudents: currentStudents,
          isRegistrationOpen: isRegistrationOpen,
        );

  factory CourseModel.fromJson(Map<String, dynamic> json) {
    return CourseModel(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      description: json['description'] ?? '',
      startDate: DateTime.parse(
          json['start_date'] ?? DateTime.now().toIso8601String()),
      endDate:
          DateTime.parse(json['end_date'] ?? DateTime.now().toIso8601String()),
      type: json['type'] ?? '',
      typeDisplayName: json['type_display_name'] ?? '',
      imageUrl: json['image_url'],
      maxStudents: json['max_students'] ?? 0,
      currentStudents: json['current_students'] ?? 0,
      isActive: json['is_active'] ?? false,
      isRegistrationOpen: json['is_registration_open'] ?? false,
      scheduleDetails: json['schedule_details'],
      groupsCount: json['groups_count'] ?? 0,
      enrollmentPercentage: (json['enrollment_percentage'] ?? 0.0).toDouble(),
      availableSlots: json['available_slots'] ?? 0,
      canEnroll: json['can_enroll'] ?? false,
      mosque: json['mosque'],
      createdBy: json['created_by'] ?? 0,
      createdAt: DateTime.parse(
          json['created_at'] ?? DateTime.now().toIso8601String()),
      updatedAt: DateTime.parse(
          json['updated_at'] ?? DateTime.now().toIso8601String()),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'type_display_name': typeDisplayName,
      'max_students': maxStudents,
      'current_students': currentStudents,
      'is_registration_open': isRegistrationOpen,
    };
  }
}
