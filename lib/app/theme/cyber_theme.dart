import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'cyber_colors.dart';
import 'cyber_text_styles.dart';

/// Creates the Cyber Command theme for the app
class CyberTheme {
  CyberTheme._();

  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: CyberColors.spaceBlack,
      primaryColor: CyberColors.electricCyan,
      colorScheme: const ColorScheme.dark(
        primary: CyberColors.electricCyan,
        secondary: CyberColors.militaryAmber,
        tertiary: CyberColors.tacticalGreen,
        error: CyberColors.combatRed,
        surface: CyberColors.darkPanel,
        onPrimary: CyberColors.spaceBlack,
        onSecondary: CyberColors.spaceBlack,
        onTertiary: CyberColors.spaceBlack,
        onError: CyberColors.textPrimary,
        onSurface: CyberColors.textPrimary,
      ),

      // App Bar
      appBarTheme: AppBarTheme(
        backgroundColor: CyberColors.deepSpace,
        foregroundColor: CyberColors.textPrimary,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: CyberTextStyles.headlineMedium,
        iconTheme: const IconThemeData(color: CyberColors.electricCyan),
      ),

      // Bottom Navigation
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: CyberColors.deepSpace,
        selectedItemColor: CyberColors.electricCyan,
        unselectedItemColor: CyberColors.textMuted,
        type: BottomNavigationBarType.fixed,
        selectedLabelStyle: GoogleFonts.inter(
          fontSize: 10,
          fontWeight: FontWeight.w600,
        ),
        unselectedLabelStyle: GoogleFonts.inter(
          fontSize: 10,
          fontWeight: FontWeight.w500,
        ),
      ),

      // Navigation Bar (Material 3)
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: CyberColors.deepSpace,
        indicatorColor: CyberColors.electricCyan.withValues(alpha: 0.2),
        surfaceTintColor: Colors.transparent,
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return GoogleFonts.inter(
              fontSize: 10,
              fontWeight: FontWeight.w600,
              color: CyberColors.electricCyan,
            );
          }
          return GoogleFonts.inter(
            fontSize: 10,
            fontWeight: FontWeight.w500,
            color: CyberColors.textMuted,
          );
        }),
        iconTheme: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return const IconThemeData(color: CyberColors.electricCyan);
          }
          return const IconThemeData(color: CyberColors.textMuted);
        }),
      ),

      // Cards
      cardTheme: CardThemeData(
        color: CyberColors.cardBackground,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(color: CyberColors.borderSubtle),
        ),
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      ),

      // Elevated Buttons
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: CyberColors.electricCyan,
          foregroundColor: CyberColors.spaceBlack,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          textStyle: CyberTextStyles.buttonPrimary,
        ),
      ),

      // Outlined Buttons
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: CyberColors.electricCyan,
          side: const BorderSide(color: CyberColors.electricCyan, width: 1.5),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          textStyle: CyberTextStyles.buttonSecondary,
        ),
      ),

      // Text Buttons
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: CyberColors.electricCyan,
          textStyle: CyberTextStyles.labelLarge,
        ),
      ),

      // Input Decoration
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: CyberColors.darkPanel,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: CyberColors.borderSubtle),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: CyberColors.borderSubtle),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: CyberColors.electricCyan, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: CyberColors.combatRed),
        ),
        labelStyle: CyberTextStyles.labelMedium,
        hintStyle: CyberTextStyles.bodyMedium.copyWith(
          color: CyberColors.textMuted,
        ),
      ),

      // Tabs
      tabBarTheme: TabBarThemeData(
        labelColor: CyberColors.electricCyan,
        unselectedLabelColor: CyberColors.textMuted,
        indicatorColor: CyberColors.electricCyan,
        labelStyle: CyberTextStyles.labelLarge,
        unselectedLabelStyle: CyberTextStyles.labelMedium,
      ),

      // Chips
      chipTheme: ChipThemeData(
        backgroundColor: CyberColors.cardBackground,
        selectedColor: CyberColors.electricCyan.withValues(alpha: 0.2),
        labelStyle: CyberTextStyles.labelSmall,
        side: BorderSide(color: CyberColors.borderSubtle),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),

      // Progress Indicators
      progressIndicatorTheme: const ProgressIndicatorThemeData(
        color: CyberColors.electricCyan,
        linearTrackColor: CyberColors.cardBackground,
      ),

      // Divider
      dividerTheme: DividerThemeData(
        color: CyberColors.borderSubtle,
        thickness: 1,
      ),

      // Dialog
      dialogTheme: DialogThemeData(
        backgroundColor: CyberColors.darkPanel,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(color: CyberColors.borderSubtle),
        ),
        titleTextStyle: CyberTextStyles.headlineMedium,
        contentTextStyle: CyberTextStyles.bodyMedium,
      ),

      // Snackbar
      snackBarTheme: SnackBarThemeData(
        backgroundColor: CyberColors.cardBackground,
        contentTextStyle: CyberTextStyles.bodyMedium,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        behavior: SnackBarBehavior.floating,
      ),

      // Text Theme
      textTheme: TextTheme(
        displayLarge: CyberTextStyles.displayLarge,
        displayMedium: CyberTextStyles.displayMedium,
        displaySmall: CyberTextStyles.displaySmall,
        headlineLarge: CyberTextStyles.headlineLarge,
        headlineMedium: CyberTextStyles.headlineMedium,
        headlineSmall: CyberTextStyles.headlineSmall,
        bodyLarge: CyberTextStyles.bodyLarge,
        bodyMedium: CyberTextStyles.bodyMedium,
        bodySmall: CyberTextStyles.bodySmall,
        labelLarge: CyberTextStyles.labelLarge,
        labelMedium: CyberTextStyles.labelMedium,
        labelSmall: CyberTextStyles.labelSmall,
      ),
    );
  }
}
