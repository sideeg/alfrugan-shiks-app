// Path: lib/presentation/screens/logs/logs_screen.dart

import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart' as intl;
import '../../providers/logs_details_provider.dart';
import '../../providers/auth_provider.dart';
import '../dashboard/widgets/student_selector_sheet.dart';
import 'widgets/enhanced_log_sheet.dart';

// ─── Palette (matches rest of app) ───────────────────────────────────────────
const _gold = Color(0xFFD4A843);
const _goldLight = Color(0xFFF0CC6E);
const _navy = Color(0xFF0B1120);
const _navyMid = Color(0xFF111D35);
const _cream = Color(0xFFF5EDD8);
const _lightBg = Color(0xFFF2F4F8);
const _lightCard = Color(0xFFFFFFFF);
const _hifzClr = Color(0xFF2E7D32);
const _revClr = Color(0xFF1565C0);

class LogsScreen extends ConsumerStatefulWidget {
  const LogsScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<LogsScreen> createState() => _LogsScreenState();
}

class _LogsScreenState extends ConsumerState<LogsScreen>
    with SingleTickerProviderStateMixin {
  late final TextEditingController _searchCtrl;
  late final ScrollController _scrollCtrl;
  bool _searchVisible = false;

  @override
  void initState() {
    super.initState();
    _searchCtrl = TextEditingController();
    _scrollCtrl = ScrollController()
      ..addListener(() {
        // Load more when near bottom
        if (_scrollCtrl.position.pixels >=
            _scrollCtrl.position.maxScrollExtent - 200) {
          ref.read(logsDetailsListProvider.notifier).loadMore();
        }
      });
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    _scrollCtrl.dispose();
    super.dispose();
  }

  void _showLogSheet(LogType type) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => StudentSelectorSheet(logType: type),
    );
  }

  Future<void> _pickDateRange(bool isDark) async {
    final now = DateTime.now();
    final picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(now.year - 2),
      lastDate: now,
      locale: const Locale('ar'),
      builder: (ctx, child) => Theme(
        data: Theme.of(ctx).copyWith(
          colorScheme: ColorScheme.dark(
            primary: _gold,
            onPrimary: Colors.white,
            surface: isDark ? _navyMid : _lightCard,
            onSurface: isDark ? _cream : _navy,
          ),
        ),
        child: child!,
      ),
    );
    if (picked != null) {
      ref.read(logsDetailsFilterProvider.notifier).setDateRange(
            intl.DateFormat('yyyy-MM-dd').format(picked.start),
            intl.DateFormat('yyyy-MM-dd').format(picked.end),
          );
      ref.read(logsDetailsListProvider.notifier).loadInitial();
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final filter = ref.watch(logsDetailsFilterProvider);
    final listState = ref.watch(logsDetailsListProvider);
    final summary = ref.read(logsDetailsListProvider.notifier).summary;
    final hasDateFilter = filter.fromDate != null || filter.toDate != null;

    return Scaffold(
      backgroundColor: isDark ? _navy : _lightBg,
      body: SafeArea(
        child: Column(
          children: [
            // ── Top bar ──────────────────────────────────────────
            _TopBar(
              isDark: isDark,
              searchVisible: _searchVisible,
              searchCtrl: _searchCtrl,
              hasDateFilter: hasDateFilter,
              onSearchToggle: () {
                setState(() => _searchVisible = !_searchVisible);
                if (!_searchVisible) {
                  _searchCtrl.clear();
                  ref.read(logsDetailsFilterProvider.notifier).setSearch('');
                  ref.read(logsDetailsListProvider.notifier).loadInitial();
                }
              },
              onSearchChanged: (v) {
                ref.read(logsDetailsFilterProvider.notifier).setSearch(v);
                ref.read(logsDetailsListProvider.notifier).loadInitial();
              },
              onDateTap: () => _pickDateRange(isDark),
              onClearDate: () {
                ref.read(logsDetailsFilterProvider.notifier).clearDateRange();
                ref.read(logsDetailsListProvider.notifier).loadInitial();
              },
            ),

            // ── Summary strip ─────────────────────────────────────
            if (summary != null)
              _SummaryStrip(summary: summary!, isDark: isDark),

            // ── Type filter tabs ──────────────────────────────────
            _TypeTabs(
              selected: filter.type,
              isDark: isDark,
              onChanged: (t) {
                ref.read(logsDetailsFilterProvider.notifier).setType(t);
                ref.read(logsDetailsListProvider.notifier).loadInitial();
              },
            ),

            const SizedBox(height: 4),

            // ── List ──────────────────────────────────────────────
            Expanded(
              child: listState.when(
                loading: () => const Center(
                  child: CircularProgressIndicator(color: _gold),
                ),
                error: (e, _) => _ErrorState(
                  error: e.toString(),
                  isDark: isDark,
                  onRetry: () =>
                      ref.read(logsDetailsListProvider.notifier).loadInitial(),
                ),
                data: (logs) {
                  if (logs.isEmpty) {
                    return _EmptyState(isDark: isDark);
                  }
                  final grouped = _groupByDate(logs);
                  final dateKeys = grouped.keys.toList();

                  return RefreshIndicator(
                    color: _gold,
                    backgroundColor: isDark ? _navyMid : _lightCard,
                    onRefresh: () =>
                        ref.read(logsDetailsListProvider.notifier).refresh(),
                    child: ListView.builder(
                      controller: _scrollCtrl,
                      padding: const EdgeInsets.fromLTRB(16, 4, 16, 100),
                      itemCount: dateKeys.length + 1,
                      itemBuilder: (ctx, i) {
                        if (i == dateKeys.length) {
                          // Load-more indicator at bottom
                          return ref
                                  .read(logsDetailsListProvider.notifier)
                                  .hasMore
                              ? const Padding(
                                  padding: EdgeInsets.symmetric(vertical: 16),
                                  child: Center(
                                    child: CircularProgressIndicator(
                                        color: _gold, strokeWidth: 2),
                                  ),
                                )
                              : const SizedBox(height: 16);
                        }
                        final dateKey = dateKeys[i];
                        final dayLogs = grouped[dateKey]!;
                        return _DateGroup(
                          dateLabel: dateKey,
                          logs: dayLogs,
                          isDark: isDark,
                        );
                      },
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),

      // ── FAB ─────────────────────────────────────────────────────
      floatingActionButton: _LogFab(isDark: isDark, onLog: _showLogSheet),
    );
  }

  /// Group logs by formatted date label (today/yesterday/actual date)
  Map<String, List<LogDetailEntry>> _groupByDate(List<LogDetailEntry> logs) {
    final map = <String, List<LogDetailEntry>>{};
    final today = DateTime.now();
    final yesterday = today.subtract(const Duration(days: 1));

    for (final log in logs) {
      DateTime? d;
      try {
        d = DateTime.parse(log.date);
      } catch (_) {
        d = null;
      }

      String label;
      if (d == null) {
        label = log.date;
      } else if (_sameDay(d, today)) {
        label = 'اليوم';
      } else if (_sameDay(d, yesterday)) {
        label = 'أمس';
      } else {
        label = intl.DateFormat('EEEE، d MMMM yyyy', 'ar').format(d);
      }

      map.putIfAbsent(label, () => []).add(log);
    }
    return map;
  }

  bool _sameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;
}

// ─────────────────────────────────────────────────────────────────────────────
// Top bar
// ─────────────────────────────────────────────────────────────────────────────
class _TopBar extends StatelessWidget {
  final bool isDark;
  final bool searchVisible;
  final TextEditingController searchCtrl;
  final bool hasDateFilter;
  final VoidCallback onSearchToggle;
  final ValueChanged<String> onSearchChanged;
  final VoidCallback onDateTap;
  final VoidCallback onClearDate;

  const _TopBar({
    required this.isDark,
    required this.searchVisible,
    required this.searchCtrl,
    required this.hasDateFilter,
    required this.onSearchToggle,
    required this.onSearchChanged,
    required this.onDateTap,
    required this.onClearDate,
  });

  @override
  Widget build(BuildContext context) {
    final fg = isDark ? _cream : _navy;

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 8),
      child: Column(
        children: [
          Row(
            textDirection: TextDirection.rtl,
            children: [
              // Back
              _IconBtn(
                icon: Icons.arrow_back_ios_new_rounded,
                isDark: isDark,
                onTap: () => context.go('/dashboard'),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  'سجل الجلسات',
                  style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                    color: fg,
                  ),
                ),
              ),
              // Date filter
              _IconBtn(
                icon: Icons.calendar_month_rounded,
                isDark: isDark,
                active: hasDateFilter,
                onTap: onDateTap,
              ),
              const SizedBox(width: 6),
              // Search toggle
              _IconBtn(
                icon:
                    searchVisible ? Icons.close_rounded : Icons.search_rounded,
                isDark: isDark,
                active: searchVisible,
                onTap: onSearchToggle,
              ),
            ],
          ),
          // Search field (animated)
          AnimatedSize(
            duration: const Duration(milliseconds: 250),
            curve: Curves.easeOutCubic,
            child: searchVisible
                ? Padding(
                    padding: const EdgeInsets.only(top: 10),
                    child: _SearchField(
                      controller: searchCtrl,
                      isDark: isDark,
                      onChanged: onSearchChanged,
                    ),
                  )
                : const SizedBox.shrink(),
          ),
          // Date filter badge
          if (hasDateFilter)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Row(
                textDirection: TextDirection.rtl,
                children: [
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                    decoration: BoxDecoration(
                      color: _gold.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: _gold.withValues(alpha: 0.3)),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.date_range_rounded,
                            size: 14, color: _gold),
                        const SizedBox(width: 6),
                        const Text('فلتر التاريخ مفعّل',
                            style: TextStyle(
                                fontSize: 12,
                                color: _gold,
                                fontWeight: FontWeight.w600)),
                        const SizedBox(width: 8),
                        GestureDetector(
                          onTap: onClearDate,
                          child: const Icon(Icons.close_rounded,
                              size: 14, color: _gold),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Summary strip
// ─────────────────────────────────────────────────────────────────────────────
class _SummaryStrip extends StatelessWidget {
  final LogSummaryEntity summary;
  final bool isDark;

  const _SummaryStrip({required this.summary, required this.isDark});

  @override
  Widget build(BuildContext context) {
    final cardBg = isDark ? _navyMid : _lightCard;

    return Container(
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 8),
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 12),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _gold.withValues(alpha: 0.2)),
        boxShadow: [
          BoxShadow(
            color: isDark
                ? Colors.black.withValues(alpha: 0.2)
                : Colors.black.withValues(alpha: 0.04),
            blurRadius: 12,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
              child: _SumCell(
                  label: 'هذا الأسبوع',
                  value: summary.totalThisWeek.toString(),
                  sub:
                      '${summary.hifzThisWeek} حفظ · ${summary.reviewThisWeek} مراجعة',
                  color: _gold,
                  isDark: isDark)),
          Container(width: 1, height: 40, color: _gold.withValues(alpha: 0.15)),
          Expanded(
              child: _SumCell(
                  label: 'هذا الشهر',
                  value: summary.totalThisMonth.toString(),
                  sub:
                      '${summary.hifzThisMonth} حفظ · ${summary.reviewThisMonth} مراجعة',
                  color: const Color(0xFF5C6BC0),
                  isDark: isDark)),
        ],
      ),
    );
  }
}

class _SumCell extends StatelessWidget {
  final String label;
  final String value;
  final String sub;
  final Color color;
  final bool isDark;

  const _SumCell(
      {required this.label,
      required this.value,
      required this.sub,
      required this.color,
      required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(label,
            style: TextStyle(
                fontSize: 11,
                color: isDark ? Colors.grey[400] : Colors.grey[500],
                fontWeight: FontWeight.w500),
            textDirection: TextDirection.rtl),
        const SizedBox(height: 4),
        Text(value,
            style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: color,
                height: 1.0)),
        const SizedBox(height: 3),
        Text(sub,
            style: TextStyle(
                fontSize: 11,
                color: isDark ? Colors.grey[500] : Colors.grey[500]),
            textDirection: TextDirection.rtl),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Type tabs
// ─────────────────────────────────────────────────────────────────────────────
class _TypeTabs extends StatelessWidget {
  final String selected;
  final bool isDark;
  final ValueChanged<String> onChanged;

  const _TypeTabs({
    required this.selected,
    required this.isDark,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final tabs = [
      ('all', 'الكل', Icons.list_alt_rounded),
      ('hifz', 'حفظ', Icons.auto_stories_rounded),
      ('review', 'مراجعة', Icons.replay_circle_filled_rounded),
    ];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          color: isDark ? _navyMid : _lightCard,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: _gold.withValues(alpha: 0.15)),
        ),
        child: Row(
          children: tabs.map((t) {
            final isActive = selected == t.$1;
            Color activeColor = t.$1 == 'hifz'
                ? _hifzClr
                : t.$1 == 'review'
                    ? _revClr
                    : _gold;
            return Expanded(
              child: GestureDetector(
                onTap: () => onChanged(t.$1),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: const EdgeInsets.symmetric(vertical: 9),
                  decoration: BoxDecoration(
                    color: isActive
                        ? activeColor.withValues(alpha: isDark ? 0.25 : 0.12)
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(10),
                    border: isActive
                        ? Border.all(color: activeColor.withValues(alpha: 0.4))
                        : Border.all(color: Colors.transparent),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(t.$3,
                          size: 15,
                          color: isActive
                              ? activeColor
                              : (isDark
                                  ? Colors.grey[500]!
                                  : Colors.grey[500]!)),
                      const SizedBox(width: 5),
                      Text(t.$2,
                          style: TextStyle(
                              fontSize: 13,
                              fontWeight:
                                  isActive ? FontWeight.bold : FontWeight.w500,
                              color: isActive
                                  ? activeColor
                                  : (isDark
                                      ? Colors.grey[400]!
                                      : Colors.grey[500]!))),
                    ],
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Date group header + cards
// ─────────────────────────────────────────────────────────────────────────────
class _DateGroup extends StatelessWidget {
  final String dateLabel;
  final List<LogDetailEntry> logs;
  final bool isDark;

  const _DateGroup({
    required this.dateLabel,
    required this.logs,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        // Date divider
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 14),
          child: Row(
            textDirection: TextDirection.rtl,
            children: [
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: BoxDecoration(
                  color: _gold.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: _gold.withValues(alpha: 0.25)),
                ),
                child: Text(dateLabel,
                    style: const TextStyle(
                        fontSize: 12,
                        color: _gold,
                        fontWeight: FontWeight.w600)),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Container(
                  height: 1,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        _gold.withValues(alpha: 0.3),
                        Colors.transparent,
                      ],
                      // textDirection: TextDirection.rtl,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        // Cards
        ...logs.map((log) => _LogCard(log: log, isDark: isDark)),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Single log card
// ─────────────────────────────────────────────────────────────────────────────
class _LogCard extends StatelessWidget {
  final LogDetailEntry log;
  final bool isDark;

  const _LogCard({required this.log, required this.isDark});

  @override
  Widget build(BuildContext context) {
    final color = log.isHifz ? _hifzClr : _revClr;
    final cardBg = isDark ? _navyMid : _lightCard;
    final textClr = isDark ? _cream : _navy;
    final subClr = isDark ? Colors.grey[400]! : Colors.grey[600]!;

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: color.withValues(alpha: 0.18)),
        boxShadow: [
          BoxShadow(
            color: isDark
                ? Colors.black.withValues(alpha: 0.2)
                : color.withValues(alpha: 0.06),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(14),
          onTap: () {}, // TODO: open detail sheet
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              textDirection: TextDirection.rtl,
              children: [
                // Type icon
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    log.isHifz
                        ? Icons.auto_stories_rounded
                        : Icons.replay_circle_filled_rounded,
                    color: color,
                    size: 22,
                  ),
                ),
                const SizedBox(width: 12),
                // Info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      // Student + type badge row
                      Row(
                        textDirection: TextDirection.rtl,
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          // Type pill
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              color: color.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              log.isHifz ? 'حفظ' : 'مراجعة',
                              style: TextStyle(
                                  fontSize: 10,
                                  color: color,
                                  fontWeight: FontWeight.bold),
                            ),
                          ),
                          // Student name
                          Flexible(
                            child: Text(log.studentName,
                                style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14,
                                    color: textClr),
                                textDirection: TextDirection.rtl,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      // Surah + ayah range
                      Text(
                        '${log.surahName}  ·  آية ${log.fromAyah} – ${log.toAyah}',
                        style: TextStyle(fontSize: 13, color: subClr),
                        textDirection: TextDirection.rtl,
                      ),
                      const SizedBox(height: 2),
                      // Course
                      Text(log.courseName,
                          style: TextStyle(
                              fontSize: 11,
                              color: subClr.withValues(alpha: 0.7)),
                          textDirection: TextDirection.rtl),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// FAB — expandable with hifz/review options
// ─────────────────────────────────────────────────────────────────────────────
class _LogFab extends StatefulWidget {
  final bool isDark;
  final void Function(LogType) onLog;

  const _LogFab({required this.isDark, required this.onLog});

  @override
  State<_LogFab> createState() => _LogFabState();
}

class _LogFabState extends State<_LogFab> with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _rot;
  late final Animation<double> _scale;
  bool _expanded = false;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 250));
    _rot = Tween<double>(begin: 0, end: math.pi / 4)
        .animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeOut));
    _scale = Tween<double>(begin: 0.0, end: 1.0)
        .animate(CurvedAnimation(parent: _ctrl, curve: Curves.elasticOut));
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  void _toggle() {
    setState(() => _expanded = !_expanded);
    _expanded ? _ctrl.forward() : _ctrl.reverse();
  }

  void _tap(LogType type) {
    _toggle();
    widget.onLog(type);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        // Review option
        ScaleTransition(
          scale: _scale,
          child: _FabOption(
            label: 'تسجيل مراجعة',
            icon: Icons.replay_circle_filled_rounded,
            color: _revClr,
            isDark: widget.isDark,
            onTap: () => _tap(LogType.review),
          ),
        ),
        const SizedBox(height: 8),
        // Hifz option
        ScaleTransition(
          scale: _scale,
          child: _FabOption(
            label: 'تسجيل حفظ',
            icon: Icons.auto_stories_rounded,
            color: _hifzClr,
            isDark: widget.isDark,
            onTap: () => _tap(LogType.hifz),
          ),
        ),
        const SizedBox(height: 12),
        // Main FAB
        GestureDetector(
          onTap: _toggle,
          child: Container(
            width: 58,
            height: 58,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [_gold, Color(0xFFB8860B)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: _gold.withValues(alpha: 0.45),
                  blurRadius: 16,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: AnimatedBuilder(
              animation: _rot,
              builder: (_, __) => Transform.rotate(
                angle: _rot.value,
                child: const Icon(Icons.add_rounded,
                    color: Colors.white, size: 28),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _FabOption extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color color;
  final bool isDark;
  final VoidCallback onTap;

  const _FabOption({
    required this.label,
    required this.icon,
    required this.color,
    required this.isDark,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Label pill
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            decoration: BoxDecoration(
              color: isDark ? _navyMid : _lightCard,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: color.withValues(alpha: 0.25)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.1),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Text(label,
                style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: isDark ? _cream : _navy)),
          ),
          const SizedBox(width: 10),
          // Icon circle
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: color.withValues(alpha: 0.4),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Icon(icon, color: Colors.white, size: 20),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Search field
// ─────────────────────────────────────────────────────────────────────────────
class _SearchField extends StatelessWidget {
  final TextEditingController controller;
  final bool isDark;
  final ValueChanged<String> onChanged;

  const _SearchField(
      {required this.controller,
      required this.isDark,
      required this.onChanged});

  @override
  Widget build(BuildContext context) {
    final fill = isDark ? _navyMid : _lightCard;
    final border = _gold.withValues(alpha: 0.25);

    return TextField(
      controller: controller,
      onChanged: onChanged,
      textDirection: TextDirection.rtl,
      style: TextStyle(color: isDark ? _cream : _navy, fontSize: 14),
      decoration: InputDecoration(
        hintText: 'ابحث بالاسم أو السورة...',
        hintStyle: TextStyle(
            color: isDark ? Colors.grey[500] : Colors.grey[400], fontSize: 13),
        prefixIcon: const Icon(Icons.search_rounded, color: _gold, size: 20),
        filled: true,
        fillColor: fill,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: border)),
        enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: border)),
        focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: _gold, width: 1.5)),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Icon button helper
// ─────────────────────────────────────────────────────────────────────────────
class _IconBtn extends StatelessWidget {
  final IconData icon;
  final bool isDark;
  final bool active;
  final VoidCallback onTap;

  const _IconBtn({
    required this.icon,
    required this.isDark,
    required this.onTap,
    this.active = false,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: active
              ? _gold.withValues(alpha: isDark ? 0.2 : 0.12)
              : (isDark ? _navyMid : _lightCard),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: active
                ? _gold.withValues(alpha: 0.45)
                : _gold.withValues(alpha: 0.15),
          ),
        ),
        child: Icon(icon,
            size: 17, color: active ? _gold : (isDark ? _cream : _navy)),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Empty + Error states
// ─────────────────────────────────────────────────────────────────────────────
class _EmptyState extends StatelessWidget {
  final bool isDark;
  const _EmptyState({required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                color: _gold.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.inbox_rounded,
                  size: 34, color: _gold.withValues(alpha: 0.7)),
            ),
            const SizedBox(height: 16),
            Text('لا توجد سجلات',
                style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: isDark ? _cream : _navy),
                textDirection: TextDirection.rtl),
            const SizedBox(height: 6),
            Text('جرّب تغيير الفلتر أو تسجيل جلسة جديدة',
                style: TextStyle(
                    fontSize: 13,
                    color: isDark ? Colors.grey[400] : Colors.grey[500]),
                textDirection: TextDirection.rtl,
                textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }
}

class _ErrorState extends StatelessWidget {
  final String error;
  final bool isDark;
  final VoidCallback onRetry;

  const _ErrorState(
      {required this.error, required this.isDark, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                color: const Color(0xFFE53935).withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.error_outline_rounded,
                  size: 32, color: Color(0xFFE53935)),
            ),
            const SizedBox(height: 14),
            Text('خطأ في التحميل',
                style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: isDark ? _cream : _navy),
                textDirection: TextDirection.rtl),
            const SizedBox(height: 6),
            Text(error,
                style: TextStyle(
                    fontSize: 12,
                    color: isDark ? Colors.grey[400] : Colors.grey[600]),
                textAlign: TextAlign.center),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh_rounded, size: 16),
              label: const Text('إعادة المحاولة'),
              style: ElevatedButton.styleFrom(
                backgroundColor: _gold,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
