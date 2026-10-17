import 'package:flutter/material.dart';
import '../../../app/theme/cyber_colors.dart';
import '../../../app/theme/cyber_text_styles.dart';

/// Styled callsign text with optional glow effect
class CallsignText extends StatelessWidget {
  final String callsign;
  final double? fontSize;
  final bool showGlow;
  final Color? color;

  const CallsignText({
    super.key,
    required this.callsign,
    this.fontSize,
    this.showGlow = true,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    final textColor = color ?? CyberColors.electricCyan;

    return Text(
      callsign,
      style: CyberTextStyles.callsign.copyWith(
        fontSize: fontSize ?? 14,
        color: textColor,
        shadows: showGlow
            ? [
                Shadow(
                  color: textColor.withValues(alpha: 0.5),
                  blurRadius: 8,
                ),
              ]
            : null,
      ),
    );
  }
}

/// Large callsign display
class CallsignDisplay extends StatelessWidget {
  final String callsign;

  const CallsignDisplay({super.key, required this.callsign});

  @override
  Widget build(BuildContext context) {
    return Text(
      callsign,
      style: CyberTextStyles.callsignLarge.copyWith(
        shadows: [
          Shadow(
            color: CyberColors.electricCyan.withValues(alpha: 0.5),
            blurRadius: 12,
          ),
        ],
      ),
    );
  }
}
