// lib/presentation/providers/logs_provider.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:quran_sheikh_app/config/dependency_injection.dart';
import 'package:quran_sheikh_app/core/network/api_client.dart';
import 'package:quran_sheikh_app/data/datasources/local/auth_local_datasource.dart';
import 'package:quran_sheikh_app/domain/entities/hifz_log_entity.dart';
import 'package:quran_sheikh_app/domain/entities/review_log_entity.dart';
import 'package:quran_sheikh_app/presentation/providers/auth_provider.dart';

/// Parameters object
class HifzLogsParams {
  final int studentId;
  final int courseId;
  HifzLogsParams({required this.studentId, required this.courseId});

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is HifzLogsParams &&
          runtimeType == other.runtimeType &&
          studentId == other.studentId &&
          courseId == other.courseId;

  @override
  int get hashCode => studentId.hashCode ^ courseId.hashCode;
}

/// 1️⃣ Hifz Logs Provider
final hifzLogsProvider = FutureProvider.family
    .autoDispose<List<HifzLogEntity>, HifzLogsParams>((ref, params) async {
  final api = getIt<ApiClient>();

  // Get sheikh ID from auth provider once, don't watch it
  final authState = ref.read(authProvider);
  final sheikhId = authState.user?.id;

  if (sheikhId == null) {
    throw Exception('Sheikh not authenticated');
  }

  final resp = await api.get('/sheikh/hifz-logs', queryParameters: {
    'sheikh_id': sheikhId,
    'student_id': params.studentId,
    'course_id': params.courseId,
  });

  final List data = resp.data['data'] ?? [];
  return data.map((e) => HifzLogEntity.fromJson(e)).toList();
});

/// 2️⃣ Review Logs Provider
final reviewLogsProvider = FutureProvider.family
    .autoDispose<List<ReviewLogEntity>, HifzLogsParams>((ref, params) async {
  final api = getIt<ApiClient>();

  final authState = ref.read(authProvider);
  final sheikhId = authState.user?.id;

  if (sheikhId == null) {
    throw Exception('Sheikh not authenticated');
  }

  final resp = await api.get('/sheikh/review-logs', queryParameters: {
    'sheikh_id': sheikhId,
    'student_id': params.studentId,
    'course_id': params.courseId,
  });

  final List data = resp.data['data'] ?? [];
  return data.map((e) => ReviewLogEntity.fromJson(e)).toList();
});

/// 3️⃣ CRUD Helper Functions

// Hifz Log CRUD
Future<void> addHifzLog(WidgetRef ref, Map<String, dynamic> body) async {
  final api = getIt<ApiClient>();
  await api.post('/sheikh/hifz-logs', data: body);

  final params = HifzLogsParams(
      studentId: body['student_id'], courseId: body['course_id']);
  ref.invalidate(hifzLogsProvider(params));
}

Future<void> updateHifzLog(
    WidgetRef ref, int logId, Map<String, dynamic> body) async {
  final api = getIt<ApiClient>();
  await api.put('/sheikh/hifz-logs/$logId', data: body);

  final params = HifzLogsParams(
      studentId: body['student_id'], courseId: body['course_id']);
  ref.invalidate(hifzLogsProvider(params));
}

Future<void> deleteHifzLog(WidgetRef ref, int logId,
    {required int studentId, required int courseId}) async {
  final api = getIt<ApiClient>();
  await api.delete('/sheikh/hifz-logs/$logId',
      data: {'sheikh_id': ref.read(authProvider).user?.id});

  final params = HifzLogsParams(studentId: studentId, courseId: courseId);
  ref.invalidate(hifzLogsProvider(params));
}

// Review Log CRUD
Future<void> addReviewLog(WidgetRef ref, Map<String, dynamic> body) async {
  final api = getIt<ApiClient>();
  await api.post('/sheikh/review-logs', data: body);

  final params = HifzLogsParams(
      studentId: body['student_id'], courseId: body['course_id']);
  ref.invalidate(reviewLogsProvider(params));
}

Future<void> updateReviewLog(
    WidgetRef ref, int logId, Map<String, dynamic> body) async {
  final api = getIt<ApiClient>();
  await api.put('/sheikh/review-logs/$logId', data: body);

  final params = HifzLogsParams(
      studentId: body['student_id'], courseId: body['course_id']);
  ref.invalidate(reviewLogsProvider(params));
}

Future<void> deleteReviewLog(WidgetRef ref, int logId,
    {required int studentId, required int courseId}) async {
  final api = getIt<ApiClient>();
  await api.delete('/sheikh/review-logs/$logId',
      data: {'sheikh_id': ref.read(authProvider).user?.id});

  final params = HifzLogsParams(studentId: studentId, courseId: courseId);
  ref.invalidate(reviewLogsProvider(params));
}
