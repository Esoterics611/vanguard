import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'cyber_colors.dart';

/// Text styles for the Cyber Command theme
class CyberTextStyles {
  CyberTextStyles._();

  // Orbitron - Headers (military tech feel)
  static TextStyle get displayLarge => GoogleFonts.orbitron(
        fontSize: 32,
        fontWeight: FontWeight.bold,
        color: CyberColors.textPrimary,
        letterSpacing: 2,
      );

  static TextStyle get displayMedium => GoogleFonts.orbitron(
        fontSize: 28,
        fontWeight: FontWeight.bold,
        color: CyberColors.textPrimary,
        letterSpacing: 1.5,
      );

  static TextStyle get displaySmall => GoogleFonts.orbitron(
        fontSize: 24,
        fontWeight: FontWeight.w600,
        color: CyberColors.textPrimary,
        letterSpacing: 1,
      );

  static TextStyle get headlineLarge => GoogleFonts.orbitron(
        fontSize: 20,
        fontWeight: FontWeight.w600,
        color: CyberColors.textPrimary,
        letterSpacing: 1,
      );

  static TextStyle get headlineMedium => GoogleFonts.orbitron(
        fontSize: 18,
        fontWeight: FontWeight.w500,
        color: CyberColors.textPrimary,
        letterSpacing: 0.5,
      );

  static TextStyle get headlineSmall => GoogleFonts.orbitron(
        fontSize: 16,
        fontWeight: FontWeight.w500,
        color: CyberColors.textPrimary,
      );

  // Inter - Body text (clean, readable)
  static TextStyle get bodyLarge => GoogleFonts.inter(
        fontSize: 16,
        fontWeight: FontWeight.normal,
        color: CyberColors.textPrimary,
      );

  static TextStyle get bodyMedium => GoogleFonts.inter(
        fontSize: 14,
        fontWeight: FontWeight.normal,
        color: CyberColors.textPrimary,
      );

  static TextStyle get bodySmall => GoogleFonts.inter(
        fontSize: 12,
        fontWeight: FontWeight.normal,
        color: CyberColors.textSecondary,
      );

  static TextStyle get labelLarge => GoogleFonts.inter(
        fontSize: 14,
        fontWeight: FontWeight.w500,
        color: CyberColors.textPrimary,
      );

  static TextStyle get labelMedium => GoogleFonts.inter(
        fontSize: 12,
        fontWeight: FontWeight.w500,
        color: CyberColors.textSecondary,
      );

  static TextStyle get labelSmall => GoogleFonts.inter(
        fontSize: 10,
        fontWeight: FontWeight.w500,
        color: CyberColors.textMuted,
      );

  // Callsign style - Monospace with glow potential
  static TextStyle get callsign => GoogleFonts.robotoMono(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        color: CyberColors.electricCyan,
        letterSpacing: 1,
      );

  static TextStyle get callsignLarge => GoogleFonts.robotoMono(
        fontSize: 18,
        fontWeight: FontWeight.bold,
        color: CyberColors.electricCyan,
        letterSpacing: 1.5,
      );

  // Rank abbreviation style
  static TextStyle get rankAbbrev => GoogleFonts.orbitron(
        fontSize: 12,
        fontWeight: FontWeight.bold,
        color: CyberColors.militaryAmber,
        letterSpacing: 1,
      );

  // Stat number style
  static TextStyle get statNumber => GoogleFonts.orbitron(
        fontSize: 24,
        fontWeight: FontWeight.bold,
        color: CyberColors.textPrimary,
      );

  static TextStyle get statLabel => GoogleFonts.inter(
        fontSize: 10,
        fontWeight: FontWeight.w500,
        color: CyberColors.textMuted,
        letterSpacing: 0.5,
      );

  // VGRD token amount
  static TextStyle get tokenAmount => GoogleFonts.robotoMono(
        fontSize: 16,
        fontWeight: FontWeight.bold,
        color: CyberColors.tacticalGreen,
      );

  // Button text
  static TextStyle get buttonPrimary => GoogleFonts.orbitron(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        color: CyberColors.spaceBlack,
        letterSpacing: 1,
      );

  static TextStyle get buttonSecondary => GoogleFonts.orbitron(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        color: CyberColors.electricCyan,
        letterSpacing: 1,
      );
}
