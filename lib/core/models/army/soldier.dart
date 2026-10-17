import 'package:freezed_annotation/freezed_annotation.dart';
import 'rank.dart';

part 'soldier.freezed.dart';
part 'soldier.g.dart';

/// Represents a soldier in the Army hierarchy
@freezed
sealed class Soldier with _$Soldier {
  const Soldier._();

  const factory Soldier({
    required String id,
    String? walletAddress,
    required String callsign,
    required Rank rank,
    String? squadId,
    String? sectionId,
    String? platoonId,
    String? companyId,
    @Default(0) int tasksCompleted,
    @Default(0) int xp,
    @Default(0) int vgrdEarned,
    @Default(0) int votingPower,
    required DateTime enlistedAt,
    String? invitedByWallet,
    @Default([]) List<String> promotionHistory,
    @Default(false) bool hasCompletedPLDC,
    @Default(false) bool hasCompletedOBC,
  }) = _Soldier;

  factory Soldier.fromJson(Map<String, dynamic> json) =>
      _$SoldierFromJson(json);

  /// Calculate the effective voting power based on rank
  int get effectiveVotingPower => rank.votingPower;

  /// Calculate XP progress to next rank (0.0 to 1.0)
  double get xpProgressToNextRank {
    final nextRank = rank.nextRank;
    if (nextRank == null) return 1.0;

    final currentRequired = rank.xpRequired;
    final nextRequired = nextRank.xpRequired;
    final xpNeeded = nextRequired - currentRequired;

    if (xpNeeded <= 0) return 1.0;

    final xpProgress = xp - currentRequired;
    return (xpProgress / xpNeeded).clamp(0.0, 1.0);
  }

  /// XP needed for next rank
  int get xpToNextRank {
    final nextRank = rank.nextRank;
    if (nextRank == null) return 0;
    return (nextRank.xpRequired - xp).clamp(0, nextRank.xpRequired);
  }

  /// Check if soldier is eligible for promotion to next rank
  bool get isEligibleForPromotion {
    final nextRank = rank.nextRank;
    if (nextRank == null) return false;

    // Check XP requirement
    if (xp < nextRank.xpRequired) return false;

    // Check training requirements
    if (nextRank == Rank.sgt && !hasCompletedPLDC) return false;
    if (nextRank == Rank.firstLt && !hasCompletedOBC) return false;

    return true;
  }

  /// Check if this soldier is a leader of any unit
  bool get isLeader => rank.index >= Rank.sgt.index;

  /// Check if this soldier can recruit
  bool get canRecruit => rank.index >= Rank.pfc.index;
}
