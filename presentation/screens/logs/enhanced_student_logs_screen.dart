// Path: lib/presentation/screens/logs/enhanced_student_logs_screen.dart

import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:quran_sheikh_app/domain/entities/hifz_log_entity.dart';
import 'package:quran_sheikh_app/domain/entities/review_log_entity.dart';
import 'package:quran_sheikh_app/presentation/providers/logs_provider.dart';
import 'package:quran_sheikh_app/presentation/screens/logs/widgets/enhanced_log_sheet.dart';

// ─── Palette ──────────────────────────────────────────────────────────────────
const _gold = Color(0xFFD4A843);
const _goldDeep = Color(0xFFB8860B);
const _navy = Color(0xFF0B1120);
const _navyMid = Color(0xFF111D35);
const _navyLight = Color(0xFF1A2A4A);
const _cream = Color(0xFFF5EDD8);
const _lightBg = Color(0xFFF2F4F8);
const _lightCard = Color(0xFFFFFFFF);
const _hifzClr = Color(0xFF2E7D32); // green for hifz
const _revClr = Color(0xFF1565C0); // blue for review

class EnhancedStudentLogsScreen extends ConsumerStatefulWidget {
  final int studentId;
  final int courseId;
  final int groupId;
  final String studentName;

  const EnhancedStudentLogsScreen({
    required this.studentId,
    required this.courseId,
    required this.groupId,
    required this.studentName,
    super.key,
  });

  @override
  ConsumerState<EnhancedStudentLogsScreen> createState() =>
      _EnhancedStudentLogsScreenState();
}

class _EnhancedStudentLogsScreenState
    extends ConsumerState<EnhancedStudentLogsScreen>
    with TickerProviderStateMixin {
  late final TabController _tab;
  late final AnimationController _fabCtrl;
  late final Animation<double> _fabRot;
  bool _fabOpen = false;

  late final HifzLogsParams params;

  @override
  void initState() {
    super.initState();
    _tab = TabController(length: 2, vsync: this)
      ..addListener(() => setState(() {}));
    params = HifzLogsParams(
      studentId: widget.studentId,
      courseId: widget.courseId,
    );
    _fabCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 260));
    _fabRot = Tween<double>(begin: 0, end: 0.375)
        .animate(CurvedAnimation(parent: _fabCtrl, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _tab.dispose();
    _fabCtrl.dispose();
    super.dispose();
  }

  String _initials() {
    final parts = widget.studentName.trim().split(' ');
    if (parts.length >= 2) return '${parts[0][0]}${parts[1][0]}';
    return widget.studentName.isNotEmpty ? widget.studentName[0] : 'ط';
  }

  void _toggleFab() {
    setState(() => _fabOpen = !_fabOpen);
    _fabOpen ? _fabCtrl.forward() : _fabCtrl.reverse();
  }

  void _openSheet(LogType type) {
    _toggleFab();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => EnhancedLogSheet(
        studentId: widget.studentId,
        courseId: widget.courseId, // ✅ FROM widget
        groupId: widget.groupId,
        initialLogType: type,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: Scaffold(
        backgroundColor: isDark ? _navy : _lightBg,
        body: Column(
          children: [
            _TopBar(
              isDark: isDark,
              studentName: widget.studentName,
              initials: _initials(),
              tab: _tab,
            ),
            Expanded(
              child: TabBarView(
                controller: _tab,
                children: [
                  _HifzTab(
                      params: params,
                      isDark: isDark,
                      onAdd: () => _openSheet(LogType.hifz)),
                  _ReviewTab(
                      params: params,
                      isDark: isDark,
                      onAdd: () => _openSheet(LogType.review)),
                ],
              ),
            ),
          ],
        ),
        floatingActionButton: _Fab(
          open: _fabOpen,
          rotation: _fabRot,
          tabIndex: _tab.index,
          onToggle: _toggleFab,
          onHifz: () => _openSheet(LogType.hifz),
          onReview: () => _openSheet(LogType.review),
        ),
      ),
    );
  }
}

// ─── Top bar ──────────────────────────────────────────────────────────────────
class _TopBar extends StatelessWidget {
  final bool isDark;
  final String studentName, initials;
  final TabController tab;

  const _TopBar({
    required this.isDark,
    required this.studentName,
    required this.initials,
    required this.tab,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topRight,
          end: Alignment.bottomLeft,
          colors: [Color(0xFF1A3A6C), _navy],
        ),
      ),
      child: Stack(
        children: [
          // Star watermark
          Positioned(
            right: -30,
            top: -30,
            child: CustomPaint(
              size: const Size(130, 130),
              painter: _StarBg(color: _gold.withValues(alpha: 0.05)),
            ),
          ),
          // Gold bottom accent
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              height: 1,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.centerRight,
                  end: Alignment.centerLeft,
                  colors: [
                    _gold.withValues(alpha: 0.0),
                    _gold.withValues(alpha: 0.4),
                    _gold.withValues(alpha: 0.0),
                  ],
                ),
              ),
            ),
          ),
          SafeArea(
            bottom: false,
            child: Column(
              children: [
                // Nav row
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
                  child: Row(
                    textDirection: TextDirection.rtl,
                    children: [
                      GestureDetector(
                        onTap: () => context.pop(),
                        child: Container(
                          width: 36,
                          height: 36,
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                                color: Colors.white.withValues(alpha: 0.2)),
                          ),
                          child: const Icon(Icons.arrow_back_ios_new_rounded,
                              size: 14, color: Colors.white),
                        ),
                      ),
                      const SizedBox(width: 12),
                      // Student avatar + name
                      Expanded(
                        child: Row(
                          textDirection: TextDirection.rtl,
                          children: [
                            Container(
                              width: 42,
                              height: 42,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                gradient: const LinearGradient(
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                  colors: [Color(0xFF2A4A7C), _navyLight],
                                ),
                                border: Border.all(
                                    color: _gold.withValues(alpha: 0.4),
                                    width: 1.5),
                              ),
                              child: Center(
                                child: Text(initials,
                                    style: const TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.bold,
                                        color: _gold)),
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  Text(studentName,
                                      style: TextStyle(
                                          fontSize: 15,
                                          fontWeight: FontWeight.bold,
                                          color:
                                              _cream.withValues(alpha: 0.95)),
                                      textDirection: TextDirection.rtl,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis),
                                  Text('سجلات التسميع والمراجعة',
                                      style: TextStyle(
                                          fontSize: 11,
                                          color: Colors.white
                                              .withValues(alpha: 0.45))),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 14),

                // Custom tab row
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: _TabRow(tab: tab),
                ),
                const SizedBox(height: 2),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Custom animated tab row ──────────────────────────────────────────────────
class _TabRow extends StatelessWidget {
  final TabController tab;
  const _TabRow({required this.tab});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _TabPill(
          label: 'التسميع',
          icon: Icons.menu_book_rounded,
          active: tab.index == 0,
          activeColor: _hifzClr,
          onTap: () => tab.animateTo(0),
        ),
        const SizedBox(width: 10),
        _TabPill(
          label: 'المراجعة',
          icon: Icons.refresh_rounded,
          active: tab.index == 1,
          activeColor: _revClr,
          onTap: () => tab.animateTo(1),
        ),
      ],
    );
  }
}

class _TabPill extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool active;
  final Color activeColor;
  final VoidCallback onTap;

  const _TabPill({
    required this.label,
    required this.icon,
    required this.active,
    required this.activeColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 220),
          curve: Curves.easeOut,
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: active
                ? activeColor.withValues(alpha: 0.2)
                : Colors.white.withValues(alpha: 0.06),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: active
                  ? activeColor.withValues(alpha: 0.5)
                  : Colors.white.withValues(alpha: 0.1),
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon,
                  size: 15,
                  color: active
                      ? Colors.white
                      : Colors.white.withValues(alpha: 0.4)),
              const SizedBox(width: 6),
              Text(label,
                  style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      color: active
                          ? Colors.white
                          : Colors.white.withValues(alpha: 0.4))),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── Hifz / Review tabs ───────────────────────────────────────────────────────
class _HifzTab extends ConsumerWidget {
  final HifzLogsParams params;
  final bool isDark;
  final VoidCallback onAdd;
  const _HifzTab(
      {required this.params, required this.isDark, required this.onAdd});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final logs = ref.watch(hifzLogsProvider(params));
    return logs.when(
      data: (list) => RefreshIndicator(
        color: _gold,
        onRefresh: () async => ref.invalidate(hifzLogsProvider(params)),
        child: list.isEmpty
            ? _EmptyState(
                isDark: isDark,
                message: 'لا توجد سجلات تسميع لهذا الطالب',
                icon: Icons.menu_book_rounded,
                color: _hifzClr,
                onAdd: onAdd,
              )
            : ListView.builder(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
                itemCount: list.length,
                itemBuilder: (_, i) => _HifzCard(
                    log: list[i], params: params, isDark: isDark, index: i),
              ),
      ),
      loading: () =>
          const Center(child: CircularProgressIndicator(color: _gold)),
      error: (e, _) => _ErrorState(
          isDark: isDark,
          error: e.toString(),
          onRetry: () {
            ref.invalidate(hifzLogsProvider(params));
          }),
    );
  }
}

class _ReviewTab extends ConsumerWidget {
  final HifzLogsParams params;
  final bool isDark;
  final VoidCallback onAdd;
  const _ReviewTab(
      {required this.params, required this.isDark, required this.onAdd});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final logs = ref.watch(reviewLogsProvider(params));
    return logs.when(
      data: (list) => RefreshIndicator(
        color: _gold,
        onRefresh: () async => ref.invalidate(reviewLogsProvider(params)),
        child: list.isEmpty
            ? _EmptyState(
                isDark: isDark,
                message: 'لا توجد سجلات مراجعة لهذا الطالب',
                icon: Icons.refresh_rounded,
                color: _revClr,
                onAdd: onAdd,
              )
            : ListView.builder(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
                itemCount: list.length,
                itemBuilder: (_, i) => _ReviewCard(
                    log: list[i], params: params, isDark: isDark, index: i),
              ),
      ),
      loading: () =>
          const Center(child: CircularProgressIndicator(color: _gold)),
      error: (e, _) => _ErrorState(
          isDark: isDark,
          error: e.toString(),
          onRetry: () {
            ref.invalidate(reviewLogsProvider(params));
          }),
    );
  }
}

// ─── Log card shared helpers ──────────────────────────────────────────────────
Color _evalColor(String ev) {
  switch (ev) {
    case 'excellent':
      return const Color(0xFF2E7D32);
    case 'very_good':
      return const Color(0xFF1565C0);
    case 'good':
      return const Color(0xFFF57F17);
    case 'needs_improvement':
      return const Color(0xFFE65100);
    case 'poor':
      return const Color(0xFFC62828);
    default:
      return Colors.grey;
  }
}

String _evalLabel(String ev) {
  switch (ev) {
    case 'excellent':
      return 'ممتاز';
    case 'very_good':
      return 'جيد جداً';
    case 'good':
      return 'جيد';
    case 'needs_improvement':
      return 'يحتاج تحسين';
    case 'poor':
      return 'ضعيف';
    default:
      return ev;
  }
}

String _evalStars(String ev) {
  switch (ev) {
    case 'excellent':
      return '★★★★★';
    case 'very_good':
      return '★★★★☆';
    case 'good':
      return '★★★☆☆';
    case 'needs_improvement':
      return '★★☆☆☆';
    case 'poor':
      return '★☆☆☆☆';
    default:
      return '';
  }
}

String _fmtDate(DateTime d) =>
    '${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}/${d.year}';

// ─── Hifz log card ────────────────────────────────────────────────────────────
class _HifzCard extends ConsumerStatefulWidget {
  final HifzLogEntity log;
  final HifzLogsParams params;
  final bool isDark;
  final int index;

  const _HifzCard({
    required this.log,
    required this.params,
    required this.isDark,
    required this.index,
  });

  @override
  ConsumerState<_HifzCard> createState() => _HifzCardState();
}

class _HifzCardState extends ConsumerState<_HifzCard>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _fade;
  late final Animation<Offset> _slide;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 400));
    _fade = CurvedAnimation(parent: _ctrl, curve: Curves.easeOut);
    _slide = Tween<Offset>(begin: const Offset(0, 0.1), end: Offset.zero)
        .animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeOutCubic));
    Future.delayed(Duration(milliseconds: 50 * widget.index), () {
      if (mounted) _ctrl.forward();
    });
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _fade,
      child: SlideTransition(
        position: _slide,
        child: _LogCardBody(
          isDark: widget.isDark,
          typeLabel: 'تسميع',
          typeColor: _hifzClr,
          date: _fmtDate(widget.log.date),
          range:
              '${widget.log.startSurah} ${widget.log.startAyah} ← ${widget.log.endSurah} ${widget.log.endAyah}',
          evaluation: widget.log.evaluation,
          notes: widget.log.notes,
          onEdit: () => showModalBottomSheet(
            context: context,
            isScrollControlled: true,
            backgroundColor: Colors.transparent,
            builder: (_) => EnhancedLogSheet(
                studentId: widget.log.studentId,
                courseId: widget.params.courseId,
                groupId: widget.log.groupId,
                hifzLog: widget.log),
          ),
          onDelete: () async {
            final ok = await _confirmDelete(context, widget.isDark);
            if (ok) {
              try {
                await deleteHifzLog(ref, widget.log.id,
                    studentId: widget.log.studentId,
                    courseId: widget.params.courseId);
              } catch (e) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                    content: Text('خطأ في الحذف: $e'),
                    backgroundColor: const Color(0xFFE53935),
                    behavior: SnackBarBehavior.floating,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ));
                }
              }
            }
          },
        ),
      ),
    );
  }
}

// ─── Review log card ──────────────────────────────────────────────────────────
class _ReviewCard extends ConsumerStatefulWidget {
  final ReviewLogEntity log;
  final HifzLogsParams params;
  final bool isDark;
  final int index;

  const _ReviewCard({
    required this.log,
    required this.params,
    required this.isDark,
    required this.index,
  });

  @override
  ConsumerState<_ReviewCard> createState() => _ReviewCardState();
}

class _ReviewCardState extends ConsumerState<_ReviewCard>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _fade;
  late final Animation<Offset> _slide;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 400));
    _fade = CurvedAnimation(parent: _ctrl, curve: Curves.easeOut);
    _slide = Tween<Offset>(begin: const Offset(0, 0.1), end: Offset.zero)
        .animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeOutCubic));
    Future.delayed(Duration(milliseconds: 50 * widget.index), () {
      if (mounted) _ctrl.forward();
    });
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _fade,
      child: SlideTransition(
        position: _slide,
        child: _LogCardBody(
          isDark: widget.isDark,
          typeLabel: 'مراجعة',
          typeColor: _revClr,
          date: _fmtDate(widget.log.date),
          range:
              '${widget.log.startSurah} ${widget.log.startAyah} ← ${widget.log.endSurah} ${widget.log.endAyah}',
          evaluation: widget.log.evaluation,
          notes: widget.log.notes,
          onEdit: () => showModalBottomSheet(
            context: context,
            isScrollControlled: true,
            backgroundColor: Colors.transparent,
            builder: (_) => EnhancedLogSheet(
              studentId: widget.log.studentId,
              courseId: widget.params.courseId, // ✅ Pass actual course
              groupId: widget.log.groupId,
              reviewLog: widget.log,
              initialLogType: LogType.review,
            ),
          ),
          onDelete: () async {
            final ok = await _confirmDelete(context, widget.isDark);
            if (ok) {
              try {
                await deleteReviewLog(
                  ref,
                  widget.log.id,
                  studentId: widget.log.studentId,
                  courseId: widget.params.courseId,
                );
              } catch (e) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                    content: Text('خطأ في الحذف: $e'),
                    backgroundColor: const Color(0xFFE53935),
                    behavior: SnackBarBehavior.floating,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ));
                }
              }
            }
          },
        ),
      ),
    );
  }
}

// ─── Shared log card body ─────────────────────────────────────────────────────
class _LogCardBody extends StatelessWidget {
  final bool isDark;
  final String typeLabel, date, range, evaluation, notes;
  final Color typeColor;
  final VoidCallback onEdit, onDelete;

  const _LogCardBody({
    required this.isDark,
    required this.typeLabel,
    required this.typeColor,
    required this.date,
    required this.range,
    required this.evaluation,
    required this.notes,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final cardBg = isDark ? _navyMid : _lightCard;
    final textClr = isDark ? _cream : _navy;
    final subClr = isDark ? Colors.grey[400]! : Colors.grey[500]!;
    final evalClr = _evalColor(evaluation);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _gold.withValues(alpha: 0.15)),
        boxShadow: [
          BoxShadow(
            color: isDark
                ? Colors.black.withValues(alpha: 0.22)
                : Colors.black.withValues(alpha: 0.05),
            blurRadius: 12,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Stack(
          children: [
            // Star watermark
            Positioned(
              left: -16,
              bottom: -16,
              child: CustomPaint(
                size: const Size(80, 80),
                painter: _StarBg(
                    color: typeColor.withValues(alpha: isDark ? 0.04 : 0.05)),
              ),
            ),
            // Top accent line
            Positioned(
              top: 0,
              right: 0,
              left: 0,
              child: Container(
                height: 3,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.centerRight,
                    end: Alignment.centerLeft,
                    colors: [
                      typeColor,
                      typeColor.withValues(alpha: 0.4),
                      typeColor.withValues(alpha: 0.0),
                    ],
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(14, 16, 14, 14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  // Header row
                  Row(
                    textDirection: TextDirection.rtl,
                    children: [
                      // Type badge
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: typeColor.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                              color: typeColor.withValues(alpha: 0.3)),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                                typeColor == _hifzClr
                                    ? Icons.menu_book_rounded
                                    : Icons.refresh_rounded,
                                size: 11,
                                color: typeColor),
                            const SizedBox(width: 4),
                            Text(typeLabel,
                                style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.bold,
                                    color: typeColor)),
                          ],
                        ),
                      ),
                      const Spacer(),
                      // Date
                      Row(children: [
                        Icon(Icons.calendar_today_rounded,
                            size: 11, color: subClr),
                        const SizedBox(width: 4),
                        Text(date,
                            style: TextStyle(fontSize: 12, color: subClr)),
                      ]),
                      const SizedBox(width: 4),
                      // Menu
                      _CardMenu(
                          isDark: isDark, onEdit: onEdit, onDelete: onDelete),
                    ],
                  ),

                  const SizedBox(height: 12),

                  // Surah range
                  Row(
                    textDirection: TextDirection.rtl,
                    children: [
                      Icon(Icons.import_contacts_rounded,
                          size: 14, color: _gold.withValues(alpha: 0.7)),
                      const SizedBox(width: 7),
                      Expanded(
                        child: Text(range,
                            style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.bold,
                                color: textClr),
                            textDirection: TextDirection.rtl),
                      ),
                    ],
                  ),

                  const SizedBox(height: 10),

                  // Evaluation + notes row
                  Row(
                    textDirection: TextDirection.rtl,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Evaluation chip
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: evalClr.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(8),
                          border:
                              Border.all(color: evalClr.withValues(alpha: 0.3)),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(_evalStars(evaluation),
                                style: TextStyle(fontSize: 10, color: evalClr)),
                            const SizedBox(width: 4),
                            Text(_evalLabel(evaluation),
                                style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.bold,
                                    color: evalClr)),
                          ],
                        ),
                      ),
                      if (notes.isNotEmpty) ...[
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(notes,
                              style: TextStyle(
                                  fontSize: 12, color: subClr, height: 1.4),
                              textDirection: TextDirection.rtl,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Card popup menu ──────────────────────────────────────────────────────────
class _CardMenu extends StatelessWidget {
  final bool isDark;
  final VoidCallback onEdit, onDelete;
  const _CardMenu(
      {required this.isDark, required this.onEdit, required this.onDelete});

  @override
  Widget build(BuildContext context) {
    final bg = isDark ? _navyMid : _lightCard;
    final txtCl = isDark ? _cream : _navy;

    return PopupMenuButton<String>(
      onSelected: (v) {
        if (v == 'edit') onEdit();
        if (v == 'delete') onDelete();
      },
      color: bg,
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(color: _gold.withValues(alpha: 0.2))),
      icon: Icon(Icons.more_vert_rounded,
          size: 18, color: isDark ? Colors.grey[500] : Colors.grey[400]),
      itemBuilder: (_) => [
        PopupMenuItem(
          value: 'edit',
          child: Row(children: [
            const Icon(Icons.edit_rounded, size: 16, color: _gold),
            const SizedBox(width: 8),
            Text('تعديل', style: TextStyle(fontSize: 13, color: txtCl)),
          ]),
        ),
        PopupMenuItem(
          value: 'delete',
          child: Row(children: [
            const Icon(Icons.delete_rounded,
                size: 16, color: Color(0xFFE53935)),
            const SizedBox(width: 8),
            const Text('حذف',
                style: TextStyle(fontSize: 13, color: Color(0xFFE53935))),
          ]),
        ),
      ],
    );
  }
}

// ─── Delete confirmation ──────────────────────────────────────────────────────
Future<bool> _confirmDelete(BuildContext context, bool isDark) async {
  final result = await showDialog<bool>(
    context: context,
    // dialogCtx = dialog's own BuildContext. Using outer `context` here would
    // make Navigator.of(context).pop() target go_router's page navigator
    // and pop the whole screen instead of dismissing the dialog.
    builder: (dialogCtx) => Dialog(
      backgroundColor: isDark ? _navyMid : _lightCard,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 58,
              height: 58,
              decoration: BoxDecoration(
                color: const Color(0xFFE53935).withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.delete_rounded,
                  size: 26, color: Color(0xFFE53935)),
            ),
            const SizedBox(height: 14),
            Text('تأكيد الحذف',
                style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: isDark ? _cream : _navy)),
            const SizedBox(height: 8),
            Text('هل تريد حذف هذا السجل؟ لا يمكن التراجع.',
                style: TextStyle(
                    fontSize: 13,
                    color: isDark ? Colors.grey[400] : Colors.grey[600]),
                textAlign: TextAlign.center,
                textDirection: TextDirection.rtl),
            const SizedBox(height: 20),
            Row(children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () => Navigator.of(dialogCtx).pop(false),
                  style: OutlinedButton.styleFrom(
                      side: BorderSide(color: _gold.withValues(alpha: 0.4)),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                      padding: const EdgeInsets.symmetric(vertical: 11)),
                  child: Text('إلغاء',
                      style: TextStyle(
                          color: isDark ? _cream : _navy,
                          fontWeight: FontWeight.w600)),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: ElevatedButton(
                  onPressed: () => Navigator.of(dialogCtx).pop(true),
                  style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFE53935),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                      padding: const EdgeInsets.symmetric(vertical: 11),
                      elevation: 0),
                  child: const Text('حذف',
                      style: TextStyle(fontWeight: FontWeight.bold)),
                ),
              ),
            ]),
          ],
        ),
      ),
    ),
  );
  return result ?? false;
}

// ─── Expandable FAB ───────────────────────────────────────────────────────────
class _Fab extends StatelessWidget {
  final bool open;
  final Animation<double> rotation;
  final int tabIndex;
  final VoidCallback onToggle, onHifz, onReview;

  const _Fab({
    required this.open,
    required this.rotation,
    required this.tabIndex,
    required this.onToggle,
    required this.onHifz,
    required this.onReview,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        // Hifz mini FAB
        AnimatedSlide(
          duration: const Duration(milliseconds: 200),
          offset: open ? Offset.zero : const Offset(0, 1.5),
          curve: Curves.easeOut,
          child: AnimatedOpacity(
            duration: const Duration(milliseconds: 180),
            opacity: open ? 1 : 0,
            child: _MiniFab(
              label: 'تسميع جديد',
              icon: Icons.menu_book_rounded,
              color: _hifzClr,
              onTap: onHifz,
            ),
          ),
        ),
        const SizedBox(height: 8),
        // Review mini FAB
        AnimatedSlide(
          duration: const Duration(milliseconds: 240),
          offset: open ? Offset.zero : const Offset(0, 1.5),
          curve: Curves.easeOut,
          child: AnimatedOpacity(
            duration: const Duration(milliseconds: 210),
            opacity: open ? 1 : 0,
            child: _MiniFab(
              label: 'مراجعة جديدة',
              icon: Icons.refresh_rounded,
              color: _revClr,
              onTap: onReview,
            ),
          ),
        ),
        const SizedBox(height: 10),
        // Main gold FAB
        GestureDetector(
          onTap: onToggle,
          child: Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [_gold, _goldDeep],
              ),
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: _gold.withValues(alpha: 0.4),
                  blurRadius: 16,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: RotationTransition(
              turns: rotation,
              child:
                  const Icon(Icons.add_rounded, color: Colors.white, size: 26),
            ),
          ),
        ),
      ],
    );
  }
}

class _MiniFab extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;
  const _MiniFab({
    required this.label,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) => GestureDetector(
        onTap: onTap,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: color.withValues(alpha: 0.35),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(icon, size: 15, color: Colors.white),
                  const SizedBox(width: 6),
                  Text(label,
                      style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          color: Colors.white)),
                ],
              ),
            ),
          ],
        ),
      );
}

// ─── Empty / Error ────────────────────────────────────────────────────────────
class _EmptyState extends StatelessWidget {
  final bool isDark;
  final String message;
  final IconData icon;
  final Color color;
  final VoidCallback onAdd;

  const _EmptyState({
    required this.isDark,
    required this.message,
    required this.icon,
    required this.color,
    required this.onAdd,
  });

  @override
  Widget build(BuildContext context) => Center(
        child: Padding(
          padding: const EdgeInsets.all(40),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.1),
                    shape: BoxShape.circle),
                child:
                    Icon(icon, size: 38, color: color.withValues(alpha: 0.6)),
              ),
              const SizedBox(height: 20),
              Text(message,
                  style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: isDark ? _cream : _navy),
                  textAlign: TextAlign.center,
                  textDirection: TextDirection.rtl),
              const SizedBox(height: 20),
              GestureDetector(
                onTap: onAdd,
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 11),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.centerRight,
                      end: Alignment.centerLeft,
                      colors: [_gold, _goldDeep],
                    ),
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                          color: _gold.withValues(alpha: 0.3),
                          blurRadius: 10,
                          offset: const Offset(0, 4)),
                    ],
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.add_rounded, size: 16, color: Colors.white),
                      SizedBox(width: 6),
                      Text('إضافة أول سجل',
                          style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                              color: Colors.white)),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      );
}

class _ErrorState extends StatelessWidget {
  final bool isDark;
  final String error;
  final VoidCallback onRetry;
  const _ErrorState(
      {required this.isDark, required this.error, required this.onRetry});

  @override
  Widget build(BuildContext context) => Center(
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
                    shape: BoxShape.circle),
                child: const Icon(Icons.error_outline_rounded,
                    size: 30, color: Color(0xFFE53935)),
              ),
              const SizedBox(height: 14),
              Text('خطأ في التحميل',
                  style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: isDark ? _cream : _navy)),
              const SizedBox(height: 20),
              ElevatedButton.icon(
                onPressed: onRetry,
                icon: const Icon(Icons.refresh_rounded, size: 16),
                label: const Text('إعادة المحاولة'),
                style: ElevatedButton.styleFrom(
                    backgroundColor: _gold,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12))),
              ),
            ],
          ),
        ),
      );
}

// ─── Star background painter ──────────────────────────────────────────────────
class _StarBg extends CustomPainter {
  final Color color;
  const _StarBg({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;
    final cx = size.width / 2;
    final cy = size.height / 2;
    final r = size.width / 2;
    for (var i = 0; i < 8; i++) {
      final angle = i * math.pi / 4;
      final path = Path()
        ..moveTo(cx, cy)
        ..lineTo(cx + r * 0.42 * math.cos(angle - 0.22),
            cy + r * 0.42 * math.sin(angle - 0.22))
        ..lineTo(cx + r * math.cos(angle), cy + r * math.sin(angle))
        ..lineTo(cx + r * 0.42 * math.cos(angle + 0.22),
            cy + r * 0.42 * math.sin(angle + 0.22))
        ..close();
      canvas.drawPath(path, paint);
    }
  }

  @override
  bool shouldRepaint(_StarBg old) => old.color != color;
}
