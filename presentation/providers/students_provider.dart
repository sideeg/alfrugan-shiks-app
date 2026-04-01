// lib/presentation/providers/students_provider.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:quran_sheikh_app/config/dependency_injection.dart';
import 'package:quran_sheikh_app/core/network/api_client.dart';
import 'package:quran_sheikh_app/domain/entities/student_entity.dart';
import 'package:quran_sheikh_app/presentation/providers/auth_provider.dart';

/// Students data response
class StudentsResponse {
  final List<StudentEntity> students;
  final int totalStudents;
  final int totalGroups;

  StudentsResponse({
    required this.students,
    required this.totalStudents,
    required this.totalGroups,
  });

  factory StudentsResponse.fromJson(Map<String, dynamic> json) {
    final data = json['data'];
    final List studentsJson = data['students'] ?? [];

    return StudentsResponse(
      students: studentsJson.map((e) => StudentEntity.fromJson(e)).toList(),
      totalStudents: data['total_students'] ?? 0,
      totalGroups: data['total_groups'] ?? 0,
    );
  }
}

/// Students provider
final studentsProvider =
    FutureProvider.autoDispose<StudentsResponse>((ref) async {
  final api = getIt<ApiClient>();

  // Ensure sheikh is authenticated
  final authState = ref.read(authProvider);
  final sheikhId = authState.user?.id;

  if (sheikhId == null) {
    throw Exception('Sheikh not authenticated');
  }

  final resp = await api.get('/sheikh/students');
  return StudentsResponse.fromJson(resp.data);
});

/// Search functionality
final searchQueryProvider = StateProvider<String>((ref) => '');

/// Filtered students based on search
final filteredStudentsProvider = Provider<List<StudentEntity>>((ref) {
  final studentsAsync = ref.watch(studentsProvider);
  final searchQuery = ref.watch(searchQueryProvider).toLowerCase();

  return studentsAsync.when(
    data: (response) {
      if (searchQuery.isEmpty) {
        return response.students;
      }

      return response.students.where((student) {
        return student.name.toLowerCase().contains(searchQuery) ||
            student.group.name.toLowerCase().contains(searchQuery) ||
            student.course.name.toLowerCase().contains(searchQuery);
      }).toList();
    },
    loading: () => [],
    error: (_, __) => [],
  );
});

/// Group students by course
final studentsGroupedByCourseProvider =
    Provider<Map<String, List<StudentEntity>>>((ref) {
  final filteredStudents = ref.watch(filteredStudentsProvider);

  Map<String, List<StudentEntity>> grouped = {};

  for (var student in filteredStudents) {
    final courseName = student.course.name;
    if (grouped[courseName] == null) {
      grouped[courseName] = [];
    }
    grouped[courseName]!.add(student);
  }

  return grouped;
});
