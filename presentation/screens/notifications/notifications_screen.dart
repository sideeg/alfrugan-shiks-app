// Path: lib/presentation/screens/notifications/notifications_screen.dart

import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart' hide TextDirection;

import '../../../domain/entities/notifications/notification_entity.dart';
import '../../providers/notifications_provider.dart';

// ─── Palette (matches profile_screen exactly) ─────────────────────────────────
const _gold = Color(0xFFD4A843);
const _goldDeep = Color(0xFFB8860B);
const _navy = Color(0xFF0B1120);
const _navyMid = Color(0xFF111D35);
const _navyLight = Color(0xFF1A2A4A);
const _cream = Color(0xFFF5EDD8);
const _lightBg = Color(0xFFF2F4F8);
const _lightCard = Color(0xFFFFFFFF);

class NotificationsScreen extends ConsumerStatefulWidget {
  const NotificationsScreen({super.key});

  @override
  ConsumerState<NotificationsScreen> createState() =>
      _NotificationsScreenState();
}

class _NotificationsScreenState extends ConsumerState<NotificationsScreen>
    with SingleTickerProviderStateMixin {
  final _scrollController = ScrollController();
  late final AnimationController _headerCtrl;
  late final Animation<double> _headerFade;

  @override
  void initState() {
    super.initState();

    _headerCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 600));
    _headerFade = CurvedAnimation(parent: _headerCtrl, curve: Curves.easeOut);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(notificationsProvider.notifier).loadNotifications();
      ref.read(unreadCountProvider.notifier).reset();
      _headerCtrl.forward();
    });

    _scrollController.addListener(_onScroll);
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      ref.read(notificationsProvider.notifier).loadMore();
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _headerCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(notificationsProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final hasUnread = state.notifications.any((n) => n.isUnread);

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: Scaffold(
        backgroundColor: isDark ? _navy : _lightBg,
        body: RefreshIndicator(
          color: _gold,
          backgroundColor: isDark ? _navyMid : _lightCard,
          onRefresh: () => ref.read(notificationsProvider.notifier).refresh(),
          child: CustomScrollView(
            controller: _scrollController,
            physics: const AlwaysScrollableScrollPhysics(),
            slivers: [
              // ── Hero app bar ─────────────────────────────────────────────
              SliverToBoxAdapter(
                child: FadeTransition(
                  opacity: _headerFade,
                  child: _NotifHero(
                    isDark: isDark,
                    hasUnread: hasUnread,
                    onMarkAll: () {
                      ref.read(notificationsProvider.notifier).markAllAsRead();
                      ref.read(unreadCountProvider.notifier).reset();
                    },
                  ),
                ),
              ),

              // ── Content ──────────────────────────────────────────────────
              if (state.isLoading)
                SliverToBoxAdapter(child: _SkeletonList(isDark: isDark))
              else if (state.errorMessage != null &&
                  state.notifications.isEmpty)
                SliverFillRemaining(
                  child: _ErrorState(
                    isDark: isDark,
                    message: state.errorMessage!,
                    onRetry: () =>
                        ref.read(notificationsProvider.notifier).refresh(),
                  ),
                )
              else if (state.notifications.isEmpty)
                SliverFillRemaining(child: _EmptyState(isDark: isDark))
              else ...[
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(16, 4, 16, 4),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        if (index == state.notifications.length) {
                          return state.isLoadingMore
                              ? Padding(
                                  padding: const EdgeInsets.all(20),
                                  child: Center(
                                    child: SizedBox(
                                      width: 24,
                                      height: 24,
                                      child: CircularProgressIndicator(
                                        color: _gold,
                                        strokeWidth: 2,
                                      ),
                                    ),
                                  ),
                                )
                              : const SizedBox(height: 32);
                        }

                        final notif = state.notifications[index];
                        // Group by date — show date header when day changes
                        final showDate = index == 0 ||
                            !_sameDay(
                              state.notifications[index - 1].sentAt ??
                                  state.notifications[index - 1].createdAt,
                              notif.sentAt ?? notif.createdAt,
                            );

                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            if (showDate)
                              _DateHeader(
                                date: notif.sentAt ?? notif.createdAt,
                                isDark: isDark,
                              ),
                            _NotifCard(
                              notification: notif,
                              isDark: isDark,
                              onTap: () => _onTap(notif),
                            ),
                          ],
                        );
                      },
                      childCount: state.notifications.length + 1,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  void _onTap(NotificationEntity notification) {
    if (notification.isUnread) {
      ref.read(notificationsProvider.notifier).markAsRead(notification.id);
      ref.read(unreadCountProvider.notifier).decrementBy(1);
    }
  }

  bool _sameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;
}

// ─── Hero header ──────────────────────────────────────────────────────────────
class _NotifHero extends StatelessWidget {
  final bool isDark;
  final bool hasUnread;
  final VoidCallback onMarkAll;

  const _NotifHero({
    required this.isDark,
    required this.hasUnread,
    required this.onMarkAll,
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
          // Star watermarks — same as profile hero
          Positioned(
            right: -40,
            top: -40,
            child: CustomPaint(
              size: const Size(180, 180),
              painter: _StarBg(color: _gold.withValues(alpha: 0.05)),
            ),
          ),
          Positioned(
            left: -20,
            bottom: 0,
            child: CustomPaint(
              size: const Size(110, 110),
              painter: _StarBg(color: _gold.withValues(alpha: 0.04)),
            ),
          ),
          // Top gold line ornament
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: Container(
              height: 3,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.centerRight,
                  end: Alignment.centerLeft,
                  colors: [
                    _gold.withValues(alpha: 0.0),
                    _gold,
                    _gold.withValues(alpha: 0.0),
                  ],
                ),
              ),
            ),
          ),

          SafeArea(
            bottom: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 14, 20, 28),
              child: Column(
                children: [
                  // Title row
                  Row(
                    textDirection: TextDirection.rtl,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Back / nav area (empty — inside shell)
                      const SizedBox(width: 36),

                      // Screen title
                      Text(
                        'الإشعارات',
                        style: TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.bold,
                          color: _cream.withValues(alpha: 0.9),
                        ),
                      ),

                      // Mark all read button
                      if (hasUnread)
                        GestureDetector(
                          onTap: onMarkAll,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 6),
                            decoration: BoxDecoration(
                              color: _gold.withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(
                                  color: _gold.withValues(alpha: 0.35)),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(Icons.done_all_rounded,
                                    size: 13, color: _gold),
                                const SizedBox(width: 4),
                                const Text('قراءة الكل',
                                    style: TextStyle(
                                        fontSize: 11,
                                        fontWeight: FontWeight.bold,
                                        color: _gold)),
                              ],
                            ),
                          ),
                        )
                      else
                        const SizedBox(width: 36),
                    ],
                  ),

                  const SizedBox(height: 20),

                  // Bell icon in gold ring — echoes the avatar ring in profile
                  Stack(
                    alignment: Alignment.center,
                    children: [
                      Container(
                        width: 72,
                        height: 72,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                              color: _gold.withValues(alpha: 0.35), width: 2),
                        ),
                      ),
                      Container(
                        width: 62,
                        height: 62,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                              color: _gold.withValues(alpha: 0.15), width: 1),
                        ),
                      ),
                      Container(
                        width: 54,
                        height: 54,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: const LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [Color(0xFF2A4A7C), _navyLight],
                          ),
                        ),
                        child: const Icon(
                          Icons.notifications_rounded,
                          size: 26,
                          color: _gold,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 14),

                  // Arabic calligraphic subtitle
                  Text(
                    'بسم الله الرحمن الرحيم',
                    style: TextStyle(
                      fontSize: 13,
                      color: _gold.withValues(alpha: 0.75),
                      fontFamily: 'Amiri',
                      letterSpacing: 0.5,
                    ),
                  ),

                  const SizedBox(height: 18),

                  // Ornamental divider — same as profile
                  Row(children: [
                    Expanded(
                        child: Container(
                            height: 1, color: _gold.withValues(alpha: 0.2))),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 10),
                      child: Container(
                          width: 6,
                          height: 6,
                          decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: _gold.withValues(alpha: 0.6))),
                    ),
                    Expanded(
                        child: Container(
                            height: 1, color: _gold.withValues(alpha: 0.2))),
                  ]),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Date header ──────────────────────────────────────────────────────────────
class _DateHeader extends StatelessWidget {
  final DateTime date;
  final bool isDark;
  const _DateHeader({required this.date, required this.isDark});

  String _label() {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final d = DateTime(date.year, date.month, date.day);
    if (d == today) return 'اليوم';
    if (d == today.subtract(const Duration(days: 1))) return 'أمس';
    return DateFormat('d MMMM yyyy', 'ar').format(date);
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 20, bottom: 8),
      child: Row(
        textDirection: TextDirection.rtl,
        children: [
          Container(
              width: 3,
              height: 14,
              decoration: BoxDecoration(
                  color: _gold, borderRadius: BorderRadius.circular(2))),
          const SizedBox(width: 8),
          Text(
            _label(),
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: isDark ? _gold.withValues(alpha: 0.8) : _goldDeep,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Container(height: 1, color: _gold.withValues(alpha: 0.15)),
          ),
        ],
      ),
    );
  }
}

// ─── Notification card ────────────────────────────────────────────────────────
class _NotifCard extends StatelessWidget {
  final NotificationEntity notification;
  final bool isDark;
  final VoidCallback onTap;

  const _NotifCard({
    required this.notification,
    required this.isDark,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final cfg = _NotifConfig.from(notification.type);
    final isUnread = notification.isUnread;
    final cardBg = isDark ? _navyMid : _lightCard;

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      // IMPORTANT: This clips the inner stripe so it rounds perfectly with the corners
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: isUnread
            ? (isDark
                ? cfg.color.withValues(alpha: 0.08)
                : cfg.color.withValues(alpha: 0.04))
            : cardBg,
        borderRadius: BorderRadius.circular(16),
        // FIX: Border is now perfectly uniform to prevent the exception
        border: Border.all(
          color: _gold.withValues(alpha: 0.1),
          width: 1,
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
      child: Stack(
        children: [
          // 1. Main Content
          Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: onTap,
              // No border radius needed here since the parent Container clips it
              child: Padding(
                padding: const EdgeInsets.all(14),
                child: Row(
                  textDirection: TextDirection.rtl,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Icon badge — gold ring on unread
                    _IconBadge(config: cfg, isUnread: isUnread, isDark: isDark),

                    const SizedBox(width: 12),

                    // Content
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          // Title + unread dot
                          Row(
                            textDirection: TextDirection.rtl,
                            children: [
                              Expanded(
                                child: Text(
                                  notification.title,
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: isUnread
                                        ? FontWeight.bold
                                        : FontWeight.w500,
                                    color: isDark ? _cream : _navy,
                                    height: 1.4,
                                  ),
                                  textDirection: TextDirection.rtl,
                                ),
                              ),
                              if (isUnread) ...[
                                const SizedBox(width: 6),
                                Container(
                                  width: 7,
                                  height: 7,
                                  decoration: BoxDecoration(
                                      color: cfg.color, shape: BoxShape.circle),
                                ),
                              ],
                            ],
                          ),

                          const SizedBox(height: 4),

                          // Message body
                          Text(
                            notification.message,
                            style: TextStyle(
                              fontSize: 12,
                              color:
                                  isDark ? Colors.grey[400] : Colors.grey[600],
                              height: 1.5,
                            ),
                            textDirection: TextDirection.rtl,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),

                          const SizedBox(height: 8),

                          // Footer: time + type chip
                          Row(
                            textDirection: TextDirection.rtl,
                            children: [
                              // Type chip — gold-tinted
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 8, vertical: 3),
                                decoration: BoxDecoration(
                                  color: cfg.color.withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(6),
                                  border: Border.all(
                                      color: cfg.color.withValues(alpha: 0.25)),
                                ),
                                child: Text(
                                  cfg.label,
                                  style: TextStyle(
                                    fontSize: 10,
                                    color: cfg.color,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),

                              const Spacer(),

                              // Time
                              Icon(
                                Icons.access_time_rounded,
                                size: 11,
                                color: isDark
                                    ? Colors.grey[600]
                                    : Colors.grey[400],
                              ),
                              const SizedBox(width: 3),
                              Text(
                                _timeLabel(notification.sentAt ??
                                    notification.createdAt),
                                style: TextStyle(
                                  fontSize: 10,
                                  color: isDark
                                      ? Colors.grey[600]
                                      : Colors.grey[400],
                                ),
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

          // 2. The Right-side Accent Stripe (Visual "Start" in Arabic)
          if (isUnread)
            Positioned(
              top: 0,
              bottom: 0,
              right: 0,
              child: Container(
                width: 3,
                color: cfg.color,
              ),
            ),
        ],
      ),
    );
  }

  String _timeLabel(DateTime dt) {
    final diff = DateTime.now().difference(dt);
    if (diff.inMinutes < 1) return 'الآن';
    if (diff.inMinutes < 60) return 'منذ ${diff.inMinutes}د';
    if (diff.inHours < 24) return 'منذ ${diff.inHours}س';
    return DateFormat('h:mm a', 'ar').format(dt);
  }
}

// ─── Icon badge ───────────────────────────────────────────────────────────────
class _IconBadge extends StatelessWidget {
  final _NotifConfig config;
  final bool isUnread;
  final bool isDark;
  const _IconBadge(
      {required this.config, required this.isUnread, required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Outer ring — echoes profile avatar rings
        if (isUnread)
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                  color: config.color.withValues(alpha: 0.3), width: 1.5),
            ),
          ),
        Positioned.fill(
          child: Center(
            child: Container(
              width: isUnread ? 40 : 44,
              height: isUnread ? 40 : 44,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: config.color.withValues(alpha: isUnread ? 0.15 : 0.08),
              ),
              child: Icon(
                config.icon,
                size: 20,
                color: config.color.withValues(alpha: isUnread ? 1.0 : 0.65),
              ),
            ),
          ),
        ),
        if (isUnread)
          const SizedBox(width: 48, height: 48)
        else
          const SizedBox(width: 44, height: 44),
      ],
    );
  }
}

// ─── Type config ──────────────────────────────────────────────────────────────
class _NotifConfig {
  final IconData icon;
  final Color color;
  final String label;

  const _NotifConfig(
      {required this.icon, required this.color, required this.label});

  factory _NotifConfig.from(String type) {
    switch (type) {
      case 'course_end':
        return const _NotifConfig(
            icon: Icons.verified, color: Colors.green, label: 'اكتمال الدورة');
      case 'new_student':
        return const _NotifConfig(
          icon: Icons.person_add_rounded,
          color: Color(0xFF2E7D32),
          label: 'طالب جديد',
        );
      case 'enrollment':
        return const _NotifConfig(
          icon: Icons.assignment_turned_in_rounded,
          color: Color(0xFF1565C0),
          label: 'التحاق',
        );
      case 'course_start':
        return const _NotifConfig(
          icon: Icons.play_circle_rounded,
          color: Color(0xFF00695C),
          label: 'بداية الدورة',
        );
      case 'course_end':
        return const _NotifConfig(
          icon: Icons.check_circle_rounded,
          color: Color(0xFF546E7A),
          label: 'نهاية الدورة',
        );
      case 'custom_broadcast':
      default:
        return const _NotifConfig(
          icon: Icons.campaign_rounded,
          color: _gold,
          label: 'إشعار عام',
        );
    }
  }
}

// ─── Skeleton loading ─────────────────────────────────────────────────────────
class _SkeletonList extends StatelessWidget {
  final bool isDark;
  const _SkeletonList({required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
      child: Column(
        children: List.generate(
          5,
          (_) => Container(
            margin: const EdgeInsets.only(bottom: 10),
            height: 88,
            decoration: BoxDecoration(
              color: isDark ? _navyMid : _lightCard,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: _gold.withValues(alpha: 0.1)),
            ),
            child: Row(
              textDirection: TextDirection.rtl,
              children: [
                const SizedBox(width: 14),
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: isDark ? _navyLight : Colors.grey.shade200,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Container(
                        height: 12,
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: isDark ? _navyLight : Colors.grey.shade200,
                          borderRadius: BorderRadius.circular(6),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Container(
                        height: 10,
                        width: 180,
                        decoration: BoxDecoration(
                          color: isDark
                              ? _navyLight.withValues(alpha: 0.6)
                              : Colors.grey.shade100,
                          borderRadius: BorderRadius.circular(6),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 14),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ─── Empty state ──────────────────────────────────────────────────────────────
class _EmptyState extends StatelessWidget {
  final bool isDark;
  const _EmptyState({required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Bell in triple ring — echoes profile avatar
            Stack(
              alignment: Alignment.center,
              children: [
                Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                        color: _gold.withValues(alpha: 0.2), width: 2),
                  ),
                ),
                Container(
                  width: 82,
                  height: 82,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                        color: _gold.withValues(alpha: 0.1), width: 1),
                  ),
                ),
                Container(
                  width: 66,
                  height: 66,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: _gold.withValues(alpha: 0.08),
                  ),
                  child: Icon(
                    Icons.notifications_none_rounded,
                    size: 32,
                    color: _gold.withValues(alpha: 0.6),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 24),

            Text(
              'لا توجد إشعارات',
              style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.bold,
                color: isDark ? _cream : _navy,
              ),
            ),

            const SizedBox(height: 8),

            Text(
              'ستظهر هنا إشعارات الطلاب والدورات',
              style: TextStyle(
                fontSize: 13,
                color: isDark ? Colors.grey[500] : Colors.grey[500],
              ),
              textAlign: TextAlign.center,
              textDirection: TextDirection.rtl,
            ),

            const SizedBox(height: 20),

            // Ornamental divider
            Row(children: [
              Expanded(
                  child: Container(
                      height: 1, color: _gold.withValues(alpha: 0.15))),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10),
                child: Container(
                    width: 5,
                    height: 5,
                    decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: _gold.withValues(alpha: 0.4))),
              ),
              Expanded(
                  child: Container(
                      height: 1, color: _gold.withValues(alpha: 0.15))),
            ]),
          ],
        ),
      ),
    );
  }
}

// ─── Error state ──────────────────────────────────────────────────────────────
class _ErrorState extends StatelessWidget {
  final bool isDark;
  final String message;
  final VoidCallback onRetry;
  const _ErrorState(
      {required this.isDark, required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 70,
              height: 70,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0xFFE53935).withValues(alpha: 0.1),
                border: Border.all(
                    color: const Color(0xFFE53935).withValues(alpha: 0.2)),
              ),
              child: const Icon(Icons.cloud_off_rounded,
                  size: 32, color: Color(0xFFE53935)),
            ),
            const SizedBox(height: 16),
            Text('تعذّر جلب الإشعارات',
                style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: isDark ? _cream : _navy),
                textDirection: TextDirection.rtl),
            const SizedBox(height: 8),
            Text(message,
                style: TextStyle(
                    fontSize: 12,
                    color: isDark ? Colors.grey[500] : Colors.grey[500]),
                textAlign: TextAlign.center),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh_rounded, size: 16),
              label: const Text('إعادة المحاولة'),
              style: ElevatedButton.styleFrom(
                backgroundColor: _gold,
                foregroundColor: Colors.white,
                padding:
                    const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
                elevation: 0,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Star background painter (identical to profile_screen) ────────────────────
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
