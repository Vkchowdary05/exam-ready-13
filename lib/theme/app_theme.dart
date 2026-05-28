// lib/theme/app_theme.dart
//
// BRIK®-inspired Design System for Exam Ready
// ─────────────────────────────────────────────
// Deep teal-black backgrounds, cream accents, lavender highlights.
// Space Grotesk for headings, Inter for body text.
// Border-only cards (no shadows), pill-shaped buttons.

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:exam_ready/utils/constants.dart';

class AppTheme {
  AppTheme._();

  // ═══════════════════════════════════════════════════════════════
  // COLOR PALETTE
  // ═══════════════════════════════════════════════════════════════

  // ── Dark backgrounds ──────────────────────────────────────────
  static const Color darkBg = Color(0xFF0B2B32);       // Primary dark bg
  static const Color darkSurface = Color(0xFF0F3A42);   // Cards on dark bg
  static const Color darkBorder = Color(0xFF1A4D58);    // Borders on dark
  static const Color darkElevated = Color(0xFF134049);  // Elevated surfaces

  // ── Light / Cream backgrounds ─────────────────────────────────
  static const Color cream = Color(0xFFF5F2EB);         // Primary light bg
  static const Color creamSurface = Color(0xFFFFFFFF);   // Cards on cream
  static const Color creamBorder = Color(0xFFE8E3D9);    // Borders on cream
  static const Color creamMuted = Color(0xFFEDE9E0);     // Muted cream

  // ── Accents ───────────────────────────────────────────────────
  static const Color lavender = Color(0xFFCBC5F0);       // Primary accent
  static const Color lavenderMuted = Color(0xFF9B93C9);  // Muted lavender
  static const Color teal = Color(0xFF4ECDC4);           // Secondary accent
  static const Color tealDark = Color(0xFF2CBAB0);       // Teal on dark bg
  static const Color coral = Color(0xFFFF6B6B);          // Error / destructive
  static const Color amber = Color(0xFFFFB84D);          // Warning
  static const Color success = Color(0xFF4ADE80);        // Success
  static const Color mint = Color(0xFF6EE7B7);           // Success muted

  // ── Text colors ───────────────────────────────────────────────
  static const Color textOnDark = Color(0xFFF5F2EB);     // Primary text on dark
  static const Color textOnDarkMuted = Color(0xFF8FA8AD); // Secondary on dark
  static const Color textOnLight = Color(0xFF1A2B2F);    // Primary text on cream
  static const Color textOnLightMuted = Color(0xFF6B7B7F); // Secondary on cream

  // ── Legacy compatibility ──────────────────────────────────────
  static const Color primaryColor = lavender;
  static const Color secondaryColor = teal;
  static const Color backgroundColor = cream;
  static const Color cardColor = creamSurface;
  static const Color textPrimary = textOnLight;
  static const Color textSecondary = textOnLightMuted;
  static const Color errorColor = coral;
  static const Color borderColor = creamBorder;

  // ═══════════════════════════════════════════════════════════════
  // GRADIENTS
  // ═══════════════════════════════════════════════════════════════

  static const LinearGradient primaryGradient = LinearGradient(
    colors: [Color(0xFF0B2B32), Color(0xFF134049)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient accentGradient = LinearGradient(
    colors: [lavender, Color(0xFFA99DE5)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient tealGradient = LinearGradient(
    colors: [teal, Color(0xFF3DBCB4)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient backgroundGradient = LinearGradient(
    colors: [Color(0xFF0B2B32), Color(0xFF0E353E)],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  static const LinearGradient hotBadgeGradient = LinearGradient(
    colors: [Color(0xFFFF6B6B), Color(0xFFFF8E8E)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient dueBadgeGradient = LinearGradient(
    colors: [Color(0xFFFFB84D), Color(0xFFFFCC73)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // ═══════════════════════════════════════════════════════════════
  // TYPOGRAPHY
  // ═══════════════════════════════════════════════════════════════

  /// Space Grotesk — for headings, numbers, brand text
  static TextStyle heading1 = GoogleFonts.spaceGrotesk(
    fontSize: 32,
    fontWeight: FontWeight.w700,
    letterSpacing: -1.0,
    height: 1.2,
  );

  static TextStyle heading2 = GoogleFonts.spaceGrotesk(
    fontSize: 24,
    fontWeight: FontWeight.w700,
    letterSpacing: -0.8,
    height: 1.3,
  );

  static TextStyle heading3 = GoogleFonts.spaceGrotesk(
    fontSize: 20,
    fontWeight: FontWeight.w600,
    letterSpacing: -0.5,
    height: 1.3,
  );

  static TextStyle heading4 = GoogleFonts.spaceGrotesk(
    fontSize: 16,
    fontWeight: FontWeight.w600,
    letterSpacing: -0.3,
    height: 1.4,
  );

  /// Inter — for body text, labels, descriptions
  static TextStyle bodyLarge = GoogleFonts.inter(
    fontSize: 16,
    fontWeight: FontWeight.w400,
    letterSpacing: -0.1,
    height: 1.5,
  );

  static TextStyle bodyMedium = GoogleFonts.inter(
    fontSize: 14,
    fontWeight: FontWeight.w400,
    letterSpacing: 0,
    height: 1.5,
  );

  static TextStyle bodySmall = GoogleFonts.inter(
    fontSize: 12,
    fontWeight: FontWeight.w400,
    letterSpacing: 0.1,
    height: 1.4,
  );

  static TextStyle label = GoogleFonts.inter(
    fontSize: 13,
    fontWeight: FontWeight.w600,
    letterSpacing: 0.3,
    height: 1.4,
  );

  static TextStyle caption = GoogleFonts.inter(
    fontSize: 11,
    fontWeight: FontWeight.w500,
    letterSpacing: 0.2,
    height: 1.3,
  );

  static TextStyle bigNumber = GoogleFonts.spaceGrotesk(
    fontSize: 40,
    fontWeight: FontWeight.w700,
    letterSpacing: -2,
    height: 1.1,
  );

  static TextStyle statNumber = GoogleFonts.spaceGrotesk(
    fontSize: 28,
    fontWeight: FontWeight.w700,
    letterSpacing: -1,
    height: 1.2,
  );

  // ── Legacy text styles (for existing code compatibility) ──────
  static TextStyle headingStyle = heading2;
  static TextStyle subheadingStyle = bodyLarge.copyWith(color: textOnLightMuted);
  static TextStyle subHeadingStyle = subheadingStyle;
  static TextStyle inputTextStyle = bodyLarge.copyWith(color: textOnLight);
  static TextStyle buttonTextStyle = GoogleFonts.inter(
    fontSize: 16,
    fontWeight: FontWeight.w600,
    color: Colors.white,
    letterSpacing: 0,
  );
  static TextStyle labelTextStyle = label;

  // ═══════════════════════════════════════════════════════════════
  // DECORATION HELPERS
  // ═══════════════════════════════════════════════════════════════

  /// Card decoration for dark backgrounds (border only, no shadow)
  static BoxDecoration darkCard({Color? borderCol}) => BoxDecoration(
    color: darkSurface,
    borderRadius: BorderRadius.circular(AppConstants.cardRadius),
    border: Border.all(
      color: borderCol ?? darkBorder,
      width: 1,
    ),
  );

  /// Card decoration for light/cream backgrounds
  static BoxDecoration lightCard({Color? borderCol}) => BoxDecoration(
    color: creamSurface,
    borderRadius: BorderRadius.circular(AppConstants.cardRadius),
    border: Border.all(
      color: borderCol ?? creamBorder,
      width: 1,
    ),
  );

  /// Pill button decoration
  static BoxDecoration pillButton({
    Color? bgColor,
    Color? borderCol,
  }) => BoxDecoration(
    color: bgColor ?? lavender,
    borderRadius: BorderRadius.circular(AppConstants.buttonRadius),
    border: borderCol != null
        ? Border.all(color: borderCol, width: 1)
        : null,
  );

  /// Chip / tag decoration
  static BoxDecoration chip({Color? bgColor, Color? borderCol}) => BoxDecoration(
    color: bgColor ?? lavender.withAlpha(30),
    borderRadius: BorderRadius.circular(AppConstants.chipRadius),
    border: Border.all(
      color: borderCol ?? lavender.withAlpha(60),
      width: 1,
    ),
  );

  /// Input field decoration (BRIK style)
  static InputDecoration inputDecoration({
    required String hint,
    IconData? icon,
    Widget? suffixIcon,
  }) {
    return InputDecoration(
      hintText: hint,
      hintStyle: bodyMedium.copyWith(color: textOnLightMuted),
      prefixIcon: icon != null
          ? Icon(icon, color: textOnLightMuted, size: 20)
          : null,
      suffixIcon: suffixIcon,
      filled: true,
      fillColor: creamMuted,
      contentPadding: const EdgeInsets.symmetric(
        horizontal: 20,
        vertical: 16,
      ),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppConstants.inputRadius),
        borderSide: BorderSide(color: creamBorder),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppConstants.inputRadius),
        borderSide: BorderSide(color: creamBorder),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppConstants.inputRadius),
        borderSide: const BorderSide(color: lavender, width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppConstants.inputRadius),
        borderSide: const BorderSide(color: coral),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppConstants.inputRadius),
        borderSide: const BorderSide(color: coral, width: 2),
      ),
    );
  }

  /// Card shadow (subtle, used sparingly)
  static List<BoxShadow> cardShadow = [
    BoxShadow(
      color: Colors.black.withAlpha(10),
      blurRadius: 12,
      offset: const Offset(0, 4),
    ),
  ];

  // ═══════════════════════════════════════════════════════════════
  // THEME DATA
  // ═══════════════════════════════════════════════════════════════

  static ThemeData get lightTheme => ThemeData(
    brightness: Brightness.light,
    useMaterial3: true,
    scaffoldBackgroundColor: cream,
    colorScheme: ColorScheme.light(
      primary: lavender,
      secondary: teal,
      surface: creamSurface,
      error: coral,
      onPrimary: darkBg,
      onSecondary: Colors.white,
      onSurface: textOnLight,
      onError: Colors.white,
    ),
    textTheme: GoogleFonts.interTextTheme().copyWith(
      headlineLarge: heading1.copyWith(color: textOnLight),
      headlineMedium: heading2.copyWith(color: textOnLight),
      headlineSmall: heading3.copyWith(color: textOnLight),
      titleLarge: heading4.copyWith(color: textOnLight),
      bodyLarge: bodyLarge.copyWith(color: textOnLight),
      bodyMedium: bodyMedium.copyWith(color: textOnLight),
      bodySmall: bodySmall.copyWith(color: textOnLightMuted),
      labelLarge: label.copyWith(color: textOnLight),
      labelSmall: caption.copyWith(color: textOnLightMuted),
    ),
    appBarTheme: AppBarTheme(
      backgroundColor: cream,
      foregroundColor: textOnLight,
      elevation: 0,
      titleTextStyle: heading3.copyWith(color: textOnLight),
    ),
    cardTheme: CardThemeData(
      color: creamSurface,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppConstants.cardRadius),
        side: const BorderSide(color: creamBorder),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: creamMuted,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppConstants.inputRadius),
        borderSide: const BorderSide(color: creamBorder),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppConstants.inputRadius),
        borderSide: const BorderSide(color: creamBorder),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppConstants.inputRadius),
        borderSide: const BorderSide(color: lavender, width: 2),
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: lavender,
        foregroundColor: darkBg,
        minimumSize: const Size(double.infinity, AppConstants.minButtonHeight),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppConstants.buttonRadius),
        ),
        textStyle: GoogleFonts.inter(
          fontSize: 16,
          fontWeight: FontWeight.w600,
        ),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: textOnLight,
        minimumSize: const Size(double.infinity, AppConstants.minButtonHeight),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppConstants.buttonRadius),
        ),
        side: const BorderSide(color: creamBorder),
        textStyle: GoogleFonts.inter(
          fontSize: 16,
          fontWeight: FontWeight.w600,
        ),
      ),
    ),
    chipTheme: ChipThemeData(
      backgroundColor: lavender.withAlpha(30),
      labelStyle: bodySmall.copyWith(color: lavenderMuted),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppConstants.chipRadius),
        side: BorderSide(color: lavender.withAlpha(60)),
      ),
    ),
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      backgroundColor: creamSurface,
      selectedItemColor: lavender,
      unselectedItemColor: textOnLightMuted,
      type: BottomNavigationBarType.fixed,
      elevation: 0,
      selectedIconTheme: IconThemeData(size: AppConstants.navIconSize),
      unselectedIconTheme: IconThemeData(size: AppConstants.navIconSize),
    ),
    dividerTheme: const DividerThemeData(
      color: creamBorder,
      thickness: 1,
      space: 1,
    ),
    snackBarTheme: SnackBarThemeData(
      backgroundColor: darkBg,
      contentTextStyle: bodyMedium.copyWith(color: textOnDark),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
      ),
      behavior: SnackBarBehavior.floating,
    ),
  );

  static ThemeData get darkTheme => ThemeData(
    brightness: Brightness.dark,
    useMaterial3: true,
    scaffoldBackgroundColor: darkBg,
    colorScheme: ColorScheme.dark(
      primary: lavender,
      secondary: teal,
      surface: darkSurface,
      error: coral,
      onPrimary: darkBg,
      onSecondary: darkBg,
      onSurface: textOnDark,
      onError: Colors.white,
    ),
    textTheme: GoogleFonts.interTextTheme(ThemeData.dark().textTheme).copyWith(
      headlineLarge: heading1.copyWith(color: textOnDark),
      headlineMedium: heading2.copyWith(color: textOnDark),
      headlineSmall: heading3.copyWith(color: textOnDark),
      titleLarge: heading4.copyWith(color: textOnDark),
      bodyLarge: bodyLarge.copyWith(color: textOnDark),
      bodyMedium: bodyMedium.copyWith(color: textOnDark),
      bodySmall: bodySmall.copyWith(color: textOnDarkMuted),
      labelLarge: label.copyWith(color: textOnDark),
      labelSmall: caption.copyWith(color: textOnDarkMuted),
    ),
    appBarTheme: AppBarTheme(
      backgroundColor: darkBg,
      foregroundColor: textOnDark,
      elevation: 0,
      titleTextStyle: heading3.copyWith(color: textOnDark),
    ),
    cardTheme: CardThemeData(
      color: darkSurface,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppConstants.cardRadius),
        side: const BorderSide(color: darkBorder),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: darkElevated,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppConstants.inputRadius),
        borderSide: const BorderSide(color: darkBorder),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppConstants.inputRadius),
        borderSide: const BorderSide(color: darkBorder),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppConstants.inputRadius),
        borderSide: const BorderSide(color: lavender, width: 2),
      ),
      hintStyle: bodyMedium.copyWith(color: textOnDarkMuted),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: lavender,
        foregroundColor: darkBg,
        minimumSize: const Size(double.infinity, AppConstants.minButtonHeight),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppConstants.buttonRadius),
        ),
        textStyle: GoogleFonts.inter(
          fontSize: 16,
          fontWeight: FontWeight.w600,
        ),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: textOnDark,
        minimumSize: const Size(double.infinity, AppConstants.minButtonHeight),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppConstants.buttonRadius),
        ),
        side: const BorderSide(color: darkBorder),
        textStyle: GoogleFonts.inter(
          fontSize: 16,
          fontWeight: FontWeight.w600,
        ),
      ),
    ),
    chipTheme: ChipThemeData(
      backgroundColor: lavender.withAlpha(25),
      labelStyle: bodySmall.copyWith(color: lavender),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppConstants.chipRadius),
        side: BorderSide(color: lavender.withAlpha(60)),
      ),
    ),
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      backgroundColor: darkSurface,
      selectedItemColor: lavender,
      unselectedItemColor: textOnDarkMuted,
      type: BottomNavigationBarType.fixed,
      elevation: 0,
      selectedIconTheme: IconThemeData(size: AppConstants.navIconSize),
      unselectedIconTheme: IconThemeData(size: AppConstants.navIconSize),
    ),
    dividerTheme: const DividerThemeData(
      color: darkBorder,
      thickness: 1,
      space: 1,
    ),
    snackBarTheme: SnackBarThemeData(
      backgroundColor: cream,
      contentTextStyle: bodyMedium.copyWith(color: textOnLight),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
      ),
      behavior: SnackBarBehavior.floating,
    ),
  );
}
