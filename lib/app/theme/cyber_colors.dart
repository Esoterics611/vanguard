import 'package:flutter/material.dart';

/// Cyber Command color palette for the Mission Control Army UI
class CyberColors {
  CyberColors._();

  // Base colors
  static const Color spaceBlack = Color(0xFF0A0E17);
  static const Color deepSpace = Color(0xFF0D1321);
  static const Color darkPanel = Color(0xFF111827);
  static const Color cardBackground = Color(0xFF1A2332);

  // Primary accent - Electric Cyan
  static const Color electricCyan = Color(0xFF00F0FF);
  static const Color electricCyanDark = Color(0xFF00B8C4);
  static const Color electricCyanLight = Color(0xFF66F7FF);

  // Secondary - Military Amber
  static const Color militaryAmber = Color(0xFFFFB800);
  static const Color militaryAmberDark = Color(0xFFCC9400);
  static const Color militaryAmberLight = Color(0xFFFFCB40);

  // Success - Tactical Green
  static const Color tacticalGreen = Color(0xFF00FF88);
  static const Color tacticalGreenDark = Color(0xFF00CC6B);
  static const Color tacticalGreenLight = Color(0xFF66FFAA);

  // Danger - Combat Red
  static const Color combatRed = Color(0xFFFF3366);
  static const Color combatRedDark = Color(0xFFCC2952);
  static const Color combatRedLight = Color(0xFFFF6688);

  // Rank colors
  static const Color officerGold = Color(0xFFFFD700);
  static const Color officerGoldDark = Color(0xFFFFA500);
  static const Color ncoSilver = Color(0xFFC0C0C0);
  static const Color ncoSilverDark = Color(0xFF909090);
  static const Color enlistedBronze = Color(0xFFCD7F32);
  static const Color enlistedBronzeDark = Color(0xFFA66328);

  // UI elements
  static const Color gridLine = Color(0xFF1A2332);
  static const Color borderSubtle = Color(0xFF2A3444);
  static const Color textPrimary = Color(0xFFFFFFFF);
  static const Color textSecondary = Color(0xFFB0B8C4);
  static const Color textMuted = Color(0xFF6B7280);
  static const Color textDisabled = Color(0xFF4B5563);

  // Scan line overlay
  static Color get scanLine => electricCyan.withValues(alpha: 0.05);

  // Glow effects
  static Color get cyanGlow => electricCyan.withValues(alpha: 0.4);
  static Color get amberGlow => militaryAmber.withValues(alpha: 0.4);
  static Color get greenGlow => tacticalGreen.withValues(alpha: 0.4);
  static Color get redGlow => combatRed.withValues(alpha: 0.4);
  static Color get goldGlow => officerGold.withValues(alpha: 0.4);

  /// Get color for a priority level
  static Color priorityColor(String priority) {
    switch (priority.toLowerCase()) {
      case 'critical':
        return combatRed;
      case 'high':
        return militaryAmber;
      case 'medium':
        return electricCyan;
      case 'low':
      default:
        return textSecondary;
    }
  }

  /// Get gradient for officer rank
  static LinearGradient get officerGradient => const LinearGradient(
        colors: [officerGold, officerGoldDark],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      );

  /// Get gradient for NCO rank
  static LinearGradient get ncoGradient => const LinearGradient(
        colors: [ncoSilver, ncoSilverDark],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      );

  /// Get gradient for enlisted rank
  static LinearGradient get enlistedGradient => const LinearGradient(
        colors: [enlistedBronze, enlistedBronzeDark],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      );

  /// Get glow box shadow for interactive elements
  static List<BoxShadow> glowShadow(Color color, {double blur = 12}) {
    return [
      BoxShadow(
        color: color.withValues(alpha: 0.4),
        blurRadius: blur,
        spreadRadius: 0,
      ),
    ];
  }
}
