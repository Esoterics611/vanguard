import 'package:flutter/material.dart';
import '../../../core/models/army/rank.dart';
import '../../../app/theme/cyber_colors.dart';
import '../../../app/theme/cyber_text_styles.dart';

/// Hexagonal badge displaying military rank
class RankBadge extends StatelessWidget {
  final Rank rank;
  final double size;
  final bool showGlow;
  final bool showLabel;

  const RankBadge({
    super.key,
    required this.rank,
    this.size = 48,
    this.showGlow = true,
    this.showLabel = false,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: _getRankGradient(),
            boxShadow: showGlow ? _getGlowShadow() : null,
            border: Border.all(
              color: _getBorderColor(),
              width: 2,
            ),
          ),
          child: Center(
            child: Text(
              rank.abbreviation,
              style: CyberTextStyles.rankAbbrev.copyWith(
                fontSize: size * 0.25,
                color: CyberColors.spaceBlack,
              ),
            ),
          ),
        ),
        if (showLabel) ...[
          const SizedBox(height: 4),
          Text(
            rank.displayName,
            style: CyberTextStyles.labelSmall.copyWith(
              color: _getTextColor(),
            ),
          ),
        ],
      ],
    );
  }

  LinearGradient _getRankGradient() {
    if (rank.isOfficer) {
      return CyberColors.officerGradient;
    } else if (rank.isNCO) {
      return CyberColors.ncoGradient;
    } else {
      return CyberColors.enlistedGradient;
    }
  }

  Color _getBorderColor() {
    if (rank.isOfficer) {
      return CyberColors.officerGold;
    } else if (rank.isNCO) {
      return CyberColors.ncoSilver;
    } else {
      return CyberColors.enlistedBronze;
    }
  }

  Color _getTextColor() {
    if (rank.isOfficer) {
      return CyberColors.officerGold;
    } else if (rank.isNCO) {
      return CyberColors.ncoSilver;
    } else {
      return CyberColors.enlistedBronze;
    }
  }

  List<BoxShadow>? _getGlowShadow() {
    final color = _getBorderColor();
    return [
      BoxShadow(
        color: color.withValues(alpha: 0.4),
        blurRadius: 12,
        spreadRadius: 0,
      ),
    ];
  }
}

/// Compact inline rank badge
class InlineRankBadge extends StatelessWidget {
  final Rank rank;

  const InlineRankBadge({super.key, required this.rank});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        gradient: _getRankGradient(),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        rank.abbreviation,
        style: CyberTextStyles.labelSmall.copyWith(
          color: CyberColors.spaceBlack,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  LinearGradient _getRankGradient() {
    if (rank.isOfficer) {
      return CyberColors.officerGradient;
    } else if (rank.isNCO) {
      return CyberColors.ncoGradient;
    } else {
      return CyberColors.enlistedGradient;
    }
  }
}
