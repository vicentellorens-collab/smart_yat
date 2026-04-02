import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  static const Color background = Color(0xFF060d1a);
  static const Color accent = Color(0xFF00b4d8);
  static const Color panel = Color(0xFF0d1e35);
  static const Color textPrimary = Color(0xFFe0f4ff);
  static const Color textSecondary = Color(0xFF7fb5d4);
  static const Color errorColor = Color(0xFFef4444);
  static const Color warningColor = Color(0xFFf59e0b);
  static const Color successColor = Color(0xFF10b981);
  static const Color dividerColor = Color(0xFF1a3a5c);

  static TextStyle orbitron({
    double size = 16,
    FontWeight weight = FontWeight.bold,
    Color? color,
  }) {
    return GoogleFonts.orbitron(
      fontSize: size,
      fontWeight: weight,
      color: color ?? textPrimary,
    );
  }

  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: background,
      primaryColor: accent,
      colorScheme: const ColorScheme.dark(
        primary: accent,
        secondary: accent,
        surface: panel,
        error: errorColor,
      ),
      textTheme: GoogleFonts.exo2TextTheme(ThemeData.dark().textTheme).apply(
        bodyColor: textPrimary,
        displayColor: textPrimary,
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: panel,
        elevation: 0,
        titleTextStyle: GoogleFonts.orbitron(
          color: textPrimary,
          fontSize: 15,
          fontWeight: FontWeight.bold,
        ),
        iconTheme: const IconThemeData(color: accent),
        actionsIconTheme: const IconThemeData(color: accent),
      ),
      cardTheme: CardThemeData(
        color: panel,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: const BorderSide(color: dividerColor, width: 1),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: accent,
          foregroundColor: background,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          textStyle:
              GoogleFonts.exo2(fontWeight: FontWeight.bold, fontSize: 14),
          padding:
              const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: accent,
          side: const BorderSide(color: accent),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          textStyle:
              GoogleFonts.exo2(fontWeight: FontWeight.w600, fontSize: 14),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: background,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: dividerColor),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: dividerColor),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: accent, width: 1.5),
        ),
        labelStyle: const TextStyle(color: textSecondary),
        hintStyle: const TextStyle(color: textSecondary),
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: panel,
        height: 64,
        indicatorColor: accent.withOpacity(0.15),
        iconTheme: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return const IconThemeData(color: accent, size: 22);
          }
          return const IconThemeData(color: textSecondary, size: 22);
        }),
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return GoogleFonts.exo2(
                color: accent, fontSize: 10, fontWeight: FontWeight.bold);
          }
          return GoogleFonts.exo2(color: textSecondary, fontSize: 10);
        }),
      ),
      dividerTheme:
          const DividerThemeData(color: dividerColor, thickness: 1),
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: accent,
        foregroundColor: background,
      ),
      bottomSheetTheme: const BottomSheetThemeData(
        backgroundColor: panel,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
        ),
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: panel,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: panel,
        contentTextStyle: GoogleFonts.exo2(color: textPrimary),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        behavior: SnackBarBehavior.floating,
      ),
      chipTheme: ChipThemeData(
        backgroundColor: background,
        selectedColor: accent.withOpacity(0.2),
        side: const BorderSide(color: dividerColor),
        labelStyle: GoogleFonts.exo2(color: textPrimary, fontSize: 12),
      ),
    );
  }
}
