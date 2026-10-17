import 'package:freezed_annotation/freezed_annotation.dart';

part 'objective.freezed.dart';
part 'objective.g.dart';

/// Status of an objective
enum ObjectiveStatus {
  active,
  inProgress,
  completed,
  cancelled,
}

/// Represents a unit-level objective linked to a bounty
@freezed
sealed class Objective with _$Objective {
  const Objective._();

  const factory Objective({
    required String id,
    required String title,
    required String description,
    required String unitId,
    required String bountyId,
    @Default(ObjectiveStatus.active) ObjectiveStatus status,
    @Default([]) List<String> taskIds,
    required int allocatedVgrd,
    required DateTime deadline,
    required DateTime createdAt,
    String? createdById,
  }) = _Objective;

  factory Objective.fromJson(Map<String, dynamic> json) =>
      _$ObjectiveFromJson(json);

  /// Number of tasks in this objective
  int get taskCount => taskIds.length;

  /// Check if objective is overdue
  bool get isOverdue => DateTime.now().isAfter(deadline);

  /// Days remaining until deadline
  int get daysRemaining => deadline.difference(DateTime.now()).inDays;

  /// Check if objective is completed
  bool get isCompleted => status == ObjectiveStatus.completed;

  /// Check if objective is active (not completed or cancelled)
  bool get isActive =>
      status == ObjectiveStatus.active || status == ObjectiveStatus.inProgress;
}
