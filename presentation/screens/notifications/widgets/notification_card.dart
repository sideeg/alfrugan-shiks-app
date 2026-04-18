// Path: lib/presentation/screens/notifications/widgets/notification_card.dart

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../../domain/entities/notifications/notification_entity.dart';

/// A single notification card in the sheikh's notification list.
///
/// Visual states:
///   Unread → light tinted background + bold title + coloured left border
///   Read   → plain white background + normal weight title + no border tint
///
/// The left border colour and icon are driven by [NotificationEntity.type].
class NotificationCard extends StatelessWidget {
  final NotificationEntity notification;
  final VoidCallback onTap;

  const NotificationCard({
    super.key,
    required this.notification,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final config = _NotifConfig.from(notification.type);
    final isUnread = notification.isUnread;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 250),
            curve: Curves.easeOut,
            decoration: BoxDecoration(
              color: isUnread
                  ? config.color.withOpacity(0.06)
                  : Theme.of(context).colorScheme.surface,
              borderRadius: BorderRadius.circular(12),
              border: Border(
                // RTL-aware: in Arabic the "left" border is on the right side
                // visually. Using BorderSide on the start side.
                right: BorderSide(
                  color: isUnread ? config.color : Colors.transparent,
                  width: 4,
                ),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.04),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ── Icon ────────────────────────────────────────────────
                  _buildIcon(config, isUnread),
                  const SizedBox(width: 12),

                  // ── Content ─────────────────────────────────────────────
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Title row with unread dot
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Expanded(
                              child: Text(
                                notification.title,
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: isUnread
                                      ? FontWeight.bold
                                      : FontWeight.w500,
                                  fontFamily: 'Cairo',
                                  color:
                                      Theme.of(context).colorScheme.onSurface,
                                  height: 1.4,
                                ),
                              ),
                            ),
                            if (isUnread) ...[
                              const SizedBox(width: 8),
                              Container(
                                width: 8,
                                height: 8,
                                decoration: BoxDecoration(
                                  color: config.color,
                                  shape: BoxShape.circle,
                                ),
                              ),
                            ],
                          ],
                        ),
                        const SizedBox(height: 4),

                        // Message body
                        Text(
                          notification.message,
                          style: TextStyle(
                            fontSize: 13,
                            fontFamily: 'Cairo',
                            color: Theme.of(context)
                                .colorScheme
                                .onSurface
                                .withOpacity(0.65),
                            height: 1.5,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 8),

                        // Time + type chip row
                        Row(
                          children: [
                            // Time
                            Icon(
                              Icons.access_time_rounded,
                              size: 12,
                              color: Theme.of(context)
                                  .colorScheme
                                  .onSurface
                                  .withOpacity(0.4),
                            ),
                            const SizedBox(width: 4),
                            Text(
                              _formatTime(notification.sentAt ??
                                  notification.createdAt),
                              style: TextStyle(
                                fontSize: 11,
                                fontFamily: 'Cairo',
                                color: Theme.of(context)
                                    .colorScheme
                                    .onSurface
                                    .withOpacity(0.4),
                              ),
                            ),
                            const Spacer(),

                            // Type chip
                            _buildTypeChip(context, config),
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
      ),
    );
  }

  Widget _buildIcon(_NotifConfig config, bool isUnread) {
    return Container(
      width: 44,
      height: 44,
      decoration: BoxDecoration(
        color: config.color.withOpacity(isUnread ? 0.15 : 0.08),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Icon(
        config.icon,
        color: config.color.withOpacity(isUnread ? 1.0 : 0.6),
        size: 22,
      ),
    );
  }

  Widget _buildTypeChip(BuildContext context, _NotifConfig config) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: config.color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        config.label,
        style: TextStyle(
          fontSize: 10,
          fontFamily: 'Cairo',
          color: config.color,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  String _formatTime(DateTime dateTime) {
    final now = DateTime.now();
    final diff = now.difference(dateTime);

    if (diff.inMinutes < 1) return 'الآن';
    if (diff.inMinutes < 60) return 'منذ ${diff.inMinutes} دقيقة';
    if (diff.inHours < 24) return 'منذ ${diff.inHours} ساعة';
    if (diff.inDays == 1) return 'أمس';
    if (diff.inDays < 7) return 'منذ ${diff.inDays} أيام';

    return DateFormat('dd/MM/yyyy', 'ar').format(dateTime);
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// TYPE CONFIG
// Maps notification type → icon + colour + Arabic label
// ─────────────────────────────────────────────────────────────────────────────

class _NotifConfig {
  final IconData icon;
  final Color color;
  final String label;

  const _NotifConfig({
    required this.icon,
    required this.color,
    required this.label,
  });

  factory _NotifConfig.from(String type) {
    switch (type) {
      case 'new_student':
        return const _NotifConfig(
          icon: Icons.person_add_rounded,
          color: Color(0xFF2E7D32), // Deep green
          label: 'طالب جديد',
        );
      case 'enrollment':
        return const _NotifConfig(
          icon: Icons.assignment_turned_in_rounded,
          color: Color(0xFF1565C0), // Deep blue
          label: 'التحاق',
        );
      case 'course_start':
        return const _NotifConfig(
          icon: Icons.play_circle_rounded,
          color: Color(0xFF00695C), // Teal
          label: 'بداية الدورة',
        );
      case 'course_end':
        return const _NotifConfig(
          icon: Icons.check_circle_rounded,
          color: Color(0xFF546E7A), // Blue grey
          label: 'نهاية الدورة',
        );
      case 'custom_broadcast':
      default:
        return const _NotifConfig(
          icon: Icons.campaign_rounded,
          color: Color(0xFF6A1B9A), // Purple
          label: 'إشعار عام',
        );
    }
  }
}
