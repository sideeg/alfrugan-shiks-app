// Path: lib/presentation/providers/dashboard_provider.dart

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:quran_sheikh_app/config/dependency_injection.dart';
import 'package:quran_sheikh_app/core/network/api_client.dart';
import 'package:quran_sheikh_app/domain/entities/dashboard/dashboard_entity.dart';
import 'package:quran_sheikh_app/presentation/providers/auth_provider.dart';

/// Dashboard data provider
final dashboardProvider =
    FutureProvider.autoDispose<DashboardEntity>((ref) async {
  final api = getIt<ApiClient>();

  // Ensure sheikh is authenticated
  final authState = ref.read(authProvider);
  final sheikhId = authState.user?.id;

  if (sheikhId == null) {
    throw Exception('Sheikh not authenticated');
  }

  final resp = await api.get('/sheikh/dashboard');
  return DashboardEntity.fromJson(resp.data);
});

/// Manual refresh provider
final dashboardRefreshProvider = StateProvider<int>((ref) => 0);

/// Dashboard provider with manual refresh capability
final dashboardWithRefreshProvider =
    FutureProvider.autoDispose<DashboardEntity>((ref) async {
  // Watch the refresh trigger
  ref.watch(dashboardRefreshProvider);

  final api = getIt<ApiClient>();
  final authState = ref.read(authProvider);
  final sheikhId = authState.user?.id;

  if (sheikhId == null) {
    throw Exception('Sheikh not authenticated');
  }

  final resp = await api.get('/sheikh/dashboard');
  return DashboardEntity.fromJson(resp.data);
});
