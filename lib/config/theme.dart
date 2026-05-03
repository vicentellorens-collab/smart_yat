import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {

  // ── SURFACES ────────────────────────────────────────────────────────────
  static const Color background   = Color(0xFF0C1520);
  static const Color surface01    = Color(0xFF111C2A);
  static const Color surface02    = Color(0xFF162236);
  static const Color surface03    = Color(0xFF1C2D45);
  static const Color borderSubtle = Color(0xFF1E3050);
  static const Color borderActive = Color(0xFF2A4A70);
  static const Color navBg        = Color(0xFF0A1219);

  // ── ACCENT — uno solo ───────────────────────────────────────────────────
  static const Color accent    = Color(0xFF0ABFC8);
  static const Color accentDim = Color(0x200ABFC8);

  // ── STATUS — solo cuando el dato lo exige ───────────────────────────────
  static const Color statusOk      = Color(0xFF0ABFC8);
  static const Color statusWarn    = Color(0xFFE09020);
  static const Color statusAlert   = Color(0xFFE03535);
  static const Color statusWarnBg  = Color(0x15E09020);
  static const Color statusAlertBg = Color(0x15E03535);

  // ── TEXTO ────────────────────────────────────────────────────────────────
  static const Color textPrimary   = Color(0xFFE8EDF2);
  static const Color textSecondary = Color(0xFF8A9BAE);
  static const Color textTertiary  = Color(0xFF4A6080);
  static const Color textInverse   = Color(0xFF0C1520);

  // ── ALIAS DE COMPATIBILIDAD (no usar en código nuevo) ───────────────────
  static const Color panel        = surface01;
  static const Color dividerColor = borderSubtle;
  static const Color errorColor   = statusAlert;
  static const Color warningColor = statusWarn;
  // successColor eliminado — el estado OK usa accent, no verde

  // ── TIPOGRAFÍA ───────────────────────────────────────────────────────────

  // Números de dashboard, títulos de pantalla
  static TextStyle displayCondensed({
    double size = 36,
    FontWeight weight = FontWeight.w700,
    Color? color,
  }) => GoogleFonts.barlowCondensed(
    fontSize: size,
    fontWeight: weight,
    color: color ?? textPrimary,
    letterSpacing: -0.5,
  );

  // Cabeceras de sección — usar siempre en MAYÚSCULAS en la UI
  static TextStyle sectionLabel({
    double size = 13,
    Color? color,
  }) => GoogleFonts.barlowCondensed(
    fontSize: size,
    fontWeight: FontWeight.w600,
    color: color ?? textSecondary,
    letterSpacing: 1.2,
  );

  // Títulos de card, items de lista
  static TextStyle cardTitle({
    double size = 15,
    Color? color,
    FontWeight weight = FontWeight.w600,
  }) => GoogleFonts.barlow(
    fontSize: size,
    fontWeight: weight,
    color: color ?? textPrimary,
  );

  // Cuerpo, etiquetas, info secundaria
  static TextStyle label({
    double size = 14,
    Color? color,
    FontWeight weight = FontWeight.w400,
  }) => GoogleFonts.barlow(
    fontSize: size,
    fontWeight: weight,
    color: color ?? textSecondary,
  );

  // Datos numéricos: contadores, IDs, timestamps
  static TextStyle mono({
    double size = 13,
    Color? color,
    FontWeight weight = FontWeight.w400,
  }) => GoogleFonts.jetBrainsMono(
    fontSize: size,
    fontWeight: weight,
    color: color ?? textPrimary,
  );

  // Etiquetas de nav bar
  static TextStyle navLabel({Color? color}) => GoogleFonts.barlow(
    fontSize: 11,
    fontWeight: FontWeight.w500,
    color: color ?? textSecondary,
    letterSpacing: 0.8,
  );

  // ── THEME ────────────────────────────────────────────────────────────────

  static ThemeData get darkTheme => ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    scaffoldBackgroundColor: background,
    primaryColor: accent,
    colorScheme: const ColorScheme.dark(
      primary: accent,
      secondary: accent,
      surface: surface01,
      error: statusAlert,
    ),
    textTheme: GoogleFonts.barlowTextTheme(
      ThemeData.dark().textTheme,
    ).apply(bodyColor: textPrimary, displayColor: textPrimary),
    appBarTheme: AppBarTheme(
      backgroundColor: background,
      elevation: 0,
      scrolledUnderElevation: 0,
      titleTextStyle: GoogleFonts.barlowCondensed(
        color: textPrimary,
        fontSize: 19,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.8,
      ),
      iconTheme: const IconThemeData(color: textSecondary),
      actionsIconTheme: const IconThemeData(color: textSecondary),
    ),
    tabBarTheme: TabBarThemeData(
      labelColor: accent,
      unselectedLabelColor: textTertiary,
      indicatorColor: accent,
      indicatorSize: TabBarIndicatorSize.tab,
      dividerColor: borderSubtle,
      labelStyle: GoogleFonts.barlowCondensed(
        fontSize: 14, fontWeight: FontWeight.w600, letterSpacing: 0.8),
      unselectedLabelStyle: GoogleFonts.barlowCondensed(
        fontSize: 14, fontWeight: FontWeight.w500, letterSpacing: 0.8),
    ),
    cardTheme: CardThemeData(
      color: surface01,
      elevation: 0,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
        side: const BorderSide(color: borderSubtle, width: 1),
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: accent,
        foregroundColor: textInverse,
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        textStyle: GoogleFonts.barlow(fontWeight: FontWeight.w600, fontSize: 15,
            letterSpacing: 0.3),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: accent,
        side: const BorderSide(color: accent),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        textStyle: GoogleFonts.barlow(fontWeight: FontWeight.w600, fontSize: 15),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: surface01,
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: borderSubtle),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: borderSubtle),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: accent, width: 1.5),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: statusAlert),
      ),
      labelStyle: GoogleFonts.barlow(color: textSecondary, fontSize: 14),
      hintStyle: GoogleFonts.barlow(color: textTertiary, fontSize: 14),
    ),
    navigationBarTheme: NavigationBarThemeData(
      backgroundColor: navBg,
      height: 64,
      elevation: 0,
      surfaceTintColor: Colors.transparent,
      shadowColor: Colors.transparent,
      indicatorColor: Colors.transparent,
      iconTheme: WidgetStateProperty.resolveWith((s) =>
        s.contains(WidgetState.selected)
          ? const IconThemeData(color: accent, size: 22)
          : const IconThemeData(color: textTertiary, size: 22)),
      labelTextStyle: WidgetStateProperty.resolveWith((s) =>
        s.contains(WidgetState.selected)
          ? GoogleFonts.barlow(color: accent, fontSize: 11,
              fontWeight: FontWeight.w500, letterSpacing: 0.6)
          : GoogleFonts.barlow(color: textTertiary, fontSize: 11,
              fontWeight: FontWeight.w400)),
    ),
    dividerTheme: const DividerThemeData(color: borderSubtle, thickness: 1),
    floatingActionButtonTheme: const FloatingActionButtonThemeData(
      backgroundColor: accent, foregroundColor: textInverse, elevation: 0),
    bottomSheetTheme: const BottomSheetThemeData(
      backgroundColor: surface02,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(14))),
      dragHandleColor: borderActive,
    ),
    dialogTheme: DialogThemeData(
      backgroundColor: surface02,
      surfaceTintColor: Colors.transparent,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    ),
    snackBarTheme: SnackBarThemeData(
      backgroundColor: surface02,
      contentTextStyle: GoogleFonts.barlow(color: textPrimary, fontSize: 14),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      behavior: SnackBarBehavior.floating,
    ),
    chipTheme: ChipThemeData(
      backgroundColor: surface01,
      selectedColor: accentDim,
      side: const BorderSide(color: borderSubtle),
      labelStyle: GoogleFonts.barlow(color: textPrimary, fontSize: 13),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
    ),
    checkboxTheme: CheckboxThemeData(
      fillColor: WidgetStateProperty.resolveWith((s) =>
        s.contains(WidgetState.selected) ? accent : Colors.transparent),
      side: const BorderSide(color: borderActive, width: 1.5),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(3)),
    ),
    switchTheme: SwitchThemeData(
      thumbColor: WidgetStateProperty.resolveWith((s) =>
        s.contains(WidgetState.selected) ? accent : textTertiary),
      trackColor: WidgetStateProperty.resolveWith((s) =>
        s.contains(WidgetState.selected) ? accentDim : borderSubtle),
    ),
    progressIndicatorTheme: const ProgressIndicatorThemeData(color: accent),
  );
}
