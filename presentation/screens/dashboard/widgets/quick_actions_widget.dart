// Path: lib/presentation/screens/dashboard/widgets/quick_actions_widget.dart

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:quran_sheikh_app/presentation/screens/dashboard/widgets/student_selector_sheet.dart';
import 'package:quran_sheikh_app/presentation/screens/logs/widgets/enhanced_log_sheet.dart';

const _gold = Color(0xFFD4A843);
const _navy = Color(0xFF0B1120);
const _navyMid = Color(0xFF111D35);
const _cream = Color(0xFFF5EDD8);
const _lightCard = Color(0xFFFFFFFF);

class QuickActionsWidget extends StatelessWidget {
  final bool isDark;
  const QuickActionsWidget({Key? key, required this.isDark}) : super(key: key);

  void _selectStudent(BuildContext ctx, LogType type) {
    showModalBottomSheet(
      context: ctx,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => StudentSelectorSheet(logType: type),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        // ── Section header ──────────────────────────────────────
        Row(
          textDirection: TextDirection.rtl,
          children: [
            Container(
              width: 3,
              height: 16,
              decoration: BoxDecoration(
                  color: _gold, borderRadius: BorderRadius.circular(2)),
            ),
            const SizedBox(width: 8),
            Text('إجراءات سريعة',
                style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: isDark ? _cream : _navy)),
          ],
        ),

        const SizedBox(height: 12),

        // ── Two primary action buttons (full row, very visible) ──
        Row(
          children: [
            Expanded(
              child: _PrimaryAction(
                title: 'تسجيل حفظ',
                description: 'أضف سجل حفظ لطالب',
                icon: Icons.auto_stories_rounded,
                iconBg: const Color(0xFF1B5E20),
                gradientColors: const [Color(0xFF2E7D32), Color(0xFF1B5E20)],
                glowColor: Color(0xFF2E7D32),
                isDark: isDark,
                onTap: () => _selectStudent(context, LogType.hifz),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _PrimaryAction(
                title: 'تسجيل مراجعة',
                description: 'أضف سجل مراجعة لطالب',
                icon: Icons.replay_circle_filled_rounded,
                iconBg: const Color(0xFF0D47A1),
                gradientColors: const [Color(0xFF1565C0), Color(0xFF0D47A1)],
                glowColor: Color(0xFF1565C0),
                isDark: isDark,
                onTap: () => _selectStudent(context, LogType.review),
              ),
            ),
          ],
        ),

        const SizedBox(height: 10),

        // ── Secondary navigation row ─────────────────────────────
        Row(
          children: [
            Expanded(
              child: _NavAction(
                title: 'الطلاب',
                icon: Icons.people_alt_rounded,
                color: const Color(0xFFE65100),
                isDark: isDark,
                onTap: () => context.go('/students'),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _NavAction(
                title: 'الدورات',
                icon: Icons.school_rounded,
                color: const Color(0xFF6A1B9A),
                isDark: isDark,
                onTap: () => context.go('/courses'),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _NavAction(
                title: 'التقارير',
                icon: Icons.bar_chart_rounded,
                color: const Color(0xFF00695C),
                isDark: isDark,
                onTap: () => ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: const Text('التقارير قريباً'),
                    backgroundColor: _gold,
                    behavior: SnackBarBehavior.floating,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Primary action — large gradient card, clearly tappable
// ─────────────────────────────────────────────────────────────────────────────
class _PrimaryAction extends StatefulWidget {
  final String title;
  final String description;
  final IconData icon;
  final Color iconBg;
  final List<Color> gradientColors;
  final Color glowColor;
  final bool isDark;
  final VoidCallback onTap;

  const _PrimaryAction({
    required this.title,
    required this.description,
    required this.icon,
    required this.iconBg,
    required this.gradientColors,
    required this.glowColor,
    required this.isDark,
    required this.onTap,
  });

  @override
  State<_PrimaryAction> createState() => _PrimaryActionState();
}

class _PrimaryActionState extends State<_PrimaryAction>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 110));
    _scale = Tween<double>(begin: 1.0, end: 0.96)
        .animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeIn));
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => _ctrl.forward(),
      onTapUp: (_) {
        _ctrl.reverse();
        widget.onTap();
      },
      onTapCancel: () => _ctrl.reverse(),
      child: ScaleTransition(
        scale: _scale,
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: widget.gradientColors,
              begin: Alignment.topRight,
              end: Alignment.bottomLeft,
            ),
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: widget.glowColor.withValues(alpha: 0.35),
                blurRadius: 18,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              // Icon in white pill
              Row(
                textDirection: TextDirection.rtl,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // "tap" hint arrow
                  Container(
                    width: 28,
                    height: 28,
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(Icons.arrow_back_ios_new_rounded,
                        size: 14, color: Colors.white),
                  ),
                  // Icon
                  Container(
                    width: 46,
                    height: 46,
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(13),
                    ),
                    child: Icon(widget.icon, color: Colors.white, size: 24),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              Text(
                widget.title,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
                textDirection: TextDirection.rtl,
              ),
              const SizedBox(height: 3),
              Text(
                widget.description,
                style: TextStyle(
                  fontSize: 11,
                  color: Colors.white.withValues(alpha: 0.78),
                ),
                textDirection: TextDirection.rtl,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Navigation action — compact outlined card
// ─────────────────────────────────────────────────────────────────────────────
class _NavAction extends StatelessWidget {
  final String title;
  final IconData icon;
  final Color color;
  final bool isDark;
  final VoidCallback onTap;

  const _NavAction({
    required this.title,
    required this.icon,
    required this.color,
    required this.isDark,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final cardBg = isDark ? _navyMid : _lightCard;
    final textColor = isDark ? _cream : _navy;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Ink(
          padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 8),
          decoration: BoxDecoration(
            color: cardBg,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: color.withValues(alpha: 0.25)),
            boxShadow: [
              BoxShadow(
                color: isDark
                    ? Colors.black.withValues(alpha: 0.2)
                    : color.withValues(alpha: 0.07),
                blurRadius: 10,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Column(
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: color, size: 20),
              ),
              const SizedBox(height: 8),
              Text(
                title,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: textColor,
                ),
                textDirection: TextDirection.rtl,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
