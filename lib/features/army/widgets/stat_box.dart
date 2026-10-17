import 'package:flutter/material.dart';
import '../../../app/theme/cyber_colors.dart';
import '../../../app/theme/cyber_text_styles.dart';

/// Box displaying a single statistic
class StatBox extends StatelessWidget {
  final String value;
  final String label;
  final IconData? icon;
  final Color? valueColor;

  const StatBox({
    super.key,
    required this.value,
    required this.label,
    this.icon,
    this.valueColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: CyberColors.darkPanel,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: CyberColors.borderSubtle),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(
              icon,
              size: 16,
              color: CyberColors.textMuted,
            ),
            const SizedBox(height: 4),
          ],
          Text(
            value,
            style: CyberTextStyles.statNumber.copyWith(
              fontSize: 20,
              color: valueColor ?? CyberColors.textPrimary,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: CyberTextStyles.statLabel,
          ),
        ],
      ),
    );
  }
}

/// Row of stat boxes
class StatRow extends StatelessWidget {
  final List<StatBox> stats;

  const StatRow({super.key, required this.stats});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: stats
          .map(
            (stat) => Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4),
                child: stat,
              ),
            ),
          )
          .toList(),
    );
  }
}

/// Large stat display with icon
class LargeStatDisplay extends StatelessWidget {
  final String value;
  final String label;
  final IconData icon;
  final Color color;

  const LargeStatDisplay({
    super.key,
    required this.value,
    required this.label,
    required this.icon,
    this.color = CyberColors.electricCyan,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(
            icon,
            size: 24,
            color: color,
          ),
        ),
        const SizedBox(width: 12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              value,
              style: CyberTextStyles.statNumber.copyWith(color: color),
            ),
            Text(
              label,
              style: CyberTextStyles.labelSmall,
            ),
          ],
        ),
      ],
    );
  }
}
