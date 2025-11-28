import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Regain-Style Minimal Design System
/// Clean, spacious, professional productivity app theme
class AppTheme {
  // ==================== REGAIN COLOR PALETTE ====================

  // Primary Colors
  static const Color primary = Color(0xFF2D3E50); // Dark Blue-Gray

  // Legacy colors for auth screens (to be migrated)
  static const Color darkPurple = Color(0xFF6C63FF);
  static const Color lightPurple = Color(0xFFB8B5FF);

  static const Color accent = Color(0xFF12CBC4); // Turquoise
  static const Color background = Color(0xFFF6F7F9); // Light Gray
  static const Color surface = Color(0xFFFFFFFF); // White

  // Text Colors
  static const Color textPrimary = Color(0xFF2D3E50); // Dark for headings
  static const Color textSecondary = Color(0xFF8E9AAF); // Gray for subtitles
  static const Color textLight = Color(0xFFFFFFFF); // White text

  // Status Colors (Minimal)
  static const Color success = Color(0xFF10B981); // Green
  static const Color error = Color(0xFFEF4444); // Red
  static const Color warning = Color(0xFFF59E0B); // Orange
  static const Color info = Color(0xFF3B82F6); // Blue

  // Background Variants
  static const Color backgroundLight = Color(0xFFF6F7F9);
  static const Color backgroundDark = Color(0xFF1A1A2E); // For focus mode
  static const Color cardLight = Color(0xFFFFFFFF);
  static const Color cardDark = Color(0xFF16213E);

  // Legacy colors (for backward compatibility)
  static const Color primaryPurple = primary;
  static const Color primaryPurpleDark = Color(0xFF1F2937);
  static const Color secondaryBlue = accent;
  static const Color successGreen = success;
  static const Color errorRed = error;
  static const Color warningOrange = warning;
  static const Color infoBlue = info;

  // Deprecated - kept for compatibility
  static get textDark => textPrimary;

  // ==================== SPACING SYSTEM ====================

  static const double spacing4 = 4.0;
  static const double spacing8 = 8.0;
  static const double spacing12 = 12.0;
  static const double spacing16 = 16.0;
  static const double spacing20 = 20.0;
  static const double spacing24 = 24.0;
  static const double spacing32 = 32.0;
  static const double spacing48 = 48.0;
  static const double spacing64 = 64.0;

  // ==================== BORDER RADIUS ====================

  static const double radiusSmall = 12.0;
  static const double radiusMedium = 16.0;
  static const double radiusLarge = 20.0;
  static const double radiusXLarge = 24.0;
  static const double radiusCircle = 999.0;

  // ==================== SHADOWS (Soft & Minimal) ====================

  static List<BoxShadow> softShadow = [
    BoxShadow(
      color: Colors.black.withValues(alpha: 0.04),
      blurRadius: 8,
      offset: const Offset(0, 2),
    ),
  ];

  static List<BoxShadow> cardShadow = [
    BoxShadow(
      color: Colors.black.withValues(alpha: 0.06),
      blurRadius: 12,
      offset: const Offset(0, 4),
    ),
  ];

  static List<BoxShadow> elevatedShadow = [
    BoxShadow(
      color: Colors.black.withValues(alpha: 0.08),
      blurRadius: 16,
      offset: const Offset(0, 6),
    ),
  ];

  // ==================== TYPOGRAPHY ====================

  // Headings (Poppins - Bold)
  static TextStyle h1 = GoogleFonts.poppins(
    fontSize: 28,
    fontWeight: FontWeight.bold,
    height: 1.2,
    color: textPrimary,
  );

  static TextStyle h2 = GoogleFonts.poppins(
    fontSize: 24,
    fontWeight: FontWeight.bold,
    height: 1.3,
    color: textPrimary,
  );

  static TextStyle h3 = GoogleFonts.poppins(
    fontSize: 20,
    fontWeight: FontWeight.w600,
    height: 1.4,
    color: textPrimary,
  );

  static TextStyle h4 = GoogleFonts.poppins(
    fontSize: 18,
    fontWeight: FontWeight.w600,
    height: 1.4,
    color: textPrimary,
  );

  // Body Text (Inter - Regular/Light)
  static TextStyle body1 = GoogleFonts.inter(
    fontSize: 16,
    fontWeight: FontWeight.normal,
    height: 1.5,
    color: textPrimary,
  );

  static TextStyle body2 = GoogleFonts.inter(
    fontSize: 14,
    fontWeight: FontWeight.normal,
    height: 1.5,
    color: textSecondary,
  );

  static TextStyle subtitle = GoogleFonts.inter(
    fontSize: 14,
    fontWeight: FontWeight.w300,
    height: 1.5,
    color: textSecondary,
  );

  static TextStyle button = GoogleFonts.inter(
    fontSize: 16,
    fontWeight: FontWeight.w600,
    letterSpacing: 0.3,
  );

  static TextStyle caption = GoogleFonts.inter(
    fontSize: 12,
    fontWeight: FontWeight.normal,
    height: 1.4,
    color: textSecondary,
  );

  static TextStyle overline = GoogleFonts.inter(
    fontSize: 10,
    fontWeight: FontWeight.w600,
    letterSpacing: 1.2,
    color: textSecondary,
  );

  // ==================== LIGHT THEME ====================

  static ThemeData lightTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    primaryColor: primary,
    scaffoldBackgroundColor: background,
    colorScheme: const ColorScheme.light(
      primary: primary,
      secondary: accent,
      error: error,
      surface: surface,
      background: background,
    ),
    textTheme: TextTheme(
      displayLarge: h1,
      displayMedium: h2,
      displaySmall: h3,
      headlineMedium: h4,
      bodyLarge: body1,
      bodyMedium: body2,
      labelLarge: button.copyWith(color: textLight),
      bodySmall: caption,
    ),
    appBarTheme: AppBarTheme(
      backgroundColor: surface,
      elevation: 0,
      centerTitle: false,
      titleTextStyle: h3,
      iconTheme: const IconThemeData(color: textPrimary, size: 24),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: accent,
        foregroundColor: textLight,
        padding: const EdgeInsets.symmetric(
          horizontal: spacing32,
          vertical: spacing16,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radiusMedium),
        ),
        elevation: 0,
        shadowColor: Colors.transparent,
        textStyle: button,
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: primary,
        padding: const EdgeInsets.symmetric(
          horizontal: spacing32,
          vertical: spacing16,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radiusMedium),
        ),
        side: BorderSide(color: primary.withValues(alpha: 0.3), width: 1.5),
        textStyle: button,
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: surface,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(radiusMedium),
        borderSide: BorderSide(color: textSecondary.withValues(alpha: 0.2)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(radiusMedium),
        borderSide: BorderSide(color: textSecondary.withValues(alpha: 0.2)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(radiusMedium),
        borderSide: const BorderSide(color: accent, width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(radiusMedium),
        borderSide: const BorderSide(color: error, width: 2),
      ),
      contentPadding: const EdgeInsets.symmetric(
        horizontal: spacing20,
        vertical: spacing16,
      ),
      hintStyle: body1.copyWith(color: textSecondary),
    ),
    cardTheme: CardThemeData(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(radiusLarge),
      ),
      color: surface,
      shadowColor: Colors.black.withValues(alpha: 0.06),
    ),
    floatingActionButtonTheme: FloatingActionButtonThemeData(
      backgroundColor: accent,
      foregroundColor: textLight,
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(radiusMedium),
      ),
    ),
    bottomNavigationBarTheme: BottomNavigationBarThemeData(
      backgroundColor: surface,
      selectedItemColor: accent,
      unselectedItemColor: textSecondary,
      selectedLabelStyle: caption.copyWith(fontWeight: FontWeight.w600),
      unselectedLabelStyle: caption,
      type: BottomNavigationBarType.fixed,
      elevation: 8,
      showSelectedLabels: true,
      showUnselectedLabels: true,
    ),
  );

  // ==================== DARK THEME (For Focus Mode) ====================

  static ThemeData darkTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    primaryColor: accent,
    scaffoldBackgroundColor: backgroundDark,
    colorScheme: const ColorScheme.dark(
      primary: accent,
      secondary: accent,
      error: error,
      surface: cardDark,
      background: backgroundDark,
    ),
    textTheme: TextTheme(
      displayLarge: h1.copyWith(color: textLight),
      displayMedium: h2.copyWith(color: textLight),
      displaySmall: h3.copyWith(color: textLight),
      headlineMedium: h4.copyWith(color: textLight),
      bodyLarge: body1.copyWith(color: textLight),
      bodyMedium: body2.copyWith(color: Colors.grey.shade400),
      labelLarge: button.copyWith(color: textLight),
      bodySmall: caption.copyWith(color: Colors.grey.shade500),
    ),
    appBarTheme: AppBarTheme(
      backgroundColor: Colors.transparent,
      elevation: 0,
      centerTitle: false,
      titleTextStyle: h3.copyWith(color: textLight),
      iconTheme: const IconThemeData(color: textLight),
    ),
  );

  // ==================== HELPER METHODS ====================

  /// Minimal card decoration with soft shadow
  static BoxDecoration minimalCard({
    Color? color,
    double borderRadius = radiusLarge,
  }) {
    return BoxDecoration(
      color: color ?? surface,
      borderRadius: BorderRadius.circular(borderRadius),
      boxShadow: cardShadow,
    );
  }

  /// Soft gradient for focus mode (subtle)
  static BoxDecoration softGradient({
    required List<Color> colors,
    double borderRadius = radiusLarge,
  }) {
    return BoxDecoration(
      gradient: LinearGradient(
        colors: colors,
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
      borderRadius: BorderRadius.circular(borderRadius),
    );
  }

  /// Glass effect (for overlays)
  static BoxDecoration glassContainer({
    Color? color,
    double borderRadius = radiusLarge,
  }) {
    return BoxDecoration(
      color: (color ?? Colors.white).withValues(alpha: 0.1),
      borderRadius: BorderRadius.circular(borderRadius),
      border: Border.all(
        color: Colors.white.withValues(alpha: 0.2),
        width: 1.5,
      ),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.1),
          blurRadius: 10,
          offset: const Offset(0, 4),
        ),
      ],
    );
  }

  // Deprecated gradients (kept for compatibility)
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [primary, Color(0xFF1F2937)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient successGradient = LinearGradient(
    colors: [success, Color(0xFF059669)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient warningGradient = LinearGradient(
    colors: [warning, Color(0xFFD97706)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient infoGradient = LinearGradient(
    colors: [info, Color(0xFF2563EB)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // Legacy gradient container (deprecated)
  static BoxDecoration gradientContainer({
    required Gradient gradient,
    double borderRadius = radiusLarge,
  }) {
    return BoxDecoration(
      gradient: gradient,
      borderRadius: BorderRadius.circular(borderRadius),
      boxShadow: cardShadow,
    );
  }
}
