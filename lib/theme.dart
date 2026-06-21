import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppColors {
  // --- Light Theme Colors ---
  static const Color lightBg = Color(0xFFF4F7F5);
  static const Color lightContainer = Color(0xFFFFFFFF);
  static const Color lightPrimary = Color(0xFF134E40); // Deep Forest Green
  static const Color lightTextPrimary = Color(0xFF1C3627); // Brand Dark
  static const Color lightTextSecondary = Color(0xFF4A5D53);
  static const Color mintTeal = Color(0xFF0EB59A);
  static const Color lightMintHighlight = Color(0xFFF0FDF4);
  static const Color lightBorder = Color(0xFFE3E8E4);
  static const Color lightBorderSecondary = Color(0xFFF1F5F2);

  // --- Dark Theme Colors ---
  static const Color darkBgDeep = Color(0xFF070908);
  static const Color darkBgSecondary = Color(0xFF0D1A18);
  static const Color darkContainer = Color(0xFF0C0F0D);
  static const Color darkBorder = Color(0xFF1D2722);
  static const Color darkTextPrimary = Color(0xFFFFFFFF);
  static const Color darkTextSecondary = Color(0xFF8B9D95);

  // --- Status Colors ---
  static const Color error = Color(0xFFEF4444);
  static const Color warning = Color(0xFFF59E0B);
  static const Color info = Color(0xFF3B82F6);

  // --- Compatibility Aliases for Existing Files ---
  static const Color backgroundDark = darkBgDeep;
  static const Color backgroundMidnight = darkBgSecondary;
  static const Color cardBackground = darkContainer;
  static const Color cardBorder = darkBorder;
  static const Color primaryTeal = mintTeal;
  static const Color primaryTealDark = Color(0xFF0F2D25);
  static const Color accentBlue = Color(0xFFD5E0FA);
  static const Color accentBlueDark = darkBorder;
  static const Color textPrimary = darkTextPrimary;
  static const Color textSecondary = darkTextSecondary;
  static const Color textMuted = Color(0xFF64748B);
  static const Color success = mintTeal;

  // --- Gradients ---
  static const LinearGradient mintGradient = LinearGradient(
    colors: [Color(0xFF0EB59A), Color(0xFF34D399)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient tealGradient = mintGradient; // Alias

  static const LinearGradient darkHeroGradient = LinearGradient(
    colors: [Color(0xFF0D1A18), Color(0xFF070908)],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );
}

class AppTheme {
  static ThemeData get lightTheme {
    return ThemeData(
      brightness: Brightness.light,
      primaryColor: AppColors.lightPrimary,
      scaffoldBackgroundColor: AppColors.lightBg,
      cardColor: AppColors.lightContainer,
      colorScheme: const ColorScheme.light(
        primary: AppColors.lightPrimary,
        secondary: AppColors.mintTeal,
        surface: AppColors.lightContainer,
        error: AppColors.error,
      ),
      textTheme: TextTheme(
        displayLarge: GoogleFonts.playfairDisplay(
          fontSize: 34,
          fontWeight: FontWeight.bold,
          color: AppColors.lightTextPrimary,
          height: 1.2,
        ),
        displayMedium: GoogleFonts.playfairDisplay(
          fontSize: 26,
          fontWeight: FontWeight.bold,
          color: AppColors.lightTextPrimary,
          height: 1.25,
        ),
        titleLarge: GoogleFonts.outfit(
          fontSize: 22,
          fontWeight: FontWeight.w600,
          color: AppColors.lightTextPrimary,
        ),
        titleMedium: GoogleFonts.outfit(
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: AppColors.lightTextPrimary,
        ),
        bodyLarge: GoogleFonts.inter(
          fontSize: 15,
          fontWeight: FontWeight.normal,
          color: AppColors.lightTextSecondary,
          height: 1.5,
        ),
        bodyMedium: GoogleFonts.inter(
          fontSize: 13,
          fontWeight: FontWeight.normal,
          color: AppColors.lightTextSecondary,
          height: 1.45,
        ),
        labelLarge: GoogleFonts.outfit(
          fontSize: 14,
          fontWeight: FontWeight.bold,
          color: AppColors.lightPrimary,
          letterSpacing: 0.5,
        ),
      ),
      cardTheme: CardThemeData(
        color: AppColors.lightContainer,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
          side: const BorderSide(color: AppColors.lightBorder, width: 1.0),
        ),
        elevation: 0,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.lightContainer,
        elevation: 0,
        centerTitle: true,
        iconTheme: IconThemeData(color: AppColors.lightPrimary),
        titleTextStyle: TextStyle(
          color: AppColors.lightTextPrimary,
          fontSize: 18,
          fontWeight: FontWeight.bold,
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.lightContainer,
        contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 15),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: AppColors.lightBorder, width: 1.0),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: AppColors.lightBorder, width: 1.0),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: AppColors.mintTeal, width: 1.5),
        ),
        hintStyle: GoogleFonts.inter(color: AppColors.lightTextSecondary.withOpacity(0.6), fontSize: 14),
        labelStyle: GoogleFonts.outfit(color: AppColors.lightTextPrimary, fontSize: 14),
      ),
    );
  }

  static ThemeData get darkTheme {
    return ThemeData(
      brightness: Brightness.dark,
      primaryColor: AppColors.mintTeal,
      scaffoldBackgroundColor: AppColors.darkBgDeep,
      cardColor: AppColors.darkContainer,
      colorScheme: const ColorScheme.dark(
        primary: AppColors.mintTeal,
        secondary: AppColors.mintTeal,
        surface: AppColors.darkContainer,
        error: AppColors.error,
      ),
      textTheme: TextTheme(
        displayLarge: GoogleFonts.playfairDisplay(
          fontSize: 34,
          fontWeight: FontWeight.bold,
          color: AppColors.darkTextPrimary,
          height: 1.2,
        ),
        displayMedium: GoogleFonts.playfairDisplay(
          fontSize: 26,
          fontWeight: FontWeight.bold,
          color: AppColors.darkTextPrimary,
          height: 1.25,
        ),
        titleLarge: GoogleFonts.outfit(
          fontSize: 22,
          fontWeight: FontWeight.w600,
          color: AppColors.darkTextPrimary,
        ),
        titleMedium: GoogleFonts.outfit(
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: AppColors.darkTextPrimary,
        ),
        bodyLarge: GoogleFonts.inter(
          fontSize: 15,
          fontWeight: FontWeight.normal,
          color: AppColors.darkTextSecondary,
          height: 1.5,
        ),
        bodyMedium: GoogleFonts.inter(
          fontSize: 13,
          fontWeight: FontWeight.normal,
          color: AppColors.darkTextSecondary,
          height: 1.45,
        ),
        labelLarge: GoogleFonts.outfit(
          fontSize: 14,
          fontWeight: FontWeight.bold,
          color: AppColors.mintTeal,
          letterSpacing: 0.5,
        ),
      ),
      cardTheme: CardThemeData(
        color: AppColors.darkContainer,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
          side: const BorderSide(color: AppColors.darkBorder, width: 1.0),
        ),
        elevation: 0,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.darkBgSecondary,
        elevation: 0,
        centerTitle: true,
        iconTheme: IconThemeData(color: AppColors.mintTeal),
        titleTextStyle: TextStyle(
          color: AppColors.darkTextPrimary,
          fontSize: 18,
          fontWeight: FontWeight.bold,
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.darkContainer,
        contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 15),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: AppColors.darkBorder, width: 1.0),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: AppColors.darkBorder, width: 1.0),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: AppColors.mintTeal, width: 1.5),
        ),
        hintStyle: GoogleFonts.inter(color: AppColors.darkTextSecondary.withOpacity(0.6), fontSize: 14),
        labelStyle: GoogleFonts.outfit(color: AppColors.darkTextSecondary, fontSize: 14),
      ),
    );
  }
}
