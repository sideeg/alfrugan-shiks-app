// Path: lib/presentation/screens/courses/courses_screen.dart

import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../domain/entities/courses/course_entity.dart';
import '../../providers/courses_provider.dart';

const _cGold = Color(0xFFD4A843);
const _cNavy = Color(0xFF0B1120);
const _cNavyMid = Color(0xFF111D35);
const _cNavyLight = Color(0xFF1A2A4A);
const _cCream = Color(0xFFF5EDD8);
const _cLightBg = Color(0xFFF2F4F8);
const _cLightCard = Color(0xFFFFFFFF);

class CoursesScreen extends ConsumerWidget {
  const CoursesScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final asyncCourses = ref.watch(coursesProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: isDark ? SystemUiOverlayStyle.light : SystemUiOverlayStyle.dark,
      child: Scaffold(
        backgroundColor: isDark ? _cNavy : _cLightBg,
        body: SafeArea(
          child: Column(
            children: [
              _TopBar(isDark: isDark),
              Expanded(
                child: RefreshIndicator(
                  color: _cGold,
                  backgroundColor: isDark ? _cNavyMid : _cLightCard,
                  onRefresh: () async => ref.invalidate(coursesProvider),
                  child: asyncCourses.when(
                    data: (courses) => courses.isEmpty
                        ? _EmptyState(isDark: isDark)
                        : _CoursesList(courses: courses, isDark: isDark),
                    loading: () => const Center(
                        child: CircularProgressIndicator(color: _cGold)),
                    error: (err, _) => _ErrorState(
                      error: err.toString(),
                      isDark: isDark,
                      onRetry: () => ref.invalidate(coursesProvider),
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

class _TopBar extends StatelessWidget {
  final bool isDark;
  const _TopBar({required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 12),
      child: Row(
        textDirection: TextDirection.rtl,
        children: [
          GestureDetector(
            onTap: () => context.go('/dashboard'),
            child: Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: isDark ? _cNavyMid : _cLightCard,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: _cGold.withValues(alpha: 0.2)),
              ),
              child: Icon(Icons.arrow_back_ios_new_rounded,
                  size: 15, color: isDark ? _cCream : _cNavy),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text('الدورات',
                    style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: isDark ? _cCream : _cNavy)),
                Text('دوراتك التعليمية المسجّلة',
                    style: TextStyle(
                        fontSize: 11,
                        color: isDark
                            ? _cCream.withValues(alpha: 0.45)
                            : Colors.grey[500])),
              ],
            ),
          ),
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: _cGold.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: _cGold.withValues(alpha: 0.3)),
            ),
            child: const Icon(Icons.school_rounded, color: _cGold, size: 20),
          ),
        ],
      ),
    );
  }
}

class _CoursesList extends StatelessWidget {
  final List<CourseEntity> courses;
  final bool isDark;
  const _CoursesList({required this.courses, required this.isDark});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
      itemCount: courses.length,
      itemBuilder: (ctx, i) =>
          _AnimatedCard(course: courses[i], isDark: isDark, index: i),
    );
  }
}

class _AnimatedCard extends StatefulWidget {
  final CourseEntity course;
  final bool isDark;
  final int index;
  const _AnimatedCard(
      {required this.course, required this.isDark, required this.index});

  @override
  State<_AnimatedCard> createState() => _AnimatedCardState();
}

class _AnimatedCardState extends State<_AnimatedCard>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _fade;
  late final Animation<Offset> _slide;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 420));
    _fade = CurvedAnimation(parent: _ctrl, curve: Curves.easeOut);
    _slide = Tween<Offset>(begin: const Offset(0, 0.12), end: Offset.zero)
        .animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeOutCubic));
    Future.delayed(Duration(milliseconds: 55 * widget.index), () {
      if (mounted) _ctrl.forward();
    });
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => FadeTransition(
        opacity: _fade,
        child: SlideTransition(
            position: _slide,
            child: _CourseCard(course: widget.course, isDark: widget.isDark)),
      );
}

class _CourseCard extends StatefulWidget {
  final CourseEntity course;
  final bool isDark;
  const _CourseCard({required this.course, required this.isDark});

  @override
  State<_CourseCard> createState() => _CourseCardState();
}

class _CourseCardState extends State<_CourseCard>
    with SingleTickerProviderStateMixin {
  late final AnimationController _press;
  late final Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _press = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 100));
    _scale = Tween<double>(begin: 1.0, end: 0.97)
        .animate(CurvedAnimation(parent: _press, curve: Curves.easeIn));
  }

  @override
  void dispose() {
    _press.dispose();
    super.dispose();
  }

  // Derive accent colour from typeDisplayName — no 'type' field on entity
  Color _accent() {
    final t = widget.course.typeDisplayName.toLowerCase();
    if (t.contains('حفظ') || t.contains('quran'))
      return const Color(0xFF2E7D32);
    if (t.contains('تجويد') || t.contains('tajweed'))
      return const Color(0xFF1565C0);
    if (t.contains('عربي') || t.contains('arabic'))
      return const Color(0xFF6A1B9A);
    return const Color(0xFFB8860B);
  }

  double get _progress {
    if (widget.course.maxStudents == 0) return 0;
    return (widget.course.currentStudents / widget.course.maxStudents)
        .clamp(0.0, 1.0);
  }

  @override
  Widget build(BuildContext context) {
    final c = widget.course;
    final isDark = widget.isDark;
    final accent = _accent();
    final prog = _progress;
    final cardBg = isDark ? _cNavyMid : _cLightCard;
    final textClr = isDark ? _cCream : _cNavy;
    final subClr = isDark ? Colors.grey[400]! : Colors.grey[600]!;

    return GestureDetector(
      onTapDown: (_) => _press.forward(),
      onTapUp: (_) {
        _press.reverse();
        context.go('/courses/${c.id}', extra: c);
      },
      onTapCancel: () => _press.reverse(),
      child: ScaleTransition(
        scale: _scale,
        child: Container(
          margin: const EdgeInsets.only(bottom: 14),
          decoration: BoxDecoration(
            color: cardBg,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: _cGold.withValues(alpha: 0.18)),
            boxShadow: [
              BoxShadow(
                color: isDark
                    ? Colors.black.withValues(alpha: 0.28)
                    : Colors.black.withValues(alpha: 0.06),
                blurRadius: 16,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(18),
            child: Stack(
              children: [
                // Star watermark
                Positioned(
                  left: -20,
                  bottom: -20,
                  child: CustomPaint(
                    size: const Size(100, 100),
                    painter: _StarWatermark(
                        color: _cGold.withValues(alpha: isDark ? 0.04 : 0.05)),
                  ),
                ),
                // Top accent line — use begin/end instead of textDirection
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
                          accent.withValues(alpha: 0.0),
                          accent,
                          _cGold,
                          accent.withValues(alpha: 0.0),
                        ],
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 18, 16, 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      // Title + badge
                      Row(
                        textDirection: TextDirection.rtl,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Text(c.name,
                                style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: textClr,
                                    height: 1.3),
                                textDirection: TextDirection.rtl,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis),
                          ),
                          const SizedBox(width: 10),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: accent.withValues(alpha: 0.12),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                  color: accent.withValues(alpha: 0.3)),
                            ),
                            child: Text(c.typeDisplayName,
                                style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.bold,
                                    color: accent)),
                          ),
                        ],
                      ),

                      // Description
                      if (c.description.isNotEmpty) ...[
                        const SizedBox(height: 8),
                        Text(c.description,
                            style: TextStyle(
                                fontSize: 13, color: subClr, height: 1.5),
                            textDirection: TextDirection.rtl,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis),
                      ],

                      const SizedBox(height: 10),

                      // Date chip — use startDate/endDate from entity
                      _Chip(
                        icon: Icons.calendar_today_rounded,
                        label:
                            '${c.startDate.split(' ').first}  –  ${c.endDate.split(' ').first}',
                        isDark: isDark,
                      ),

                      const SizedBox(height: 14),

                      // Enrollment
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
                                color: c.isRegistrationOpen
                                    ? const Color(0xFF2E7D32)
                                    : Colors.grey,
                              ),
                            ),
                            const SizedBox(width: 5),
                            Text(
                              c.isRegistrationOpen
                                  ? 'التسجيل مفتوح'
                                  : 'التسجيل مغلق',
                              style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                  color: c.isRegistrationOpen
                                      ? const Color(0xFF2E7D32)
                                      : Colors.grey),
                            ),
                          ]),
                          Text('${c.currentStudents}/${c.maxStudents} طالب',
                              style: const TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: _cGold)),
                        ],
                      ),
                      const SizedBox(height: 7),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(4),
                        child: Stack(children: [
                          Container(
                              height: 5,
                              width: double.infinity,
                              color: isDark
                                  ? _cNavyLight
                                  : Colors.grey.withValues(alpha: 0.12)),
                          FractionallySizedBox(
                            widthFactor: prog,
                            child: Container(
                              height: 5,
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  begin: Alignment.centerRight,
                                  end: Alignment.centerLeft,
                                  colors: [_cGold, accent],
                                ),
                              ),
                            ),
                          ),
                        ]),
                      ),

                      const SizedBox(height: 12),

                      // Footer
                      Row(
                        textDirection: TextDirection.rtl,
                        children: [
                          Container(
                            width: 32,
                            height: 32,
                            decoration: BoxDecoration(
                              color: _cGold.withValues(alpha: 0.12),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Icon(Icons.arrow_back_ios_new_rounded,
                                size: 13, color: _cGold),
                          ),
                          Expanded(
                            child: Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 10),
                              child: Row(children: [
                                Expanded(
                                    child: Container(
                                        height: 1,
                                        color: _cGold.withValues(alpha: 0.15))),
                                Padding(
                                  padding:
                                      const EdgeInsets.symmetric(horizontal: 5),
                                  child: Container(
                                      width: 4,
                                      height: 4,
                                      decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          color:
                                              _cGold.withValues(alpha: 0.35))),
                                ),
                                Expanded(
                                    child: Container(
                                        height: 1,
                                        color: _cGold.withValues(alpha: 0.15))),
                              ]),
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 5),
                            decoration: BoxDecoration(
                              color: _cGold.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(
                                  color: _cGold.withValues(alpha: 0.25)),
                            ),
                            child: const Text('عرض التفاصيل',
                                style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w600,
                                    color: _cGold)),
                          ),
                        ],
                      ),
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

class _Chip extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isDark;
  const _Chip({required this.icon, required this.label, required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: isDark
            ? _cNavyLight.withValues(alpha: 0.6)
            : Colors.grey.withValues(alpha: 0.07),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
            color: isDark
                ? Colors.white.withValues(alpha: 0.06)
                : Colors.grey.withValues(alpha: 0.15)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon,
              size: 11, color: isDark ? Colors.grey[400] : Colors.grey[500]),
          const SizedBox(width: 5),
          Text(label,
              style: TextStyle(
                  fontSize: 11,
                  color: isDark ? Colors.grey[400] : Colors.grey[600])),
        ],
      ),
    );
  }
}

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

class _EmptyState extends StatelessWidget {
  final bool isDark;
  const _EmptyState({required this.isDark});

  @override
  Widget build(BuildContext context) => Center(
        child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
                color: _cGold.withValues(alpha: 0.1), shape: BoxShape.circle),
            child: Icon(Icons.school_rounded,
                size: 38, color: _cGold.withValues(alpha: 0.7)),
          ),
          const SizedBox(height: 20),
          Text('لا توجد دورات',
              style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.bold,
                  color: isDark ? _cCream : _cNavy)),
          const SizedBox(height: 6),
          Text('لم يتم تسجيلك في أي دورة بعد',
              style: TextStyle(
                  fontSize: 13,
                  color: isDark ? Colors.grey[400] : Colors.grey[500])),
        ]),
      );
}

class _ErrorState extends StatelessWidget {
  final String error;
  final bool isDark;
  final VoidCallback onRetry;
  const _ErrorState(
      {required this.error, required this.isDark, required this.onRetry});

  @override
  Widget build(BuildContext context) => Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
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
                    color: isDark ? _cCream : _cNavy)),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh_rounded, size: 16),
              label: const Text('إعادة المحاولة'),
              style: ElevatedButton.styleFrom(
                  backgroundColor: _cGold,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12))),
            ),
          ]),
        ),
      );
}
