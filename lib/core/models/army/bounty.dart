import 'package:freezed_annotation/freezed_annotation.dart';

part 'bounty.freezed.dart';
part 'bounty.g.dart';

/// Status of a bounty
enum BountyStatus {
  draft,
  active,
  inProgress,
  completed,
  cancelled,
}

/// Represents a bounty (high-level work item) created by a Captain
@freezed
sealed class Bounty with _$Bounty {
  const Bounty._();

  const factory Bounty({
    required String id,
    required String title,
    required String description,
    required String creatorId,
    required int totalAmount,
    @Default(0) int remainingAmount,
    required DateTime deadline,
    @Default(BountyStatus.draft) BountyStatus status,
    @Default([]) List<String> objectiveIds,
    @Default([]) List<String> skillTags,
    @Default(null) DateTime? createdAt,
    DateTime? completedAt,
  }) = _Bounty;

  factory Bounty.fromJson(Map<String, dynamic> json) => _$BountyFromJson(json);

  /// Number of objectives in this bounty
  int get objectiveCount => objectiveIds.length;

  /// Amount already distributed
  int get distributedAmount => totalAmount - remainingAmount;

  /// Percentage completed (by amount)
  double get completionPercentage {
    if (totalAmount == 0) return 0;
    return (distributedAmount / totalAmount).clamp(0.0, 1.0);
  }

  /// Days remaining until deadline
  int get daysRemaining => deadline.difference(DateTime.now()).inDays;

  /// Check if bounty is overdue
  bool get isOverdue =>
      DateTime.now().isAfter(deadline) && status != BountyStatus.completed;

  /// Check if bounty is active
  bool get isActive =>
      status == BountyStatus.active || status == BountyStatus.inProgress;

  /// Check if bounty can be funded
  bool get canBeFunded =>
      status == BountyStatus.draft || status == BountyStatus.active;

  /// Check if bounty can be cancelled
  bool get canBeCancelled =>
      status == BountyStatus.draft ||
      (status == BountyStatus.active && distributedAmount == 0);
}
