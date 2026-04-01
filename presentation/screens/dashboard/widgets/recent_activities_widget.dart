// Path: lib/presentation/screens/dashboard/widgets/recent_activities_widget.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:quran_sheikh_app/domain/entities/dashboard/dashboard_entity.dart';
import 'package:intl/intl.dart' as intl;
import 'package:quran_sheikh_app/presentation/screens/dashboard/widgets/student_selector_sheet.dart';
import 'package:quran_sheikh_app/presentation/screens/logs/widgets/enhanced_log_sheet.dart';

class RecentActivitiesWidget extends ConsumerWidget {
  final List<RecentHifzLogEntity> hifzLogs;
  final List<RecentReviewLogEntity> reviewLogs;
  final bool isDark;

  const RecentActivitiesWidget({
    Key? key,
    required this.hifzLogs,
    required this.reviewLogs,
    required this.isDark,
  }) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final textColor =
        isDark ? const Color(0xFFF5EDD8) : const Color(0xFF1A1A2E);
    final isEmpty = hifzLogs.isEmpty && reviewLogs.isEmpty;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        // Section header
        Row(
          textDirection: TextDirection.rtl,
          children: [
            Container(
              width: 4,
              height: 18,
              decoration: BoxDecoration(
                color: const Color(0xFFD4A843),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(width: 10),
            Text(
              'النشاطات الأخيرة',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: textColor,
              ),
            ),
          ],
        ),

        const SizedBox(height: 14),

        if (isEmpty)
          _EmptyActivities(isDark: isDark)
        else ...[
          // Hifz logs
          if (hifzLogs.isNotEmpty) ...[
            _SubHeader(
              label: 'سجلات الحفظ',
              icon: Icons.auto_stories_rounded,
              color: const Color(0xFF2E7D32),
              isDark: isDark,
            ),
            const SizedBox(height: 10),
            ...hifzLogs.map((log) => _HifzCard(log: log, isDark: isDark)),
            const SizedBox(height: 20),
          ],

          // Review logs
          if (reviewLogs.isNotEmpty) ...[
            _SubHeader(
              label: 'سجلات المراجعة',
              icon: Icons.replay_circle_filled_rounded,
              color: const Color(0xFF1565C0),
              isDark: isDark,
            ),
            const SizedBox(height: 10),
            ...reviewLogs.map((log) => _ReviewCard(log: log, isDark: isDark)),
          ],
        ],
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Sub-header with icon
// ─────────────────────────────────────────────────────────────────────────────
class _SubHeader extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color color;
  final bool isDark;

  const _SubHeader({
    required this.label,
    required this.icon,
    required this.color,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      textDirection: TextDirection.rtl,
      children: [
        Container(
          width: 28,
          height: 28,
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: color, size: 14),
        ),
        const SizedBox(width: 8),
        Text(
          label,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: isDark ? Colors.grey[400] : Colors.grey[600],
          ),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Hifz log card
// ─────────────────────────────────────────────────────────────────────────────
class _HifzCard extends StatelessWidget {
  final RecentHifzLogEntity log;
  final bool isDark;

  const _HifzCard({required this.log, required this.isDark});

  String _formatDate(String dateStr) {
    try {
      final date = DateTime.parse(dateStr);
      return intl.DateFormat('dd MMM', 'ar').format(date);
    } catch (_) {
      return dateStr;
    }
  }

  @override
  Widget build(BuildContext context) {
    const color = Color(0xFF2E7D32);
    final cardColor = isDark ? const Color(0xFF111D35) : Colors.white;
    final textColor =
        isDark ? const Color(0xFFF5EDD8) : const Color(0xFF1A1A2E);
    final subColor = isDark ? Colors.grey[500]! : Colors.grey[600]!;

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: color.withValues(alpha: 0.15)),
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
      child: Row(
        textDirection: TextDirection.rtl,
        children: [
          // Icon
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.auto_stories_rounded,
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
                Text(
                  log.studentName,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                    color: textColor,
                  ),
                  textDirection: TextDirection.rtl,
                ),
                const SizedBox(height: 3),
                Text(
                  '${log.surahName}  •  ${log.fromAyah} – ${log.toAyah}',
                  style: TextStyle(fontSize: 12, color: subColor),
                  textDirection: TextDirection.rtl,
                ),
                const SizedBox(height: 2),
                Text(
                  log.courseName,
                  style: TextStyle(
                    fontSize: 11,
                    color: subColor.withValues(alpha: 0.7),
                  ),
                  textDirection: TextDirection.rtl,
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          // Date badge
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              _formatDate(log.date),
              style: TextStyle(
                fontSize: 11,
                color: color,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Review log card
// ─────────────────────────────────────────────────────────────────────────────
class _ReviewCard extends StatelessWidget {
  final RecentReviewLogEntity log;
  final bool isDark;

  const _ReviewCard({required this.log, required this.isDark});

  String _formatDate(String dateStr) {
    try {
      final date = DateTime.parse(dateStr);
      return intl.DateFormat('dd MMM', 'ar').format(date);
    } catch (_) {
      return dateStr;
    }
  }

  @override
  Widget build(BuildContext context) {
    const color = Color(0xFF1565C0);
    final cardColor = isDark ? const Color(0xFF111D35) : Colors.white;
    final textColor =
        isDark ? const Color(0xFFF5EDD8) : const Color(0xFF1A1A2E);
    final subColor = isDark ? Colors.grey[500]! : Colors.grey[600]!;

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: color.withValues(alpha: 0.15)),
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
      child: Row(
        textDirection: TextDirection.rtl,
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.replay_circle_filled_rounded,
              color: color,
              size: 22,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  log.studentName,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                    color: textColor,
                  ),
                  textDirection: TextDirection.rtl,
                ),
                const SizedBox(height: 3),
                Text(
                  '${log.surahName}  •  ${log.fromAyah} – ${log.toAyah}',
                  style: TextStyle(fontSize: 12, color: subColor),
                  textDirection: TextDirection.rtl,
                ),
                const SizedBox(height: 2),
                Text(
                  log.courseName,
                  style: TextStyle(
                    fontSize: 11,
                    color: subColor.withValues(alpha: 0.7),
                  ),
                  textDirection: TextDirection.rtl,
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              _formatDate(log.date),
              style: TextStyle(
                fontSize: 11,
                color: color,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Empty state
// ─────────────────────────────────────────────────────────────────────────────
class _EmptyActivities extends StatelessWidget {
  final bool isDark;
  const _EmptyActivities({required this.isDark});

  @override
  Widget build(BuildContext context) {
    final cardColor = isDark ? const Color(0xFF111D35) : Colors.white;
    final subColor = isDark ? Colors.grey[500]! : Colors.grey[500]!;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 36, horizontal: 24),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0xFFD4A843).withValues(alpha: 0.15),
        ),
      ),
      child: Column(
        children: [
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              color: const Color(0xFFD4A843).withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.inbox_rounded,
              size: 32,
              color: const Color(0xFFD4A843).withValues(alpha: 0.7),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'لا توجد نشاطات حديثة',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: isDark ? const Color(0xFFF5EDD8) : const Color(0xFF1A1A2E),
            ),
            textDirection: TextDirection.rtl,
          ),
          const SizedBox(height: 6),
          Text(
            'ابدأ بإضافة أول سجل حفظ لطلابك',
            style: TextStyle(fontSize: 13, color: subColor),
            textDirection: TextDirection.rtl,
          ),
          const SizedBox(height: 20),
          ElevatedButton.icon(
            onPressed: () {
              showModalBottomSheet(
                context: context,
                isScrollControlled: true,
                backgroundColor: Colors.transparent,
                builder: (_) => StudentSelectorSheet(logType: LogType.hifz),
              );
            },
            icon: const Icon(Icons.add_rounded, size: 18),
            label: const Text('إضافة أول سجل'),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFD4A843),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
              elevation: 0,
            ),
          ),
        ],
      ),
    );
  }
}
