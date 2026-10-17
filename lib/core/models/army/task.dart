import 'package:freezed_annotation/freezed_annotation.dart';

part 'task.freezed.dart';
part 'task.g.dart';

/// Status of a task
enum TaskStatus {
  created,
  assigned,
  inProgress,
  blocked,
  submitted,
  completed,
  failed,
}

/// Priority level of a task
enum TaskPriority {
  low,
  medium,
  high,
  critical,
}

/// Represents an individual task assigned to a soldier
@freezed
sealed class Task with _$Task {
  const Task._();

  const factory Task({
    required String id,
    required String title,
    required String description,
    required String objectiveId,
    String? assigneeId,
    @Default(TaskStatus.created) TaskStatus status,
    @Default(TaskPriority.medium) TaskPriority priority,
    required int rewardVgrd,
    required DateTime deadline,
    String? submissionIpfsHash,
    DateTime? completedAt,
    required DateTime createdAt,
    String? createdById,
  }) = _Task;

  factory Task.fromJson(Map<String, dynamic> json) => _$TaskFromJson(json);

  /// Check if task is assigned
  bool get isAssigned => assigneeId != null;

  /// Check if task is completed
  bool get isCompleted => status == TaskStatus.completed;

  /// Check if task is overdue
  bool get isOverdue =>
      DateTime.now().isAfter(deadline) && !isCompleted;

  /// Days remaining until deadline
  int get daysRemaining => deadline.difference(DateTime.now()).inDays;

  /// Hours remaining until deadline
  int get hoursRemaining => deadline.difference(DateTime.now()).inHours;

  /// Check if task can be started
  bool get canStart =>
      status == TaskStatus.assigned || status == TaskStatus.blocked;

  /// Check if task can be submitted
  bool get canSubmit => status == TaskStatus.inProgress;

  /// Get status display text
  String get statusDisplayText {
    switch (status) {
      case TaskStatus.created:
        return 'Created';
      case TaskStatus.assigned:
        return 'Assigned';
      case TaskStatus.inProgress:
        return 'In Progress';
      case TaskStatus.blocked:
        return 'Blocked';
      case TaskStatus.submitted:
        return 'Submitted';
      case TaskStatus.completed:
        return 'Completed';
      case TaskStatus.failed:
        return 'Failed';
    }
  }

  /// Get priority display text
  String get priorityDisplayText {
    switch (priority) {
      case TaskPriority.low:
        return 'Low';
      case TaskPriority.medium:
        return 'Medium';
      case TaskPriority.high:
        return 'High';
      case TaskPriority.critical:
        return 'Critical';
    }
  }
}
