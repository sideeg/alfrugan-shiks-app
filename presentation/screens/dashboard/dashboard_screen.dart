// Path: lib/presentation/screens/dashboard/dashboard_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../providers/auth_provider.dart';
import '../../providers/dashboard_provider.dart';
import '../../providers/notifications_provider.dart';
import 'widgets/dashboard_stats_widget.dart';
import 'widgets/quick_actions_widget.dart';
import 'widgets/recent_activities_widget.dart';

const kDGold = Color(0xFFD4A843);
const kDNavy = Color(0xFF0B1120);
const kDNavyMid = Color(0xFF111D35);
const kDCream = Color(0xFFF5EDD8);
const kDLightBg = Color(0xFFF2F4F8);
const kDLightCard = Color(0xFFFFFFFF);

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({Key? key}) : super(key: key);

  String _greeting() {
    final h = DateTime.now().hour;
    if (h >= 5 && h < 12) return 'صباح الخير';
    if (h >= 12 && h < 17) return 'مساء الخير';
    if (h >= 17 && h < 20) return 'مساء النور';
    return 'أهلاً بك';
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authProvider).user;
    final dashboardAsync = ref.watch(dashboardWithRefreshProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // When dashboard data loads, sync the unread count from it.
    // This replaces the separate /notifications/unread/count call.
    ref.listen(dashboardWithRefreshProvider, (prev, next) {
      next.whenData((dashboard) {
        final count = dashboard.unreadNotificationsCount;
        // Only update if the value differs — avoids unnecessary rebuilds
        if (ref.read(unreadCountProvider) != count) {
          ref.read(unreadCountProvider.notifier).state = count;
        }
      });
    });

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: isDark ? SystemUiOverlayStyle.light : SystemUiOverlayStyle.dark,
      child: Scaffold(
        backgroundColor: isDark ? kDNavy : kDLightBg,
        body: SafeArea(
          child: Column(
            children: [
              _TopBar(isDark: isDark),
              Expanded(
                child: RefreshIndicator(
                  color: kDGold,
                  backgroundColor: isDark ? kDNavyMid : kDLightCard,
                  onRefresh: () async {
                    // Pull-to-refresh reloads the dashboard which
                    // automatically re-syncs the badge count via the listener above
                    ref.read(dashboardRefreshProvider.notifier).state++;
                  },
                  child: dashboardAsync.when(
                    data: (dashboard) => SingleChildScrollView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      padding: const EdgeInsets.fromLTRB(16, 0, 16, 32),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          _GreetingBar(
                            name: user?.name ?? 'الشيخ الكريم',
                            greeting: _greeting(),
                            isDark: isDark,
                          ),
                          const SizedBox(height: 20),
                          DashboardStatsWidget(
                              stats: dashboard.stats, isDark: isDark),
                          const SizedBox(height: 24),
                          QuickActionsWidget(isDark: isDark),
                          const SizedBox(height: 24),
                          RecentActivitiesWidget(
                            hifzLogs: dashboard.recentHifzLogs,
                            reviewLogs: dashboard.recentReviewLogs,
                            isDark: isDark,
                          ),
                        ],
                      ),
                    ),
                    loading: () => const Center(
                        child: CircularProgressIndicator(color: kDGold)),
                    error: (err, _) => _ErrorBody(
                      error: err.toString(),
                      isDark: isDark,
                      onRetry: () =>
                          ref.read(dashboardRefreshProvider.notifier).state++,
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

// ─── Top bar ──────────────────────────────────────────────────────────────────
class _TopBar extends ConsumerWidget {
  final bool isDark;
  const _TopBar({required this.isDark});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final unreadCount = ref.watch(unreadCountProvider);

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 6),
      child: Row(
        textDirection: TextDirection.rtl,
        children: [
          // ── Logo ────────────────────────────────────────────────────────
          Container(
            width: 34,
            height: 34,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(9),
              border: Border.all(color: kDGold.withValues(alpha: 0.45)),
              color: isDark ? kDNavyMid : Colors.white,
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.asset(
                'assets/icons/logo.png',
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => const Icon(
                    Icons.menu_book_rounded,
                    size: 16,
                    color: kDGold),
              ),
            ),
          ),
          const SizedBox(width: 8),
          Text(
            'تطبيق الشيوخ',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.bold,
              color: isDark ? kDCream : kDNavy,
            ),
          ),

          const Spacer(),

          // ── Notification Bell with Badge ──────────────────────────────
          GestureDetector(
            onTap: () {
              context.go('/notifications');
              // Reset badge immediately on tap — the notification screen
              // will call mark-all-read on the backend
              ref.read(unreadCountProvider.notifier).reset();
            },
            child: Container(
              width: 34,
              height: 34,
              decoration: BoxDecoration(
                color: isDark ? kDNavyMid : Colors.white,
                borderRadius: BorderRadius.circular(9),
                border: Border.all(color: kDGold.withValues(alpha: 0.2)),
              ),
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  Center(
                    child: Icon(
                      unreadCount > 0
                          ? Icons.notifications_rounded
                          : Icons.notifications_outlined,
                      size: 17,
                      color: unreadCount > 0
                          ? kDGold
                          : (isDark ? kDCream : kDNavy),
                    ),
                  ),
                  if (unreadCount > 0)
                    Positioned(
                      top: -4,
                      left: -4,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 4, vertical: 1),
                        constraints:
                            const BoxConstraints(minWidth: 16, minHeight: 16),
                        decoration: BoxDecoration(
                          color: const Color(0xFFD32F2F),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: isDark ? kDNavyMid : Colors.white,
                            width: 1.5,
                          ),
                        ),
                        child: Text(
                          unreadCount > 99 ? '99+' : unreadCount.toString(),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 8,
                            fontWeight: FontWeight.bold,
                            height: 1.2,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),

          const SizedBox(width: 6),
          _Btn(Icons.person_outline_rounded, isDark,
              () => context.go('/profile')),
          const SizedBox(width: 6),
          _Btn(Icons.logout_rounded, isDark, () => _confirmLogout(context, ref),
              color: const Color(0xFFE53935)),
        ],
      ),
    );
  }

  void _confirmLogout(BuildContext ctx, WidgetRef ref) {
    showDialog(
      context: ctx,
      builder: (dialogCtx) => AlertDialog(
        backgroundColor: isDark ? kDNavyMid : kDLightCard,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text('تسجيل الخروج',
            textDirection: TextDirection.rtl,
            style: TextStyle(color: isDark ? kDCream : kDNavy)),
        content: Text('هل أنت متأكد من الخروج؟',
            textDirection: TextDirection.rtl,
            style: TextStyle(
                color: isDark
                    ? kDCream.withValues(alpha: 0.6)
                    : Colors.grey[600])),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogCtx).pop(),
            child: Text('إلغاء',
                style: TextStyle(color: isDark ? kDCream : kDNavy)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFE53935),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
            ),
            onPressed: () async {
              Navigator.of(dialogCtx).pop();
              await ref.read(authProvider.notifier).logout();
              if (ctx.mounted) ctx.go('/login');
            },
            child: const Text('خروج'),
          ),
        ],
      ),
    );
  }
}

class _Btn extends StatelessWidget {
  final IconData icon;
  final bool isDark;
  final VoidCallback onTap;
  final Color? color;
  const _Btn(this.icon, this.isDark, this.onTap, {this.color});

  @override
  Widget build(BuildContext context) {
    final c = color ?? (isDark ? kDCream : kDNavy);
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 34,
        height: 34,
        decoration: BoxDecoration(
          color: isDark ? kDNavyMid : Colors.white,
          borderRadius: BorderRadius.circular(9),
          border: Border.all(color: (color ?? kDGold).withValues(alpha: 0.2)),
        ),
        child: Icon(icon, size: 17, color: c),
      ),
    );
  }
}

// ─── Greeting ─────────────────────────────────────────────────────────────────
class _GreetingBar extends StatelessWidget {
  final String name;
  final String greeting;
  final bool isDark;
  const _GreetingBar(
      {required this.name, required this.greeting, required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: isDark ? kDNavyMid : kDLightCard,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: kDGold.withValues(alpha: 0.2)),
        boxShadow: [
          BoxShadow(
            color: isDark
                ? Colors.black.withValues(alpha: 0.3)
                : Colors.black.withValues(alpha: 0.05),
            blurRadius: 14,
            offset: const Offset(0, 4),
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
              shape: BoxShape.circle,
              gradient: const LinearGradient(
                colors: [kDGold, Color(0xFFB8860B)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              boxShadow: [
                BoxShadow(
                  color: kDGold.withValues(alpha: 0.35),
                  blurRadius: 10,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child:
                const Icon(Icons.person_rounded, color: Colors.white, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(greeting,
                    style: TextStyle(
                        fontSize: 11,
                        color: kDGold.withValues(alpha: 0.85),
                        fontWeight: FontWeight.w500),
                    textDirection: TextDirection.rtl),
                const SizedBox(height: 2),
                Text(name,
                    style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: isDark ? kDCream : kDNavy),
                    textDirection: TextDirection.rtl,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: kDGold.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: kDGold.withValues(alpha: 0.3)),
            ),
            child: const Text('بسم الله',
                style: TextStyle(
                    fontSize: 11, color: kDGold, fontWeight: FontWeight.w600)),
          ),
        ],
      ),
    );
  }
}

// ─── Error ────────────────────────────────────────────────────────────────────
class _ErrorBody extends StatelessWidget {
  final String error;
  final bool isDark;
  final VoidCallback onRetry;
  const _ErrorBody(
      {required this.error, required this.isDark, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(32),
        child: Column(
          children: [
            Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                color: const Color(0xFFE53935).withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.error_outline_rounded,
                  size: 36, color: Color(0xFFE53935)),
            ),
            const SizedBox(height: 16),
            Text('حدث خطأ في تحميل البيانات',
                style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: isDark ? kDCream : kDNavy),
                textDirection: TextDirection.rtl,
                textAlign: TextAlign.center),
            const SizedBox(height: 8),
            Text(error,
                style: TextStyle(
                    fontSize: 13,
                    color: isDark ? Colors.grey[400] : Colors.grey[600]),
                textAlign: TextAlign.center),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh_rounded, size: 18),
              label: const Text('إعادة المحاولة'),
              style: ElevatedButton.styleFrom(
                backgroundColor: kDGold,
                foregroundColor: Colors.white,
                padding:
                    const EdgeInsets.symmetric(horizontal: 28, vertical: 14),
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
