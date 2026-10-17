import 'package:flutter/material.dart';
import '../../../app/theme/cyber_colors.dart';

/// Styled card with cyber theme
class CyberCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final Color? borderColor;
  final bool showScanLines;
  final VoidCallback? onTap;

  const CyberCard({
    super.key,
    required this.child,
    this.padding,
    this.margin,
    this.borderColor,
    this.showScanLines = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    Widget content = Container(
      padding: padding ?? const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: CyberColors.cardBackground,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: borderColor ?? CyberColors.borderSubtle,
          width: 1,
        ),
      ),
      child: child,
    );

    if (showScanLines) {
      content = Stack(
        children: [
          content,
          Positioned.fill(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: const _ScanLineOverlay(),
            ),
          ),
        ],
      );
    }

    if (onTap != null) {
      content = InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: content,
      );
    }

    return Padding(
      padding: margin ?? const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: content,
    );
  }
}

/// Subtle scan line overlay effect
class _ScanLineOverlay extends StatelessWidget {
  const _ScanLineOverlay();

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              CyberColors.scanLine,
              Colors.transparent,
              CyberColors.scanLine,
              Colors.transparent,
              CyberColors.scanLine,
            ],
            stops: const [0.0, 0.2, 0.4, 0.6, 0.8],
          ),
        ),
      ),
    );
  }
}

/// Card with glowing border
class GlowingCard extends StatelessWidget {
  final Widget child;
  final Color glowColor;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;

  const GlowingCard({
    super.key,
    required this.child,
    this.glowColor = CyberColors.electricCyan,
    this.padding,
    this.margin,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: margin ?? const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: glowColor.withValues(alpha: 0.3),
            blurRadius: 12,
            spreadRadius: 0,
          ),
        ],
      ),
      child: Container(
        padding: padding ?? const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: CyberColors.cardBackground,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: glowColor,
            width: 1.5,
          ),
        ),
        child: child,
      ),
    );
  }
}
