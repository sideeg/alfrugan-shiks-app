// lib/presentation/widgets/student_stats_widget.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:quran_sheikh_app/presentation/providers/logs_provider.dart';

class StudentStatsWidget extends ConsumerWidget {
  final int studentId;
  final int courseId;

  const StudentStatsWidget({
    required this.studentId,
    required this.courseId,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final params = HifzLogsParams(studentId: studentId, courseId: courseId);
    final hifzLogs = ref.watch(hifzLogsProvider(params));
    final reviewLogs = ref.watch(reviewLogsProvider(params));

    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'إحصائيات الطالب',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildStatCard(
                  'سجلات التسميع',
                  hifzLogs.when(
                    data: (logs) => logs.length.toString(),
                    loading: () => '...',
                    error: (_, __) => '0',
                  ),
                  Colors.blue,
                  Icons.book,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildStatCard(
                  'سجلات المراجعة',
                  reviewLogs.when(
                    data: (logs) => logs.length.toString(),
                    loading: () => '...',
                    error: (_, __) => '0',
                  ),
                  Colors.orange,
                  Icons.refresh,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildStatCard(
                  'آخر تسميع',
                  hifzLogs.when(
                    data: (logs) => logs.isNotEmpty
                        ? _formatDate(logs.first.date)
                        : 'لا يوجد',
                    loading: () => '...',
                    error: (_, __) => 'خطأ',
                  ),
                  Colors.green,
                  Icons.schedule,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildStatCard(
                  'متوسط التقييم',
                  hifzLogs.when(
                    data: (logs) => logs.isNotEmpty
                        ? _calculateAverageRating(logs)
                        : 'لا يوجد',
                    loading: () => '...',
                    error: (_, __) => 'خطأ',
                  ),
                  Colors.purple,
                  Icons.star,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(
      String title, String value, Color color, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: color, size: 16),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    fontSize: 12,
                    color: color,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}';
  }

  String _calculateAverageRating(List logs) {
    if (logs.isEmpty) return 'لا يوجد';

    Map<String, int> ratingValues = {
      'excellent': 5,
      'very_good': 4,
      'good': 3,
      'acceptable': 2,
      'needs_improvement': 1,
    };

    int totalScore = 0;
    int validRatings = 0;

    for (var log in logs) {
      int? score = ratingValues[log.evaluation];
      if (score != null) {
        totalScore += score;
        validRatings++;
      }
    }

    if (validRatings == 0) return 'لا يوجد';

    double average = totalScore / validRatings;
    return '${average.toStringAsFixed(1)}/5';
  }
}
