// lib/theme/app_theme.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // Relaxing, formal color palette
  static const Color backgroundColor = Color(0xFFF5F7FA);
  static const Color cardColor = Color(0xFFFFFFFF);
  static const Color primaryColor = Color(0xFF4A5568);
  static const Color accentColor = Color(0xFF5A67D8);
  static const Color secondaryColor = Color(0xFF667EEA);
  static const Color subtleAccent = Color(0xFF7C3AED);
  static const Color borderColor = Color(0xFFE2E8F0);
  static const Color textPrimary = Color(0xFF2D3748);
  static const Color textSecondary = Color(0xFF718096);
  static const Color textHint = Color(0xFFA0AEC0);
  
  // Gentle gradients for subtle visual interest
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [Color(0xFF667EEA), Color(0xFF5A67D8)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  
  static const LinearGradient secondaryGradient = LinearGradient(
    colors: [Color(0xFF7C3AED), Color(0xFF6366F1)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  
  static const LinearGradient accentGradient = LinearGradient(
    colors: [Color(0xFF5A67D8), Color(0xFF4299E1)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  
  // Typography hierarchy
  static TextStyle headingStyle = GoogleFonts.inter(
    fontSize: 28,
    fontWeight: FontWeight.w600,
    color: textPrimary,
    letterSpacing: -0.5,
  );
  
  static TextStyle subheadingStyle = GoogleFonts.inter(
    fontSize: 15,
    fontWeight: FontWeight.w400,
    color: textSecondary,
    letterSpacing: 0,
  );
  
  static TextStyle cardTitleStyle = GoogleFonts.inter(
    fontSize: 16,
    fontWeight: FontWeight.w600,
    color: textPrimary,
    letterSpacing: -0.2,
  );
  
  static TextStyle cardSubtitleStyle = GoogleFonts.inter(
    fontSize: 13,
    fontWeight: FontWeight.w400,
    color: textSecondary,
    letterSpacing: 0,
  );
  
  static TextStyle statNumberStyle = GoogleFonts.inter(
    fontSize: 24,
    fontWeight: FontWeight.w700,
    color: textPrimary,
    letterSpacing: -0.5,
  );
  
  static TextStyle statLabelStyle = GoogleFonts.inter(
    fontSize: 12,
    fontWeight: FontWeight.w500,
    color: textSecondary,
    letterSpacing: 0.3,
  );
  
  static TextStyle buttonTextStyle = GoogleFonts.inter(
    fontSize: 15,
    fontWeight: FontWeight.w600,
    color: Colors.white,
    letterSpacing: 0.2,
  );
}