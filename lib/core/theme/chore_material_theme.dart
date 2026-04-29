import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Material 3 themes aligned with DESIGN_RULES §22 (platform defaults).
abstract final class ChoreMaterialTheme {
  static ThemeData get light {
    final colorScheme = ColorScheme(
      brightness: Brightness.light,
      primary: const Color(0xFF2E9D76),
      onPrimary: Colors.white,
      primaryContainer: const Color(0xFFDDF6EA),
      onPrimaryContainer: const Color(0xFF123A2D),
      secondary: const Color(0xFFF3B63F),
      onSecondary: const Color(0xFF3F2F0B),
      secondaryContainer: const Color(0xFFFFF1C7),
      onSecondaryContainer: const Color(0xFF3F2F0B),
      tertiary: const Color(0xFF4F8FD8),
      onTertiary: Colors.white,
      error: const Color(0xFFD9534F),
      onError: Colors.white,
      surface: Colors.white,
      onSurface: const Color(0xFF25312C),
      surfaceContainerHighest: const Color(0xFFF4EFE7),
      onSurfaceVariant: const Color(0xFF65736E),
      outline: const Color(0xFFC8D2CC),
      outlineVariant: const Color(0xFFE1E8E3),
    );
    final textTheme = GoogleFonts.nunitoSansTextTheme();
    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      textTheme: textTheme,
      scaffoldBackgroundColor: const Color(0xFFFFFDF7),
      appBarTheme: AppBarTheme(
        backgroundColor: colorScheme.surface,
        foregroundColor: colorScheme.onSurface,
        elevation: 0,
        titleTextStyle: GoogleFonts.nunitoSans(
          fontSize: 18,
          fontWeight: FontWeight.w700,
          color: colorScheme.onSurface,
        ),
      ),
      navigationBarTheme: NavigationBarThemeData(
        labelTextStyle: WidgetStatePropertyAll(
          GoogleFonts.nunitoSans(fontSize: 12, fontWeight: FontWeight.w600),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: colorScheme.surfaceContainerHighest,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        contentTextStyle: GoogleFonts.nunitoSans(color: Colors.white),
      ),
    );
  }

  static ThemeData get dark {
    final colorScheme = ColorScheme(
      brightness: Brightness.dark,
      primary: const Color(0xFF77D7B0),
      onPrimary: const Color(0xFF0D3024),
      primaryContainer: const Color(0xFF174D3B),
      onPrimaryContainer: const Color(0xFFDDF6EA),
      secondary: const Color(0xFFF5C96B),
      onSecondary: const Color(0xFF3F2F0B),
      secondaryContainer: const Color(0xFF5A4218),
      onSecondaryContainer: const Color(0xFFFFF1C7),
      tertiary: const Color(0xFF8BBDF2),
      onTertiary: const Color(0xFF10253D),
      error: const Color(0xFFFF8A8A),
      onError: const Color(0xFF3D1111),
      surface: const Color(0xFF18221E),
      onSurface: const Color(0xFFF3F8F4),
      surfaceContainerHighest: const Color(0xFF24322D),
      onSurfaceVariant: const Color(0xFFB9C8C0),
      outline: const Color(0xFF43524B),
      outlineVariant: const Color(0xFF2E3B36),
    );
    final textTheme = GoogleFonts.nunitoSansTextTheme(ThemeData(brightness: Brightness.dark).textTheme);
    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      textTheme: textTheme,
      scaffoldBackgroundColor: const Color(0xFF101815),
      appBarTheme: AppBarTheme(
        backgroundColor: colorScheme.surface,
        foregroundColor: colorScheme.onSurface,
        elevation: 0,
        titleTextStyle: GoogleFonts.nunitoSans(
          fontSize: 18,
          fontWeight: FontWeight.w700,
          color: colorScheme.onSurface,
        ),
      ),
      navigationBarTheme: NavigationBarThemeData(
        labelTextStyle: WidgetStatePropertyAll(
          GoogleFonts.nunitoSans(fontSize: 12, fontWeight: FontWeight.w600),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: colorScheme.surfaceContainerHighest,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        contentTextStyle: GoogleFonts.nunitoSans(color: Colors.white),
      ),
    );
  }
}
