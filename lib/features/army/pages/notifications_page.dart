import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../app/theme/cyber_colors.dart';
import '../../../app/theme/cyber_text_styles.dart';

/// Notification type
enum NotificationType {
  taskAssigned,
  taskApproved,
  taskRejected,
  promotion,
  squadApplication,
  squadAccepted,
  bountyCreated,
  message,
  system,
}

/// Notification model
class AppNotification {
  final String id;
  final NotificationType type;
  final String title;
  final String body;
  final DateTime timestamp;
  final bool isRead;
  final Map<String, dynamic>? data;

  AppNotification({
    required this.id,
    required this.type,
    required this.title,
    required this.body,
    required this.timestamp,
    this.isRead = false,
    this.data,
  });
}

/// Provider for notifications (mock data for now)
final notificationsProvider = FutureProvider<List<AppNotification>>((ref) async {
  // In a real app, this would fetch from Firestore
  return [
    AppNotification(
      id: '1',
      type: NotificationType.taskAssigned,
      title: 'New Task Assigned',
      body: 'You have been assigned to "Audit reentrancy vulnerabilities"',
      timestamp: DateTime.now().subtract(const Duration(hours: 1)),
    ),
    AppNotification(
      id: '2',
      type: NotificationType.promotion,
      title: 'Promotion Available',
      body: 'You are eligible for promotion to PV2',
      timestamp: DateTime.now().subtract(const Duration(hours: 5)),
    ),
    AppNotification(
      id: '3',
      type: NotificationType.bountyCreated,
      title: 'New Bounty',
      body: 'A new bounty "DeFi Protocol Analysis" has been created',
      timestamp: DateTime.now().subtract(const Duration(days: 1)),
    ),
    AppNotification(
      id: '4',
      type: NotificationType.message,
      title: 'New Message',
      body: 'SGT GHOST-9K2: "Welcome to Alpha Squad"',
      timestamp: DateTime.now().subtract(const Duration(days: 2)),
      isRead: true,
    ),
  ];
});

/// Notifications page
class NotificationsPage extends ConsumerWidget {
  const NotificationsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notificationsAsync = ref.watch(notificationsProvider);

    return Scaffold(
      backgroundColor: CyberColors.spaceBlack,
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back, color: CyberColors.textPrimary),
                    onPressed: () => Navigator.pop(context),
                  ),
                  Text('NOTIFICATIONS', style: CyberTextStyles.headlineLarge),
                  const Spacer(),
                  TextButton(
                    onPressed: () {
                      // Mark all as read
                    },
                    child: Text(
                      'Mark all read',
                      style: CyberTextStyles.labelSmall.copyWith(
                        color: CyberColors.electricCyan,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Content
            Expanded(
              child: notificationsAsync.when(
                data: (notifications) {
                  if (notifications.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.notifications_none,
                            size: 64,
                            color: CyberColors.textMuted,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'No notifications',
                            style: CyberTextStyles.bodyMedium.copyWith(
                              color: CyberColors.textMuted,
                            ),
                          ),
                        ],
                      ),
                    );
                  }

                  return ListView.builder(
                    padding: const EdgeInsets.only(bottom: 100),
                    itemCount: notifications.length,
                    itemBuilder: (context, index) {
                      return _NotificationCard(notification: notifications[index]);
                    },
                  );
                },
                loading: () => const Center(
                  child: CircularProgressIndicator(color: CyberColors.electricCyan),
                ),
                error: (e, _) => Center(
                  child: Text(
                    'Error: $e',
                    style: CyberTextStyles.bodyMedium.copyWith(
                      color: CyberColors.combatRed,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _NotificationCard extends StatelessWidget {
  final AppNotification notification;

  const _NotificationCard({required this.notification});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      decoration: BoxDecoration(
        color: notification.isRead
            ? CyberColors.cardBackground
            : CyberColors.electricCyan.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: notification.isRead
              ? CyberColors.borderSubtle
              : CyberColors.electricCyan.withValues(alpha: 0.3),
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            // Handle notification tap
          },
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Icon
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: _getTypeColor(notification.type).withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Icon(
                    _getTypeIcon(notification.type),
                    color: _getTypeColor(notification.type),
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),

                // Content
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              notification.title,
                              style: CyberTextStyles.bodyMedium.copyWith(
                                fontWeight: notification.isRead
                                    ? FontWeight.normal
                                    : FontWeight.w600,
                              ),
                            ),
                          ),
                          if (!notification.isRead)
                            Container(
                              width: 8,
                              height: 8,
                              decoration: const BoxDecoration(
                                color: CyberColors.electricCyan,
                                shape: BoxShape.circle,
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        notification.body,
                        style: CyberTextStyles.bodySmall.copyWith(
                          color: CyberColors.textMuted,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        _formatTimestamp(notification.timestamp),
                        style: CyberTextStyles.labelSmall.copyWith(
                          color: CyberColors.textMuted,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Color _getTypeColor(NotificationType type) {
    switch (type) {
      case NotificationType.taskAssigned:
        return CyberColors.electricCyan;
      case NotificationType.taskApproved:
        return CyberColors.tacticalGreen;
      case NotificationType.taskRejected:
        return CyberColors.combatRed;
      case NotificationType.promotion:
        return CyberColors.officerGold;
      case NotificationType.squadApplication:
      case NotificationType.squadAccepted:
        return CyberColors.ncoSilver;
      case NotificationType.bountyCreated:
        return CyberColors.militaryAmber;
      case NotificationType.message:
        return CyberColors.electricCyan;
      case NotificationType.system:
        return CyberColors.textMuted;
    }
  }

  IconData _getTypeIcon(NotificationType type) {
    switch (type) {
      case NotificationType.taskAssigned:
        return Icons.assignment;
      case NotificationType.taskApproved:
        return Icons.check_circle;
      case NotificationType.taskRejected:
        return Icons.cancel;
      case NotificationType.promotion:
        return Icons.military_tech;
      case NotificationType.squadApplication:
        return Icons.person_add;
      case NotificationType.squadAccepted:
        return Icons.group_add;
      case NotificationType.bountyCreated:
        return Icons.add_task;
      case NotificationType.message:
        return Icons.message;
      case NotificationType.system:
        return Icons.info;
    }
  }

  String _formatTimestamp(DateTime timestamp) {
    final now = DateTime.now();
    final diff = now.difference(timestamp);

    if (diff.inMinutes < 60) {
      return '${diff.inMinutes}m ago';
    } else if (diff.inHours < 24) {
      return '${diff.inHours}h ago';
    } else if (diff.inDays < 7) {
      return '${diff.inDays}d ago';
    } else {
      return '${timestamp.month}/${timestamp.day}';
    }
  }
}
