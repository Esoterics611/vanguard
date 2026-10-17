import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../app/theme/cyber_colors.dart';
import '../../../app/theme/cyber_text_styles.dart';
import '../../../core/models/army/army_models.dart';
import '../../../core/providers/army_provider.dart';
import '../widgets/army_widgets.dart';

/// Detail page for viewing a task
class TaskDetailPage extends ConsumerStatefulWidget {
  final Task task;

  const TaskDetailPage({super.key, required this.task});

  @override
  ConsumerState<TaskDetailPage> createState() => _TaskDetailPageState();
}

class _TaskDetailPageState extends ConsumerState<TaskDetailPage> {
  final _submissionController = TextEditingController();
  bool _isSubmitting = false;

  @override
  void dispose() {
    _submissionController.dispose();
    super.dispose();
  }

  Future<void> _submitTask() async {
    if (_submissionController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter submission details')),
      );
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      final service = ref.read(armyServiceProvider);
      await service.submitTask(
        taskId: widget.task.id,
        submissionHash: _submissionController.text.trim(),
      );

      ref.invalidate(myTasksProvider);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Task submitted for review')),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final task = widget.task;

    return Scaffold(
      backgroundColor: CyberColors.spaceBlack,
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            // App Bar
            SliverAppBar(
              backgroundColor: CyberColors.spaceBlack,
              floating: true,
              leading: IconButton(
                icon: const Icon(Icons.arrow_back, color: CyberColors.textPrimary),
                onPressed: () => Navigator.pop(context),
              ),
              title: Text('TASK DETAILS', style: CyberTextStyles.headlineSmall),
            ),

            // Header Card
            SliverToBoxAdapter(
              child: GlowingCard(
                glowColor: _getPriorityColor(task.priority),
                margin: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Status and Priority
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: _getStatusColor(task.status).withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: _getStatusColor(task.status)),
                          ),
                          child: Text(
                            task.status.name.toUpperCase(),
                            style: CyberTextStyles.labelSmall.copyWith(
                              color: _getStatusColor(task.status),
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: _getPriorityColor(task.priority).withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: _getPriorityColor(task.priority)),
                          ),
                          child: Text(
                            task.priority.name.toUpperCase(),
                            style: CyberTextStyles.labelSmall.copyWith(
                              color: _getPriorityColor(task.priority),
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        const Spacer(),
                        Row(
                          children: [
                            Icon(Icons.schedule, size: 16, color: CyberColors.textMuted),
                            const SizedBox(width: 4),
                            Text(
                              _formatDeadline(task.deadline),
                              style: CyberTextStyles.labelSmall,
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // Title
                    Text(task.title, style: CyberTextStyles.headlineMedium),
                    const SizedBox(height: 8),

                    // Description
                    if (task.description.isNotEmpty)
                      Text(
                        task.description,
                        style: CyberTextStyles.bodyMedium,
                      ),

                    const SizedBox(height: 16),

                    // Reward
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: CyberColors.tacticalGreen.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: CyberColors.tacticalGreen.withValues(alpha: 0.3)),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.toll, color: CyberColors.tacticalGreen),
                          const SizedBox(width: 12),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Reward', style: CyberTextStyles.labelSmall),
                              Text(
                                '${task.rewardVgrd} VGRD',
                                style: CyberTextStyles.headlineSmall.copyWith(
                                  color: CyberColors.tacticalGreen,
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

            // Submission section (if task is in progress)
            if (task.status == TaskStatus.inProgress || task.status == TaskStatus.assigned)
              SliverToBoxAdapter(
                child: CyberCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('SUBMIT WORK', style: CyberTextStyles.headlineSmall),
                      const SizedBox(height: 8),
                      Text(
                        'Enter your IPFS hash or submission details',
                        style: CyberTextStyles.bodySmall,
                      ),
                      const SizedBox(height: 16),
                      TextField(
                        controller: _submissionController,
                        maxLines: 3,
                        style: CyberTextStyles.bodyMedium,
                        decoration: InputDecoration(
                          hintText: 'ipfs://Qm... or description',
                          hintStyle: CyberTextStyles.bodySmall.copyWith(
                            color: CyberColors.textMuted,
                          ),
                          filled: true,
                          fillColor: CyberColors.darkPanel,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: const BorderSide(color: CyberColors.borderSubtle),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton.icon(
                        onPressed: _isSubmitting ? null : _submitTask,
                        icon: _isSubmitting
                            ? const SizedBox(
                                width: 16,
                                height: 16,
                                child: CircularProgressIndicator(strokeWidth: 2),
                              )
                            : const Icon(Icons.upload),
                        label: const Text('Submit for Review'),
                        style: ElevatedButton.styleFrom(
                          minimumSize: const Size(double.infinity, 48),
                          backgroundColor: CyberColors.electricCyan,
                          foregroundColor: CyberColors.spaceBlack,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

            // Submission info (if already submitted)
            if (task.status == TaskStatus.submitted && task.submissionIpfsHash != null)
              SliverToBoxAdapter(
                child: CyberCard(
                  borderColor: CyberColors.militaryAmber,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.pending, color: CyberColors.militaryAmber),
                          const SizedBox(width: 8),
                          Text(
                            'AWAITING REVIEW',
                            style: CyberTextStyles.headlineSmall.copyWith(
                              color: CyberColors.militaryAmber,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Text('Submission:', style: CyberTextStyles.labelSmall),
                      const SizedBox(height: 4),
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: CyberColors.darkPanel,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: SelectableText(
                          task.submissionIpfsHash!,
                          style: CyberTextStyles.bodySmall.copyWith(
                            fontFamily: 'monospace',
                            color: CyberColors.electricCyan,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

            // Completed info
            if (task.status == TaskStatus.completed)
              SliverToBoxAdapter(
                child: CyberCard(
                  borderColor: CyberColors.tacticalGreen,
                  child: Row(
                    children: [
                      Icon(Icons.check_circle, color: CyberColors.tacticalGreen, size: 48),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'TASK COMPLETED',
                              style: CyberTextStyles.headlineSmall.copyWith(
                                color: CyberColors.tacticalGreen,
                              ),
                            ),
                            Text(
                              'You earned ${task.rewardVgrd} VGRD',
                              style: CyberTextStyles.bodyMedium,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),

            const SliverToBoxAdapter(child: SizedBox(height: 100)),
          ],
        ),
      ),
    );
  }

  Color _getStatusColor(TaskStatus status) {
    switch (status) {
      case TaskStatus.created:
        return CyberColors.textMuted;
      case TaskStatus.assigned:
        return CyberColors.electricCyan;
      case TaskStatus.inProgress:
        return CyberColors.electricCyan;
      case TaskStatus.blocked:
        return CyberColors.combatRed;
      case TaskStatus.submitted:
        return CyberColors.militaryAmber;
      case TaskStatus.completed:
        return CyberColors.tacticalGreen;
      case TaskStatus.failed:
        return CyberColors.combatRed;
    }
  }

  Color _getPriorityColor(TaskPriority priority) {
    switch (priority) {
      case TaskPriority.low:
        return CyberColors.textMuted;
      case TaskPriority.medium:
        return CyberColors.electricCyan;
      case TaskPriority.high:
        return CyberColors.militaryAmber;
      case TaskPriority.critical:
        return CyberColors.combatRed;
    }
  }

  String _formatDeadline(DateTime deadline) {
    final now = DateTime.now();
    final diff = deadline.difference(now);
    if (diff.isNegative) return 'Overdue';
    if (diff.inDays > 0) return '${diff.inDays}d left';
    if (diff.inHours > 0) return '${diff.inHours}h left';
    return '${diff.inMinutes}m left';
  }
}
