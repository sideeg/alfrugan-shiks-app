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
    RouteConstants.DASHBOARD,
    RouteConstants.LOGS,
    RouteConstants.COURSES,
    RouteConstants.STUDENTS,
    RouteConstants.NOTIFICATIONS,
    RouteConstants.PROFILE,
  ];

  int _locationToIndex(String location) {
    for (int i = 0; i < _routes.length; i++) {
      if (location.startsWith(_routes[i])) return i;
    }
    return 4;
  }

  @override
  Widget build(BuildContext context) {
    final location = GoRouterState.of(context).matchedLocation;
    final currentIndex = _locationToIndex(location);
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
        boxShadow: [
          BoxShadow(
            color: isDark
                ? Colors.black.withOpacity(0.3)
                : Colors.black.withOpacity(0.08),
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
              _NavItem(
                icon: Icons.dashboard_rounded,
                label: 'الرئيسية',
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
                customIcon: NotificationBadge(
                  child: Icon(
                    currentIndex == 0
                        ? Icons.notifications_rounded
                        : Icons.notifications_outlined,
                    color: currentIndex == 4
                        ? theme.colorScheme.primary
                        : isDark
                            ? Colors.grey.shade400
                            : Colors.grey.shade600,
                    size: 24,
                  ),
                ),
                label: 'الإشعارات',
                isSelected: currentIndex == 4,
                onTap: () => context.go(_routes[4]),
              ),
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

class _NavItem extends StatefulWidget {
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
  State<_NavItem> createState() => _NavItemState();
}

class _NavItemState extends State<_NavItem>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _bounceAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(begin: 1.0, end: 1.15).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeOutBack,
      ),
    );

    _bounceAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.6, curve: Curves.elasticOut),
      ),
    );

    if (widget.isSelected) {
      _controller.value = 1.0;
    }
  }

  @override
  void didUpdateWidget(_NavItem oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isSelected && !oldWidget.isSelected) {
      _controller.forward(from: 0.0);
    } else if (!widget.isSelected && oldWidget.isSelected) {
      _controller.reverse();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final primaryColor = theme.colorScheme.primary;

    final color = widget.isSelected
        ? primaryColor
        : isDark
            ? Colors.grey.shade400
            : Colors.grey.shade600;

    return GestureDetector(
      onTap: () {
        if (!widget.isSelected) {
          _controller.forward(from: 0.0);
        }
        widget.onTap();
      },
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeInOut,
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
        decoration: BoxDecoration(
          color: widget.isSelected
              ? primaryColor.withOpacity(isDark ? 0.15 : 0.1)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AnimatedBuilder(
              animation: _controller,
              builder: (context, child) {
                return Transform.scale(
                  scale: widget.isSelected ? _scaleAnimation.value : 1.0,
                  child: widget.customIcon ??
                      Icon(widget.icon!, color: color, size: 22),
                );
              },
            ),
            const SizedBox(height: 3),
            AnimatedDefaultTextStyle(
              duration: const Duration(milliseconds: 200),
              style: TextStyle(
                fontSize: 9,
                fontFamily: 'Cairo',
                color: color,
                fontWeight:
                    widget.isSelected ? FontWeight.bold : FontWeight.normal,
              ),
              child: Text(widget.label),
            ),
            const SizedBox(height: 2),
            AnimatedBuilder(
              animation: _bounceAnimation,
              builder: (context, child) {
                return Transform.scale(
                  scale: widget.isSelected ? _bounceAnimation.value : 0,
                  child: Container(
                    width: 4,
                    height: 4,
                    decoration: BoxDecoration(
                      color: primaryColor,
                      shape: BoxShape.circle,
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
