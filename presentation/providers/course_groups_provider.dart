// lib/presentation/providers/course_groups_provider.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:get_it/get_it.dart';
import '../../../config/dependency_injection.dart';
import '../../../core/network/api_client.dart';
import '../../../domain/entities/groups/course_group_entity.dart';

final courseGroupsProvider =
    FutureProvider.family<List<CourseGroupEntity>, int>((ref, courseId) async {
  final api = GetIt.instance<ApiClient>();
  try {
    final resp = await api.get('/sheikh/courses/$courseId/groups');
    final List data = resp.data['data'] as List;
    return data.map((e) => CourseGroupEntity.fromJson(e)).toList();
  } catch (_) {
    return []; // server returns success:false when empty
  }
});
