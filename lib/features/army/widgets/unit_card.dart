import 'package:flutter/material.dart';
import '../../../core/models/army/unit.dart';
import '../../../core/models/army/unit_type.dart';
import '../../../app/theme/cyber_colors.dart';
import '../../../app/theme/cyber_text_styles.dart';
import 'cyber_card.dart';
import 'cyber_progress_ring.dart';

/// Card displaying unit information
class UnitCard extends StatelessWidget {
  final Unit unit;
  final bool isExpanded;
  final bool isUserUnit;
  final VoidCallback? onTap;

  const UnitCard({
    super.key,
    required this.unit,
    this.isExpanded = false,
    this.isUserUnit = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return CyberCard(
      borderColor: isUserUnit ? CyberColors.electricCyan : null,
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              _UnitTypeIcon(type: unit.type),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          unit.name,
                          style: CyberTextStyles.headlineSmall,
                        ),
                        if (isUserUnit) ...[
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: CyberColors.electricCyan.withValues(alpha: 0.2),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              'YOUR UNIT',
                              style: CyberTextStyles.labelSmall.copyWith(
                                color: CyberColors.electricCyan,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${unit.type.displayName} • Led by ${unit.type.leaderRank}',
                      style: CyberTextStyles.labelSmall,
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    '${unit.memberCount}/${unit.maxSize}',
                    style: CyberTextStyles.bodyLarge.copyWith(
                      fontWeight: FontWeight.bold,
                      color: unit.isNearSplit
                          ? CyberColors.militaryAmber
                          : CyberColors.textPrimary,
                    ),
                  ),
                  Text(
                    'members',
                    style: CyberTextStyles.labelSmall,
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 12),
          CyberProgressBar(
            progress: unit.fillPercentage,
            height: 6,
            progressColor: unit.isNearSplit
                ? CyberColors.militaryAmber
                : CyberColors.electricCyan,
          ),
          if (unit.isNearSplit) ...[
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(
                  Icons.warning_amber_rounded,
                  size: 14,
                  color: CyberColors.militaryAmber,
                ),
                const SizedBox(width: 4),
                Text(
                  'Near split threshold! ${unit.membersUntilSplit} more to split',
                  style: CyberTextStyles.labelSmall.copyWith(
                    color: CyberColors.militaryAmber,
                  ),
                ),
              ],
            ),
          ],
          if (isExpanded) ...[
            const Divider(height: 24),
            _ExpandedContent(unit: unit),
          ],
        ],
      ),
    );
  }
}

class _UnitTypeIcon extends StatelessWidget {
  final UnitType type;

  const _UnitTypeIcon({required this.type});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 48,
      height: 48,
      decoration: BoxDecoration(
        color: _getColor().withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: _getColor()),
      ),
      child: Center(
        child: Text(
          type.icon,
          style: const TextStyle(fontSize: 20),
        ),
      ),
    );
  }

  Color _getColor() {
    switch (type) {
      case UnitType.company:
        return CyberColors.officerGold;
      case UnitType.platoon:
        return CyberColors.militaryAmber;
      case UnitType.section:
        return CyberColors.ncoSilver;
      case UnitType.squad:
        return CyberColors.electricCyan;
    }
  }
}

class _ExpandedContent extends StatelessWidget {
  final Unit unit;

  const _ExpandedContent({required this.unit});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Active Objectives',
          style: CyberTextStyles.labelLarge,
        ),
        const SizedBox(height: 8),
        if (unit.objectiveIds.isEmpty)
          Text(
            'No active objectives',
            style: CyberTextStyles.bodySmall,
          )
        else
          Text(
            '${unit.objectiveIds.length} objectives in progress',
            style: CyberTextStyles.bodySmall,
          ),
        if (unit.hasChildren) ...[
          const SizedBox(height: 16),
          Text(
            'Child Units',
            style: CyberTextStyles.labelLarge,
          ),
          const SizedBox(height: 8),
          Text(
            '${unit.childUnitIds.length} ${unit.type.childType?.displayName.toLowerCase() ?? "units"}',
            style: CyberTextStyles.bodySmall,
          ),
        ],
      ],
    );
  }
}

/// Compact unit badge for inline display
class UnitBadge extends StatelessWidget {
  final Unit unit;
  final bool compact;

  const UnitBadge({
    super.key,
    required this.unit,
    this.compact = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: compact ? 8 : 12,
        vertical: compact ? 4 : 6,
      ),
      decoration: BoxDecoration(
        color: CyberColors.cardBackground,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: CyberColors.borderSubtle),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            unit.type.icon,
            style: TextStyle(fontSize: compact ? 12 : 16),
          ),
          const SizedBox(width: 6),
          Text(
            unit.name,
            style: compact
                ? CyberTextStyles.labelSmall
                : CyberTextStyles.labelMedium,
          ),
          if (!compact) ...[
            const SizedBox(width: 8),
            Text(
              '${unit.memberCount}',
              style: CyberTextStyles.labelSmall.copyWith(
                color: CyberColors.textMuted,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
