// Path: lib/presentation/screens/notifications/widgets/notification_badge.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../providers/notifications_provider.dart';

/// A small red badge that wraps any widget (typically an Icon) and overlays
/// the unread notification count in the top-right corner.
///
/// Usage inside the bottom nav bar:
/// ```dart
/// NotificationBadge(child: Icon(Icons.notifications_outlined))
/// ```
///
/// Automatically hides when count is 0. Shows "99+" when count > 99.
class NotificationBadge extends ConsumerWidget {
  final Widget child;

  const NotificationBadge({super.key, required this.child});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Only watches the lightweight int provider — not the full list.
    final count = ref.watch(unreadCountProvider);

    return Stack(
      clipBehavior: Clip.none,
      children: [
        child,
        if (count > 0)
          Positioned(
            top: -4,
            right: -6,
            child: AnimatedScale(
              duration: const Duration(milliseconds: 200),
              scale: count > 0 ? 1.0 : 0.0,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 5,
                  vertical: 2,
                ),
                constraints: const BoxConstraints(minWidth: 18, minHeight: 18),
                decoration: BoxDecoration(
                  color: const Color(0xFFD32F2F), // Material red 700
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: Colors.white, width: 1.5),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.red.withOpacity(0.3),
                      blurRadius: 4,
                      offset: const Offset(0, 1),
                    ),
                  ],
                ),
                child: Text(
                  count > 99 ? '99+' : count.toString(),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 9,
                    fontWeight: FontWeight.bold,
                    height: 1.1,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          ),
      ],
    );
  }
}
