// Path: lib/presentation/providers/logs_details_provider.dart
//
// This is a SEPARATE file — it does NOT modify your existing logs_provider.dart
// It powers the /logs screen (full paginated log history with filters)

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:quran_sheikh_app/config/dependency_injection.dart';
import 'package:quran_sheikh_app/core/network/api_client.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Entities
// ─────────────────────────────────────────────────────────────────────────────
class LogSummaryEntity {
  final int hifzThisWeek;
  final int hifzThisMonth;
  final int reviewThisWeek;
  final int reviewThisMonth;
  final int totalThisWeek;
  final int totalThisMonth;

  const LogSummaryEntity({
    required this.hifzThisWeek,
    required this.hifzThisMonth,
    required this.reviewThisWeek,
    required this.reviewThisMonth,
    required this.totalThisWeek,
    required this.totalThisMonth,
  });

  factory LogSummaryEntity.fromJson(Map<String, dynamic> j) => LogSummaryEntity(
        hifzThisWeek: j['hifz_this_week'] ?? 0,
        hifzThisMonth: j['hifz_this_month'] ?? 0,
        reviewThisWeek: j['review_this_week'] ?? 0,
        reviewThisMonth: j['review_this_month'] ?? 0,
        totalThisWeek: j['total_this_week'] ?? 0,
        totalThisMonth: j['total_this_month'] ?? 0,
      );
}

class LogDetailEntry {
  final int id;
  final String type; // 'hifz' | 'review'
  final int studentId;
  final String studentName;
  final String surahName;
  final int fromAyah;
  final int toAyah;
  final String date;
  final int courseId;
  final String courseName;
  final DateTime createdAt;

  const LogDetailEntry({
    required this.id,
    required this.type,
    required this.studentId,
    required this.studentName,
    required this.surahName,
    required this.fromAyah,
    required this.toAyah,
    required this.date,
    required this.courseId,
    required this.courseName,
    required this.createdAt,
  });

  bool get isHifz => type == 'hifz';

  factory LogDetailEntry.fromJson(Map<String, dynamic> j) => LogDetailEntry(
        id: j['id'] ?? 0,
        type: j['type'] ?? 'hifz',
        studentId: j['student_id'] ?? 0,
        studentName: j['student_name'] ?? '',
        surahName: j['surah_name'] ?? '',
        fromAyah: j['from_ayah'] ?? 0,
        toAyah: j['to_ayah'] ?? 0,
        date: j['date'] ?? '',
        courseId: j['course_id'] ?? 0,
        courseName: j['course_name'] ?? '',
        createdAt: DateTime.tryParse(j['created_at'] ?? '') ?? DateTime.now(),
      );
}

// ─────────────────────────────────────────────────────────────────────────────
// Filter state
// ─────────────────────────────────────────────────────────────────────────────
class LogsDetailsFilter {
  final String type; // 'all' | 'hifz' | 'review'
  final String search;
  final String? fromDate; // yyyy-MM-dd
  final String? toDate; // yyyy-MM-dd
  final int page;

  const LogsDetailsFilter({
    this.type = 'all',
    this.search = '',
    this.fromDate,
    this.toDate,
    this.page = 1,
  });

  bool get hasDateFilter => fromDate != null || toDate != null;

  LogsDetailsFilter copyWith({
    String? type,
    String? search,
    String? fromDate,
    String? toDate,
    int? page,
  }) =>
      LogsDetailsFilter(
        type: type ?? this.type,
        search: search ?? this.search,
        fromDate: fromDate ?? this.fromDate,
        toDate: toDate ?? this.toDate,
        page: page ?? this.page,
      );

  LogsDetailsFilter resetPage() => copyWith(page: 1);
  LogsDetailsFilter clearDate() =>
      LogsDetailsFilter(type: type, search: search, page: 1);

  Map<String, dynamic> toQueryParams() => {
        'type': type,
        if (search.isNotEmpty) 'search': search,
        if (fromDate != null) 'from_date': fromDate,
        if (toDate != null) 'to_date': toDate,
        'page': page,
        'per_page': 20,
      };
}

// ─────────────────────────────────────────────────────────────────────────────
// Filter notifier
// ─────────────────────────────────────────────────────────────────────────────
final logsDetailsFilterProvider =
    StateNotifierProvider<LogsDetailsFilterNotifier, LogsDetailsFilter>(
  (_) => LogsDetailsFilterNotifier(),
);

class LogsDetailsFilterNotifier extends StateNotifier<LogsDetailsFilter> {
  LogsDetailsFilterNotifier() : super(const LogsDetailsFilter());

  void setType(String type) => state = state.copyWith(type: type).resetPage();

  void setSearch(String search) =>
      state = state.copyWith(search: search).resetPage();

  void setDateRange(String from, String to) =>
      state = state.copyWith(fromDate: from, toDate: to).resetPage();

  void clearDateRange() => state = state.clearDate();

  void reset() => state = const LogsDetailsFilter();
}

// ─────────────────────────────────────────────────────────────────────────────
// Paginated list notifier (supports load-more)
// ─────────────────────────────────────────────────────────────────────────────
final logsDetailsListProvider = StateNotifierProvider.autoDispose<
    LogsDetailsListNotifier, AsyncValue<List<LogDetailEntry>>>(
  (ref) => LogsDetailsListNotifier(ref),
);

class LogsDetailsListNotifier
    extends StateNotifier<AsyncValue<List<LogDetailEntry>>> {
  final Ref _ref;

  LogSummaryEntity? summary;
  int _currentPage = 1;
  int _lastPage = 1;
  bool _loading = false;

  LogsDetailsListNotifier(this._ref) : super(const AsyncValue.loading()) {
    loadInitial();
  }

  bool get hasMore => _currentPage < _lastPage;

  Future<void> loadInitial() async {
    state = const AsyncValue.loading();
    _currentPage = 1;
    final filter = _ref.read(logsDetailsFilterProvider).copyWith(page: 1);
    try {
      final result = await _fetch(filter);
      summary = result.summary;
      _lastPage = result.lastPage;
      state = AsyncValue.data(result.logs);
    } catch (e, s) {
      state = AsyncValue.error(e, s);
    }
  }

  Future<void> loadMore() async {
    if (_loading || !hasMore) return;
    _loading = true;
    final next = _currentPage + 1;
    final filter = _ref.read(logsDetailsFilterProvider).copyWith(page: next);
    try {
      final result = await _fetch(filter);
      _currentPage = next;
      _lastPage = result.lastPage;
      final current = state.value ?? [];
      state = AsyncValue.data([...current, ...result.logs]);
    } catch (_) {}
    _loading = false;
  }

  Future<void> refresh() => loadInitial();
}

// ─────────────────────────────────────────────────────────────────────────────
// Internal response wrapper
// ─────────────────────────────────────────────────────────────────────────────
class _LogsPage {
  final LogSummaryEntity summary;
  final List<LogDetailEntry> logs;
  final int lastPage;
  final bool hasMore;

  const _LogsPage({
    required this.summary,
    required this.logs,
    required this.lastPage,
    required this.hasMore,
  });
}

Future<_LogsPage> _fetch(LogsDetailsFilter filter) async {
  final api = getIt<ApiClient>();
  final resp = await api.get(
    '/sheikh/logs/details',
    queryParameters: filter.toQueryParams(),
  );

  final data = resp.data['data'];
  final pagRaw = data['pagination'];

  return _LogsPage(
    summary: LogSummaryEntity.fromJson(data['summary']),
    logs:
        (data['logs'] as List).map((e) => LogDetailEntry.fromJson(e)).toList(),
    lastPage: pagRaw['last_page'] ?? 1,
    hasMore: pagRaw['has_more'] ?? false,
  );
}
