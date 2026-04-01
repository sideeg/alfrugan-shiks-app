// Path: lib/presentation/screens/courses/course_details_screen.dart

import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../domain/entities/courses/course_entity.dart';
import '../../../presentation/providers/course_groups_provider.dart';

// ─── Palette ──────────────────────────────────────────────────────────────────
const _dGold = Color(0xFFD4A843);
const _dNavy = Color(0xFF0B1120);
const _dNavyMid = Color(0xFF111D35);
const _dNavyLight = Color(0xFF1A2A4A);
const _dCream = Color(0xFFF5EDD8);
const _dLightCard = Color(0xFFFFFFFF);
const _dLightBg = Color(0xFFF2F4F8);

class CourseDetailsScreen extends ConsumerWidget {
  final CourseEntity course;
  const CourseDetailsScreen({required this.course, Key? key}) : super(key: key);

  // Only typeDisplayName is available — derive accent colour from it
  Color _accent() {
    final t = course.typeDisplayName.toLowerCase();
    if (t.contains('حفظ') || t.contains('quran'))
      return const Color(0xFF2E7D32);
    if (t.contains('تجويد') || t.contains('tajweed'))
      return const Color(0xFF1565C0);
    if (t.contains('عربي') || t.contains('arabic'))
      return const Color(0xFF6A1B9A);
    return const Color(0xFFB8860B);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final asyncGroups = ref.watch(courseGroupsProvider(course.id));
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final accent = _accent();

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: Scaffold(
        backgroundColor: isDark ? _dNavy : _dLightBg,
        body: RefreshIndicator(
          color: _dGold,
          backgroundColor: isDark ? _dNavyMid : _dLightCard,
          onRefresh: () async =>
              ref.invalidate(courseGroupsProvider(course.id)),
          child: CustomScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            slivers: [
              _HeroSliver(course: course, isDark: isDark, accent: accent),
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(16, 20, 16, 40),
                sliver: asyncGroups.when(
                  data: (groups) {
                    if (groups.isEmpty) {
                      return SliverToBoxAdapter(
                          child: _NoGroups(isDark: isDark));
                    }
                    return SliverList(
                      delegate: SliverChildBuilderDelegate(
                        (ctx, i) {
                          if (i == 0) {
                            return Padding(
                              padding: const EdgeInsets.only(bottom: 14),
                              child: _SectionHeader(
                                  label: 'المجموعات', isDark: isDark),
                            );
                          }
                          return _GroupCard(
                            group: groups[i - 1],
                            isDark: isDark,
                            accent: accent,
                          );
                        },
                        childCount: groups.length + 1,
                      ),
                    );
                  },
                  loading: () => const SliverToBoxAdapter(
                    child: Padding(
                      padding: EdgeInsets.only(top: 50),
                      child: Center(
                          child: CircularProgressIndicator(color: _dGold)),
                    ),
                  ),
                  error: (err, _) => SliverToBoxAdapter(
                    child: _LoadError(
                      error: err.toString(),
                      isDark: isDark,
                      onRetry: () =>
                          ref.invalidate(courseGroupsProvider(course.id)),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── Hero SliverAppBar ────────────────────────────────────────────────────────
class _HeroSliver extends StatelessWidget {
  final CourseEntity course;
  final bool isDark;
  final Color accent;
  const _HeroSliver(
      {required this.course, required this.isDark, required this.accent});

  double get _progress {
    if (course.maxStudents == 0) return 0;
    return (course.currentStudents / course.maxStudents).clamp(0.0, 1.0);
  }

  @override
  Widget build(BuildContext context) {
    final prog = _progress;
    return SliverAppBar(
      expandedHeight: 250,
      pinned: true,
      backgroundColor: _dNavy,
      automaticallyImplyLeading: false,
      leading: Padding(
        padding: const EdgeInsets.all(8),
        child: GestureDetector(
          onTap: () => context.go('/courses'),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: Colors.white.withValues(alpha: 0.2)),
            ),
            child: const Icon(Icons.arrow_back_ios_new_rounded,
                size: 15, color: Colors.white),
          ),
        ),
      ),
      flexibleSpace: FlexibleSpaceBar(
        collapseMode: CollapseMode.pin,
        background: Stack(
          children: [
            // Background gradient — begin/end only, no textDirection
            Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topRight,
                  end: Alignment.bottomLeft,
                  colors: [Color(0xFF1A3A6C), _dNavy],
                ),
              ),
            ),
            // Star watermarks
            Positioned(
              right: -30,
              top: -30,
              child: CustomPaint(
                size: const Size(160, 160),
                painter: _StarWatermark(color: _dGold.withValues(alpha: 0.06)),
              ),
            ),
            Positioned(
              left: -20,
              bottom: 20,
              child: CustomPaint(
                size: const Size(90, 90),
                painter: _StarWatermark(color: accent.withValues(alpha: 0.08)),
              ),
            ),
            // Text content
            SafeArea(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 44, 16, 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    // Type badge — uses typeDisplayName (exists on entity)
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 5),
                      decoration: BoxDecoration(
                        color: accent.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(20),
                        border:
                            Border.all(color: accent.withValues(alpha: 0.4)),
                      ),
                      child: Text(
                        course.typeDisplayName,
                        style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: Colors.white),
                      ),
                    ),
                    const SizedBox(height: 10),
                    // Name
                    Text(
                      course.name,
                      style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          height: 1.3),
                      textDirection: TextDirection.rtl,
                    ),
                    // Description
                    if (course.description.isNotEmpty) ...[
                      const SizedBox(height: 6),
                      Text(
                        course.description,
                        style: TextStyle(
                            fontSize: 13,
                            color: Colors.white.withValues(alpha: 0.6),
                            height: 1.4),
                        textDirection: TextDirection.rtl,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                    const SizedBox(height: 14),
                    // Stats chips — only entity fields: currentStudents, startDate, endDate
                    Row(
                      textDirection: TextDirection.rtl,
                      children: [
                        _HeroChip(
                          icon: Icons.people_alt_rounded,
                          value: '${course.currentStudents}',
                          label: 'طالب',
                          color: _dGold,
                        ),
                        const SizedBox(width: 8),
                        _HeroChip(
                          icon: Icons.calendar_today_rounded,
                          value: course.startDate.split(' ').first,
                          label: 'بداية',
                          color: const Color(0xFF26A69A),
                          small: true,
                        ),
                        const SizedBox(width: 8),
                        _HeroChip(
                          icon: Icons.event_rounded,
                          value: course.endDate.split(' ').first,
                          label: 'نهاية',
                          color: const Color(0xFF5C6BC0),
                          small: true,
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    // Enrollment — isRegistrationOpen & currentStudents/maxStudents
                    Row(
                      textDirection: TextDirection.rtl,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(children: [
                          Container(
                            width: 6,
                            height: 6,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: course.isRegistrationOpen
                                  ? const Color(0xFF66BB6A)
                                  : Colors.grey,
                            ),
                          ),
                          const SizedBox(width: 5),
                          Text(
                            course.isRegistrationOpen
                                ? 'التسجيل مفتوح'
                                : 'التسجيل مغلق',
                            style: TextStyle(
                                fontSize: 11,
                                color: course.isRegistrationOpen
                                    ? const Color(0xFF66BB6A)
                                    : Colors.grey),
                          ),
                        ]),
                        Text(
                          '${course.currentStudents}/${course.maxStudents}',
                          style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: _dGold),
                        ),
                      ],
                    ),
                    const SizedBox(height: 5),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(3),
                      child: Stack(children: [
                        Container(
                            height: 4,
                            width: double.infinity,
                            color: Colors.white.withValues(alpha: 0.12)),
                        FractionallySizedBox(
                          widthFactor: prog,
                          child: Container(
                            height: 4,
                            decoration: BoxDecoration(
                              // begin/end instead of textDirection
                              gradient: LinearGradient(
                                begin: Alignment.centerRight,
                                end: Alignment.centerLeft,
                                colors: [_dGold, accent],
                              ),
                            ),
                          ),
                        ),
                      ]),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _HeroChip extends StatelessWidget {
  final IconData icon;
  final String value;
  final String label;
  final Color color;
  final bool small;
  const _HeroChip({
    required this.icon,
    required this.value,
    required this.label,
    required this.color,
    this.small = false,
  });

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: color.withValues(alpha: 0.35)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 13, color: color),
            const SizedBox(width: 5),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(value,
                    style: TextStyle(
                        fontSize: small ? 11 : 14,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        height: 1.1)),
                Text(label,
                    style: TextStyle(
                        fontSize: 9,
                        color: Colors.white.withValues(alpha: 0.5))),
              ],
            ),
          ],
        ),
      );
}

// ─── Section header ───────────────────────────────────────────────────────────
class _SectionHeader extends StatelessWidget {
  final String label;
  final bool isDark;
  const _SectionHeader({required this.label, required this.isDark});

  @override
  Widget build(BuildContext context) => Row(
        textDirection: TextDirection.rtl,
        children: [
          Container(
              width: 3,
              height: 16,
              decoration: BoxDecoration(
                  color: _dGold, borderRadius: BorderRadius.circular(2))),
          const SizedBox(width: 8),
          Text(label,
              style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: isDark ? _dCream : _dNavy)),
        ],
      );
}

// ─── Group card ───────────────────────────────────────────────────────────────
class _GroupCard extends StatefulWidget {
  final dynamic group;
  final bool isDark;
  final Color accent;
  const _GroupCard(
      {required this.group, required this.isDark, required this.accent});

  @override
  State<_GroupCard> createState() => _GroupCardState();
}

class _GroupCardState extends State<_GroupCard>
    with SingleTickerProviderStateMixin {
  bool _expanded = false;
  late final AnimationController _ctrl;
  late final Animation<double> _turn;
  late final Animation<double> _size;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 260));
    _turn = Tween<double>(begin: 0, end: 0.5)
        .animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut));
    _size = CurvedAnimation(parent: _ctrl, curve: Curves.easeOut);
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

  double _prog() {
    final max = (widget.group.maxStudents ?? 0) as int;
    final cur = (widget.group.currentStudents ?? 0) as int;
    if (max == 0) return 0;
    return (cur / max).clamp(0.0, 1.0);
  }

  @override
  Widget build(BuildContext context) {
    final g = widget.group;
    final isDark = widget.isDark;
    final cardBg = isDark ? _dNavyMid : _dLightCard;
    final textClr = isDark ? _dCream : _dNavy;
    final subClr = isDark ? Colors.grey[400]! : Colors.grey[600]!;
    final prog = _prog();
    final students = (g.students ?? []) as List;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: _expanded
              ? widget.accent.withValues(alpha: 0.3)
              : _dGold.withValues(alpha: 0.15),
        ),
        boxShadow: [
          BoxShadow(
            color: isDark
                ? Colors.black.withValues(alpha: 0.2)
                : Colors.black.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        children: [
          // ── Tappable header ─────────────────────────────────
          GestureDetector(
            onTap: _toggle,
            behavior: HitTestBehavior.opaque,
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Row(
                    textDirection: TextDirection.rtl,
                    children: [
                      Container(
                        width: 42,
                        height: 42,
                        decoration: BoxDecoration(
                          color: widget.accent.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(Icons.groups_rounded,
                            color: widget.accent, size: 22),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(g.name ?? '',
                                style: TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.bold,
                                    color: textClr),
                                textDirection: TextDirection.rtl),
                            if ((g.scheduleDetails ?? '').isNotEmpty)
                              Text(g.scheduleDetails.toString(),
                                  style: TextStyle(fontSize: 12, color: subClr),
                                  textDirection: TextDirection.rtl),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      // Student count badge
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: _dGold.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(8),
                          border:
                              Border.all(color: _dGold.withValues(alpha: 0.25)),
                        ),
                        child: Text(
                          '${g.currentStudents ?? 0}',
                          style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                              color: _dGold),
                        ),
                      ),
                      const SizedBox(width: 8),
                      // Rotate arrow
                      RotationTransition(
                        turns: _turn,
                        child: Container(
                          width: 28,
                          height: 28,
                          decoration: BoxDecoration(
                            color: _dGold.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Icon(Icons.keyboard_arrow_down_rounded,
                              size: 18, color: _dGold),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  // Mini progress
                  Row(
                    textDirection: TextDirection.rtl,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('${(prog * 100).round()}%',
                          style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: _dGold.withValues(alpha: 0.8))),
                      Text(
                          '${g.currentStudents ?? 0}/${g.maxStudents ?? 0} طالب',
                          style: TextStyle(fontSize: 11, color: subClr)),
                    ],
                  ),
                  const SizedBox(height: 5),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(3),
                    child: Stack(children: [
                      Container(
                          height: 3,
                          width: double.infinity,
                          color: isDark
                              ? _dNavyLight
                              : Colors.grey.withValues(alpha: 0.12)),
                      FractionallySizedBox(
                        widthFactor: prog,
                        child: Container(
                          height: 3,
                          // begin/end, no textDirection
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.centerRight,
                              end: Alignment.centerLeft,
                              colors: [_dGold, widget.accent],
                            ),
                          ),
                        ),
                      ),
                    ]),
                  ),
                ],
              ),
            ),
          ),

          // ── Students list ────────────────────────────────────
          SizeTransition(
            sizeFactor: _size,
            child: Column(
              children: [
                // Divider
                Container(
                  height: 1,
                  margin: const EdgeInsets.symmetric(horizontal: 14),
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.centerRight,
                      end: Alignment.centerLeft,
                      colors: [
                        Colors.transparent,
                        Color(0x33D4A843),
                        Colors.transparent,
                      ],
                    ),
                  ),
                ),
                if (students.isEmpty)
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        vertical: 16, horizontal: 16),
                    child: Text('لا يوجد طلاب في هذه المجموعة',
                        style: TextStyle(
                            fontSize: 13,
                            color:
                                isDark ? Colors.grey[500] : Colors.grey[400]),
                        textDirection: TextDirection.rtl),
                  )
                else
                  ...List.generate(
                      students.length,
                      (i) => _StudentTile(
                            student: students[i],
                            isDark: isDark,
                            accent: widget.accent,
                            isLast: i == students.length - 1,
                          )),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Student tile ─────────────────────────────────────────────────────────────
class _StudentTile extends StatelessWidget {
  final dynamic student;
  final bool isDark;
  final Color accent;
  final bool isLast;
  const _StudentTile({
    required this.student,
    required this.isDark,
    required this.accent,
    required this.isLast,
  });

  String _initials(String name) {
    final parts = name.trim().split(' ');
    if (parts.length >= 2) return '${parts[0][0]}${parts[1][0]}';
    return name.isNotEmpty ? name[0] : '؟';
  }

  @override
  Widget build(BuildContext context) {
    final s = student;
    final textClr = isDark ? _dCream : _dNavy;
    final subClr = isDark ? Colors.grey[400]! : Colors.grey[600]!;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => context.goNamed(
          'studentLogs',
          pathParameters: {'id': s.id.toString()},
        ),
        borderRadius: isLast
            ? const BorderRadius.only(
                bottomLeft: Radius.circular(16),
                bottomRight: Radius.circular(16))
            : BorderRadius.zero,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(14, 10, 14, 10),
          child: Row(
            textDirection: TextDirection.rtl,
            children: [
              // Avatar with initials
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      accent.withValues(alpha: 0.7),
                      accent.withValues(alpha: 0.35),
                    ],
                  ),
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(
                    _initials(s.name ?? ''),
                    style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        color: Colors.white),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(s.name ?? '',
                        style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: textClr),
                        textDirection: TextDirection.rtl),
                    if ((s.email ?? '').isNotEmpty)
                      Text(s.email.toString(),
                          style: TextStyle(fontSize: 11, color: subClr)),
                  ],
                ),
              ),
              Icon(Icons.arrow_back_ios_rounded,
                  size: 12,
                  color: isDark ? Colors.grey[600] : Colors.grey[400]),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── Empty / Error ────────────────────────────────────────────────────────────
class _NoGroups extends StatelessWidget {
  final bool isDark;
  const _NoGroups({required this.isDark});

  @override
  Widget build(BuildContext context) => Center(
        child: Padding(
          padding: const EdgeInsets.all(40),
          child: Column(
            children: [
              Container(
                width: 70,
                height: 70,
                decoration: BoxDecoration(
                    color: _dGold.withValues(alpha: 0.1),
                    shape: BoxShape.circle),
                child: Icon(Icons.groups_outlined,
                    size: 34, color: _dGold.withValues(alpha: 0.6)),
              ),
              const SizedBox(height: 16),
              Text('لا توجد مجموعات لهذه الدورة',
                  style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: isDark ? _dCream : _dNavy),
                  textDirection: TextDirection.rtl),
            ],
          ),
        ),
      );
}

class _LoadError extends StatelessWidget {
  final String error;
  final bool isDark;
  final VoidCallback onRetry;
  const _LoadError(
      {required this.error, required this.isDark, required this.onRetry});

  @override
  Widget build(BuildContext context) => Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            children: [
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                    color: const Color(0xFFE53935).withValues(alpha: 0.1),
                    shape: BoxShape.circle),
                child: const Icon(Icons.error_outline_rounded,
                    size: 32, color: Color(0xFFE53935)),
              ),
              const SizedBox(height: 14),
              Text('خطأ في التحميل',
                  style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: isDark ? _dCream : _dNavy),
                  textDirection: TextDirection.rtl),
              const SizedBox(height: 20),
              ElevatedButton.icon(
                onPressed: onRetry,
                icon: const Icon(Icons.refresh_rounded, size: 16),
                label: const Text('إعادة المحاولة'),
                style: ElevatedButton.styleFrom(
                    backgroundColor: _dGold,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12))),
              ),
            ],
          ),
        ),
      );
}

// ─── Star watermark painter ───────────────────────────────────────────────────
class _StarWatermark extends CustomPainter {
  final Color color;
  const _StarWatermark({required this.color});

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
  bool shouldRepaint(_StarWatermark old) => old.color != color;
}
