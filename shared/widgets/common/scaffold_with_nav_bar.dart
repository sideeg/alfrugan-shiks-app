// Path: lib/shared/widgets/common/scaffold_with_nav_bar.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/route_constants.dart';
import '../../../presentation/screens/notifications/widgets/notification_badge.dart';

class ScaffoldWithNavBar extends ConsumerWidget {
  final Widget child;
  const ScaffoldWithNavBar({super.key, required this.child});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      body: child,
      bottomNavigationBar: const _BottomNav(),
    );
  }
}

class _BottomNav extends StatelessWidget {
  const _BottomNav();

  static const _routes = [
    RouteConstants.NOTIFICATIONS,
    RouteConstants.LOGS,
    RouteConstants.COURSES,
    RouteConstants.STUDENTS,
    RouteConstants.DASHBOARD,
    RouteConstants.PROFILE, // NEW
  ];

  int _locationToIndex(String location) {
    for (int i = 0; i < _routes.length; i++) {
      if (location.startsWith(_routes[i])) return i;
    }
    return 4; // default to dashboard
  }

  @override
  Widget build(BuildContext context) {
    final location = GoRouterState.of(context).matchedLocation;
    final currentIndex = _locationToIndex(location);

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 12,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 6),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              // ── Notifications (with badge) ───────────────────────────────
              _NavItem(
                customIcon: NotificationBadge(
                  child: Icon(
                    currentIndex == 0
                        ? Icons.notifications_rounded
                        : Icons.notifications_outlined,
                    color: currentIndex == 0
                        ? const Color(0xFF2E7D32)
                        : Colors.grey.shade600,
                    size: 24,
                  ),
                ),
                label: 'الإشعارات',
                isSelected: currentIndex == 0,
                onTap: () => context.go(_routes[0]),
              ),

              _NavItem(
                icon: Icons.edit_note_rounded,
                label: 'السجلات',
                isSelected: currentIndex == 1,
                onTap: () => context.go(_routes[1]),
              ),

              _NavItem(
                icon: Icons.menu_book_rounded,
                label: 'الدورات',
                isSelected: currentIndex == 2,
                onTap: () => context.go(_routes[2]),
              ),

              _NavItem(
                icon: Icons.people_rounded,
                label: 'الطلاب',
                isSelected: currentIndex == 3,
                onTap: () => context.go(_routes[3]),
              ),

              _NavItem(
                icon: Icons.dashboard_rounded,
                label: 'الرئيسية',
                isSelected: currentIndex == 4,
                onTap: () => context.go(_routes[4]),
              ),

              // ── Profile (NEW) ────────────────────────────────────────────
              _NavItem(
                icon: currentIndex == 5
                    ? Icons.person_rounded
                    : Icons.person_outline_rounded,
                label: 'حسابي',
                isSelected: currentIndex == 5,
                onTap: () => context.go(_routes[5]),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  final IconData? icon;
  final Widget? customIcon;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _NavItem({
    this.icon,
    this.customIcon,
    required this.label,
    required this.isSelected,
    required this.onTap,
  }) : assert(icon != null || customIcon != null);

  @override
  Widget build(BuildContext context) {
    final color = isSelected ? const Color(0xFF2E7D32) : Colors.grey.shade600;

    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected
              ? const Color(0xFF2E7D32).withOpacity(0.1)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            customIcon ?? Icon(icon!, color: color, size: 22),
            const SizedBox(height: 3),
            Text(
              label,
              style: TextStyle(
                fontSize: 9,
                fontFamily: 'Cairo',
                color: color,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
