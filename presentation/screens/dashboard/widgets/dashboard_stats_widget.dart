// Path: lib/presentation/screens/dashboard/widgets/dashboard_stats_widget.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:quran_sheikh_app/domain/entities/dashboard/dashboard_entity.dart';

const _gold = Color(0xFFD4A843);
const _navy = Color(0xFF0B1120);
const _navyMid = Color(0xFF111D35);
const _cream = Color(0xFFF5EDD8);
const _lightCard = Color(0xFFFFFFFF);

class DashboardStatsWidget extends ConsumerWidget {
  final DashboardStatsEntity stats;
  final bool isDark;

  const DashboardStatsWidget(
      {Key? key, required this.stats, required this.isDark})
      : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        _SectionLabel(label: 'نظرة عامة', isDark: isDark),
        const SizedBox(height: 12),

        // Three equal stat cards side by side
        Row(
          children: [
            Expanded(
              child: _StatCard(
                label: 'الطلاب',
                value: stats.totalStudents.toString(),
                icon: Icons.people_alt_rounded,
                accentColor: _gold,
                isDark: isDark,
                isPrimary: true,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _StatCard(
                label: 'الدورات',
                value: stats.totalCourses.toString(),
                icon: Icons.menu_book_rounded,
                accentColor: const Color(0xFF5C6BC0),
                isDark: isDark,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _StatCard(
                label: 'المجموعات',
                value: stats.totalGroups.toString(),
                icon: Icons.groups_rounded,
                accentColor: const Color(0xFF26A69A),
                isDark: isDark,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _StatCard extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color accentColor;
  final bool isDark;
  final bool isPrimary;

  const _StatCard({
    required this.label,
    required this.value,
    required this.icon,
    required this.accentColor,
    required this.isDark,
    this.isPrimary = false,
  });

  @override
  Widget build(BuildContext context) {
    final cardBg = isDark ? _navyMid : _lightCard;
    final textColor = isDark ? _cream : _navy;
    final subColor = isDark ? Colors.grey[400]! : Colors.grey[500]!;

    // Primary (gold) card gets a subtle gradient top edge
    return Container(
      padding: const EdgeInsets.fromLTRB(14, 16, 14, 16),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: accentColor.withValues(alpha: isPrimary ? 0.45 : 0.18),
          width: isPrimary ? 1.5 : 1.0,
        ),
        boxShadow: [
          BoxShadow(
            color: isDark
                ? Colors.black.withValues(alpha: 0.25)
                : accentColor.withValues(alpha: 0.08),
            blurRadius: 14,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Icon badge
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: accentColor.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: accentColor, size: 20),
          ),
          const SizedBox(height: 10),
          // Value
          Text(
            value,
            style: TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.bold,
              color: accentColor,
              height: 1.0,
            ),
          ),
          const SizedBox(height: 4),
          // Label
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: subColor,
            ),
            textDirection: TextDirection.rtl,
          ),
        ],
      ),
    );
  }
}

// ─── Reusable section label ───────────────────────────────────────────────────
class _SectionLabel extends StatelessWidget {
  final String label;
  final bool isDark;

  const _SectionLabel({required this.label, required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Row(
      textDirection: TextDirection.rtl,
      children: [
        Container(
          width: 3,
          height: 16,
          decoration: BoxDecoration(
            color: _gold,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 8),
        Text(
          label,
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.bold,
            color: isDark ? _cream : _navy,
          ),
        ),
      ],
    );
  }
}

// Export so other widgets can reuse
class DashboardSectionLabel extends StatelessWidget {
  final String label;
  final bool isDark;
  const DashboardSectionLabel(
      {required this.label, required this.isDark, Key? key})
      : super(key: key);

  @override
  Widget build(BuildContext context) =>
      _SectionLabel(label: label, isDark: isDark);
}
