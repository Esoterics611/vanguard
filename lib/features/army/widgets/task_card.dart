import 'package:flutter/material.dart';
import '../../../core/models/army/task.dart';
import '../../../app/theme/cyber_colors.dart';
import '../../../app/theme/cyber_text_styles.dart';
import 'cyber_card.dart';

/// Card displaying a task with priority and status
class TaskCard extends StatelessWidget {
  final Task task;
  final VoidCallback? onTap;

  const TaskCard({
    super.key,
    required this.task,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return CyberCard(
      borderColor: _getPriorityColor(),
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              _PriorityIndicator(priority: task.priority),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  task.title,
                  style: CyberTextStyles.bodyLarge.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            task.description,
            style: CyberTextStyles.bodySmall,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _StatusChip(status: task.status),
              Row(
                children: [
                  Icon(
                    Icons.schedule,
                    size: 14,
                    color: task.isOverdue
                        ? CyberColors.combatRed
                        : CyberColors.textMuted,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    _formatDeadline(),
                    style: CyberTextStyles.labelSmall.copyWith(
                      color: task.isOverdue
                          ? CyberColors.combatRed
                          : CyberColors.textMuted,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    '${task.rewardVgrd} VGRD',
                    style: CyberTextStyles.tokenAmount.copyWith(fontSize: 12),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Color _getPriorityColor() {
    switch (task.priority) {
      case TaskPriority.critical:
        return CyberColors.combatRed;
      case TaskPriority.high:
        return CyberColors.militaryAmber;
      case TaskPriority.medium:
        return CyberColors.electricCyan;
      case TaskPriority.low:
        return CyberColors.borderSubtle;
    }
  }

  String _formatDeadline() {
    if (task.isOverdue) return 'Overdue';
    final days = task.daysRemaining;
    if (days == 0) {
      final hours = task.hoursRemaining;
      return '${hours}h left';
    }
    return '${days}d left';
  }
}

class _PriorityIndicator extends StatelessWidget {
  final TaskPriority priority;

  const _PriorityIndicator({required this.priority});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: _getColor().withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: _getColor()),
      ),
      child: Text(
        priority.name.toUpperCase(),
        style: CyberTextStyles.labelSmall.copyWith(
          color: _getColor(),
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Color _getColor() {
    switch (priority) {
      case TaskPriority.critical:
        return CyberColors.combatRed;
      case TaskPriority.high:
        return CyberColors.militaryAmber;
      case TaskPriority.medium:
        return CyberColors.electricCyan;
      case TaskPriority.low:
        return CyberColors.textMuted;
    }
  }
}

class _StatusChip extends StatelessWidget {
  final TaskStatus status;

  const _StatusChip({required this.status});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: _getColor().withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(
              color: _getColor(),
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 6),
          Text(
            status.name.toUpperCase(),
            style: CyberTextStyles.labelSmall.copyWith(
              color: _getColor(),
            ),
          ),
        ],
      ),
    );
  }

  Color _getColor() {
    switch (status) {
      case TaskStatus.created:
        return CyberColors.textMuted;
      case TaskStatus.assigned:
        return CyberColors.electricCyan;
      case TaskStatus.inProgress:
        return CyberColors.militaryAmber;
      case TaskStatus.blocked:
        return CyberColors.combatRed;
      case TaskStatus.submitted:
        return CyberColors.tacticalGreen;
      case TaskStatus.completed:
        return CyberColors.tacticalGreen;
      case TaskStatus.failed:
        return CyberColors.combatRed;
    }
  }
}

/// Compact task card for lists
class CompactTaskCard extends StatelessWidget {
  final Task task;
  final VoidCallback? onTap;

  const CompactTaskCard({
    super.key,
    required this.task,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: CyberColors.cardBackground,
          borderRadius: BorderRadius.circular(8),
          border: Border(
            left: BorderSide(
              color: _getPriorityColor(),
              width: 3,
            ),
          ),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    task.title,
                    style: CyberTextStyles.bodyMedium.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${task.daysRemaining}d left • ${task.rewardVgrd} VGRD',
                    style: CyberTextStyles.labelSmall,
                  ),
                ],
              ),
            ),
            Icon(
              Icons.chevron_right,
              color: CyberColors.textMuted,
            ),
          ],
        ),
      ),
    );
  }

  Color _getPriorityColor() {
    switch (task.priority) {
      case TaskPriority.critical:
        return CyberColors.combatRed;
      case TaskPriority.high:
        return CyberColors.militaryAmber;
      case TaskPriority.medium:
        return CyberColors.electricCyan;
      case TaskPriority.low:
        return CyberColors.borderSubtle;
    }
  }
}
