import 'package:freezed_annotation/freezed_annotation.dart';

part 'application.freezed.dart';
part 'application.g.dart';

/// Status of a squad application
enum ApplicationStatus {
  pending,
  accepted,
  rejected,
}

/// Represents an application from a guest to join a squad
@freezed
sealed class SquadApplication with _$SquadApplication {
  const SquadApplication._();

  const factory SquadApplication({
    required String id,
    required String walletAddress,
    required String squadId,
    String? message,
    @Default(ApplicationStatus.pending) ApplicationStatus status,
    String? reviewedById,
    DateTime? reviewedAt,
    required DateTime createdAt,
  }) = _SquadApplication;

  factory SquadApplication.fromJson(Map<String, dynamic> json) =>
      _$SquadApplicationFromJson(json);

  /// Check if application is pending
  bool get isPending => status == ApplicationStatus.pending;

  /// Check if application was accepted
  bool get isAccepted => status == ApplicationStatus.accepted;

  /// Check if application was rejected
  bool get isRejected => status == ApplicationStatus.rejected;

  /// Check if application has been reviewed
  bool get isReviewed => status != ApplicationStatus.pending;

  /// Days since application was submitted
  int get daysSinceSubmitted => DateTime.now().difference(createdAt).inDays;
}
