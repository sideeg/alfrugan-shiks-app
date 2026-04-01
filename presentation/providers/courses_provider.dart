// lib/presentation/providers/courses_provider.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dio/dio.dart';
import 'package:quran_sheikh_app/core/network/api_client.dart';
import 'package:get_it/get_it.dart';
import '../../domain/entities/courses/course_entity.dart';

final coursesProvider = FutureProvider<List<CourseEntity>>((ref) async {
  ApiClient apiClient = GetIt.instance<ApiClient>();
  final resp = await apiClient.get('/sheikh/courses');
  final List data = resp.data['data'] as List;
  return data.map((e) => CourseEntity.fromJson(e)).toList();
});
