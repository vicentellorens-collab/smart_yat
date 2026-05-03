# SmartYat — Design System Overhaul
# Prompt completo para Claude Code

---

## Contexto del producto

SmartYat es una app Flutter de gestión profesional de yates de superllujo.
Usuarios: capitanes, oficiales y tripulación. Funciona en tablets, PDAs y
teléfonos Android en puente, sala de máquinas y cubierta.

Estado previo del código: tipografías Orbitron y Exo2 (registro sci-fi),
colores navy intensos, bordes de colores en todos los lados de las cards.
Todo esto se reemplaza en este trabajo.

Tu misión es exclusivamente la capa visual: theme, tipografía, componentes
y apariencia de widgets. No toques lógica de negocio, modelos, providers
ni servicios.

---

## Filosofía de diseño

Tres palabras que rigen cada decisión: autoritario, preciso, marítimo.

Referencias: Garmin (claridad de instrumentación), Palantir (contención,
densidad de datos sin ruido visual), Beneteau/Hanse (marítimo profesional).

NO es:
- App de navegación recreativa
- Interfaz sci-fi o gaming (Orbitron era el error principal)
- SaaS genérico con tema oscuro
- Nada con anclas, olas, rosas de los vientos ni textura náutica

El color es señal, nunca decoración. Una card con count == 0 no tiene color
de estado. Una card con incidencias abiertas es roja. El color aparece
únicamente cuando el dato lo exige.

---

## Stack técnico

- Flutter + Provider (no cambiar arquitectura)
- Material Design 3 como estructura base — override completo de colores y tipo
- Fuentes: Barlow + Barlow Condensed + JetBrains Mono (todas via google_fonts,
  ya instalado)

---

## PASO 1 — lib/config/theme.dart

Reemplaza el archivo completo con esto:

```dart
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
    double size = 11,
    Color? color,
  }) => GoogleFonts.barlowCondensed(
    fontSize: size,
    fontWeight: FontWeight.w600,
    color: color ?? textSecondary,
    letterSpacing: 1.4,
  );

  // Títulos de card, items de lista
  static TextStyle cardTitle({
    double size = 14,
    Color? color,
    FontWeight weight = FontWeight.w600,
  }) => GoogleFonts.barlow(
    fontSize: size,
    fontWeight: weight,
    color: color ?? textPrimary,
  );

  // Cuerpo, etiquetas, info secundaria
  static TextStyle label({
    double size = 13,
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
    fontSize: 10,
    fontWeight: FontWeight.w500,
    color: color ?? textSecondary,
    letterSpacing: 0.8,
  );

  // ELIMINADO: AppTheme.orbitron() — reemplazar todas las referencias
  // en el codebase por el método correcto según contexto (ver tabla abajo)

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
        fontSize: 17,
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
        fontSize: 13, fontWeight: FontWeight.w600, letterSpacing: 0.8),
      unselectedLabelStyle: GoogleFonts.barlowCondensed(
        fontSize: 13, fontWeight: FontWeight.w500, letterSpacing: 0.8),
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
        textStyle: GoogleFonts.barlow(fontWeight: FontWeight.w600, fontSize: 14,
            letterSpacing: 0.3),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: accent,
        side: const BorderSide(color: accent),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        textStyle: GoogleFonts.barlow(fontWeight: FontWeight.w600, fontSize: 14),
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
      labelStyle: GoogleFonts.barlow(color: textSecondary, fontSize: 13),
      hintStyle: GoogleFonts.barlow(color: textTertiary, fontSize: 13),
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
          ? GoogleFonts.barlow(color: accent, fontSize: 10,
              fontWeight: FontWeight.w500, letterSpacing: 0.6)
          : GoogleFonts.barlow(color: textTertiary, fontSize: 10,
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
      contentTextStyle: GoogleFonts.barlow(color: textPrimary, fontSize: 13),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      behavior: SnackBarBehavior.floating,
    ),
    chipTheme: ChipThemeData(
      backgroundColor: surface01,
      selectedColor: accentDim,
      side: const BorderSide(color: borderSubtle),
      labelStyle: GoogleFonts.barlow(color: textPrimary, fontSize: 12),
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
```

### Tabla de sustitución de orbitron()

Localiza todas las llamadas a `AppTheme.orbitron()` en el proyecto y
sustitúyelas según el contexto:

| Contexto actual                        | Sustituir por                         |
|----------------------------------------|---------------------------------------|
| Títulos de pantalla / AppBar           | AppTheme.displayCondensed(size: 17)   |
| Saludo "Buen día" en dashboard         | AppTheme.displayCondensed(size: 22)   |
| Número grande en StatCard              | AppTheme.displayCondensed(size: 34)   |
| Cabecera de sección ("INCIDENCIAS...") | AppTheme.sectionLabel()               |
| Subtítulo de sección / "DATOS DEL..."  | AppTheme.sectionLabel(size: 11)       |
| Título de bottomsheet / dialog         | AppTheme.sectionLabel(size: 13)       |

Localiza también todas las referencias a `GoogleFonts.exo2()` y sustitúyelas
por `AppTheme.label()` o `AppTheme.cardTitle()` según contexto.

---

## PASO 2 — lib/widgets/common_widgets.dart

Reedita cada componente. No cambies los parámetros de los constructores.

### SectionTitle

```dart
class SectionTitle extends StatelessWidget {
  final String text;
  final Widget? trailing;
  const SectionTitle(this.text, {super.key, this.trailing});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(text.toUpperCase(), style: AppTheme.sectionLabel()),
        const Spacer(),
        if (trailing != null) trailing!,
      ],
    );
  }
}
```

### StatCard

El borde de color solo aparece en el lado izquierdo (3dp) cuando color !=
accent. No bordes de color en todos los lados.

```dart
class StatCard extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color color;
  final VoidCallback? onTap;

  const StatCard({
    super.key,
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
    this.onTap,
  });

  bool get _hasStatus => color != AppTheme.accent;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: _hasStatus
              ? (color == AppTheme.statusAlert
                  ? AppTheme.statusAlertBg
                  : AppTheme.statusWarnBg)
              : AppTheme.surface01,
          borderRadius: BorderRadius.circular(10),
          border: Border(
            left: BorderSide(
              color: _hasStatus ? color : AppTheme.borderSubtle,
              width: _hasStatus ? 3 : 1,
            ),
            top: const BorderSide(color: AppTheme.borderSubtle, width: 1),
            right: const BorderSide(color: AppTheme.borderSubtle, width: 1),
            bottom: const BorderSide(color: AppTheme.borderSubtle, width: 1),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: color, size: 20),
            const SizedBox(height: 8),
            Text(value, style: AppTheme.displayCondensed(size: 34, color: color)),
            const SizedBox(height: 4),
            Text(label, style: AppTheme.label(size: 11)),
          ],
        ),
      ),
    );
  }
}
```

### PriorityBadge

```dart
class PriorityBadge extends StatelessWidget {
  final TaskPriority priority;
  const PriorityBadge(this.priority, {super.key});

  @override
  Widget build(BuildContext context) {
    final (label, color) = switch (priority) {
      TaskPriority.alta  => ('ALTA',  AppTheme.statusAlert),
      TaskPriority.media => ('MEDIA', AppTheme.statusWarn),
      TaskPriority.baja  => ('BAJA',  AppTheme.textTertiary),
    };
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(3),
        border: Border.all(color: color.withOpacity(0.5)),
      ),
      child: Text(label, style: AppTheme.sectionLabel(size: 10, color: color)),
    );
  }
}
```

### TaskStatusChip

Completada es neutro (textSecondary), no verde. No usar pill shape.

```dart
class TaskStatusChip extends StatelessWidget {
  final TaskStatus status;
  const TaskStatusChip(this.status, {super.key});

  @override
  Widget build(BuildContext context) {
    final (label, color) = switch (status) {
      TaskStatus.pendiente  => ('Pendiente',   AppTheme.statusWarn),
      TaskStatus.enProgreso => ('En Progreso', AppTheme.accent),
      TaskStatus.completada => ('Completada',  AppTheme.textSecondary),
      TaskStatus.rechazada  => ('Rechazada',   AppTheme.statusAlert),
    };
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(3),
        border: Border.all(color: color.withOpacity(0.4)),
      ),
      child: Text(label, style: AppTheme.sectionLabel(size: 10, color: color)),
    );
  }
}
```

### AlertBadge

VENCIDO y 15d: fill sólido statusAlert, textInverse. OK: solo texto tertiary,
sin fondo ni borde.

```dart
class AlertBadge extends StatelessWidget {
  final AlertLevel level;
  final int days;
  const AlertBadge(this.level, this.days, {super.key});

  @override
  Widget build(BuildContext context) {
    return switch (level) {
      AlertLevel.none    => Text('OK', style: AppTheme.mono(size: 11,
          color: AppTheme.textTertiary)),
      AlertLevel.expired => _solidBadge('VENCIDO', AppTheme.statusAlert),
      AlertLevel.days15  => _solidBadge('${days}d', AppTheme.statusAlert),
      AlertLevel.days30  => _outlineBadge('${days}d', AppTheme.statusWarn),
      AlertLevel.days60  => _outlineBadge('${days}d', AppTheme.statusWarn),
      AlertLevel.days90  => _outlineBadge('${days}d', AppTheme.statusWarn),
    };
  }

  Widget _solidBadge(String text, Color color) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
    decoration: BoxDecoration(
      color: color,
      borderRadius: BorderRadius.circular(3),
    ),
    child: Text(text, style: AppTheme.sectionLabel(size: 10,
        color: AppTheme.textInverse)),
  );

  Widget _outlineBadge(String text, Color color) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
    decoration: BoxDecoration(
      color: color.withOpacity(0.12),
      borderRadius: BorderRadius.circular(3),
      border: Border.all(color: color.withOpacity(0.5)),
    ),
    child: Text(text, style: AppTheme.sectionLabel(size: 10, color: color)),
  );
}
```

### InventoryBadge

SIN STOCK: fill sólido. BAJO: outline. OK: solo texto, sin fondo.

```dart
class InventoryBadge extends StatelessWidget {
  final InventoryStatus status;
  const InventoryBadge(this.status, {super.key});

  @override
  Widget build(BuildContext context) {
    return switch (status) {
      InventoryStatus.ok => Text('OK', style: AppTheme.mono(size: 10,
          color: AppTheme.textTertiary)),
      InventoryStatus.bajo => Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
        decoration: BoxDecoration(
          color: AppTheme.statusWarnBg,
          borderRadius: BorderRadius.circular(3),
          border: Border.all(color: AppTheme.statusWarn.withOpacity(0.5)),
        ),
        child: Text('BAJO', style: AppTheme.sectionLabel(size: 10,
            color: AppTheme.statusWarn)),
      ),
      InventoryStatus.sinStock => Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
        decoration: BoxDecoration(
          color: AppTheme.statusAlert,
          borderRadius: BorderRadius.circular(3),
        ),
        child: Text('SIN STOCK', style: AppTheme.sectionLabel(size: 10,
            color: AppTheme.textInverse)),
      ),
    };
  }
}
```

### EmptyState

```dart
class EmptyState extends StatelessWidget {
  final IconData icon;
  final String message;
  const EmptyState({super.key, required this.icon, required this.message});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 48, color: AppTheme.textTertiary.withOpacity(0.4)),
          const SizedBox(height: 12),
          Text(message, style: AppTheme.label(size: 13,
              color: AppTheme.textTertiary), textAlign: TextAlign.center),
        ],
      ),
    );
  }
}
```

CategoryIcon y PrefTypeIcon: mantener los mismos colores de categoría — son
colores de identidad, no de estado. Solo sustituir orbitron/exo2 si
aparecen en esos widgets.

---

## PASO 3 — lib/screens/login_screen.dart

### _WelcomeView

Sustituye el bloque que contiene el Container circular con _YachtLogo +
"SmartYat" en orbitron + tagline en exo2, por esto:

```dart
SmartYatLogo(
  width: 200,
  showTagline: true,
),
```

Importa el widget al inicio del archivo:

```dart
import '../widgets/smartyat_logo.dart';
```

El _YachtLogo y _YachtPainter al final del archivo: mantenlos. No los
elimines — pueden usarse en otros contextos. Solo dejan de usarse en
_WelcomeView.

### Resto de _WelcomeView, _RegisterView, _LoginView

- Sustituir todas las llamadas a AppTheme.orbitron() por los equivalentes
  de la tabla del Paso 1
- Los botones, inputs y PIN pad ya quedan restyled por el theme
- _NumPadKey: cambiar border-radius de 12 a 8, border a borderSubtle
- _UserTile: border color por defecto -> borderSubtle. Border en error
  (bloqueado/expirado) -> statusAlert.withOpacity(0.4)
- CircleAvatar del avatar: backgroundColor -> accentDim, color de inicial -> accent

### _RegisterView — cabeceras de sección

Estas líneas:

```dart
Text('DATOS DEL ADMINISTRADOR', style: AppTheme.orbitron(size: 11, ...))
Text('DATOS DEL YATE', style: AppTheme.orbitron(size: 11, ...))
Text('PIN DE ACCESO', style: AppTheme.orbitron(size: 11, ...))
```

Sustituir por AppTheme.sectionLabel() en cada una.

---

## PASO 4 — lib/screens/manager/dashboard_screen.dart

### Saludo

```dart
Text(
  'Buen día, ${user?.name ?? 'Capitán'}',
  style: AppTheme.displayCondensed(size: 22),
),
```

Subtitle "Estado del yate..." -> AppTheme.label(size: 12).
Eliminar el Text de "Pulsa un widget para ir al módulo".

### Lógica de color en StatCards

Sustituir la lógica actual (que usa successColor cuando count == 0)
por esta regla: count == 0 -> AppTheme.accent, count > 0 -> color de estado.

```dart
StatCard(
  label: 'Tareas Activas',
  value: '${p.activeTasks}',
  icon: Icons.task_alt_outlined,
  color: AppTheme.accent,
  onTap: onActiveTasks,
),
StatCard(
  label: 'Tareas Rechazadas',
  value: '${p.rejectedTasks}',
  icon: Icons.cancel_outlined,
  color: p.rejectedTasks > 0 ? AppTheme.statusAlert : AppTheme.accent,
  onTap: onRejectedTasks,
),
StatCard(
  label: 'Incidencias Abiertas',
  value: '${p.openIncidents}',
  icon: Icons.warning_amber_outlined,
  color: p.openIncidents > 0 ? AppTheme.statusAlert : AppTheme.accent,
  onTap: onIncidents,
),
StatCard(
  label: 'Certs. con Alerta',
  value: '${p.alertCertificates}',
  icon: Icons.verified_outlined,
  color: p.alertCertificates > 0 ? AppTheme.statusWarn : AppTheme.accent,
  onTap: onCertificates,
),
StatCard(
  label: 'Stock Bajo/Agotado',
  value: '${p.lowStockItems}',
  icon: Icons.inventory_2_outlined,
  color: p.lowStockItems > 0 ? AppTheme.statusWarn : AppTheme.accent,
  onTap: onLowStock,
),
StatCard(
  label: 'Docs Escaneados',
  value: '${p.scannedDocuments.length}',
  icon: Icons.document_scanner_outlined,
  color: AppTheme.accent,
  onTap: onDocScan,
),
```

### _IncidentTile en dashboard

Añadir borde izquierdo 3dp en statusAlert. Fondo statusAlertBg.

```dart
Container(
  margin: const EdgeInsets.only(bottom: 8),
  decoration: BoxDecoration(
    color: AppTheme.statusAlertBg,
    borderRadius: BorderRadius.circular(10),
    border: Border(
      left: const BorderSide(color: AppTheme.statusAlert, width: 3),
      top: const BorderSide(color: AppTheme.borderSubtle, width: 1),
      right: const BorderSide(color: AppTheme.borderSubtle, width: 1),
      bottom: const BorderSide(color: AppTheme.borderSubtle, width: 1),
    ),
  ),
)
```

TextButton "Ver todas":

```dart
style: TextStyle(color: AppTheme.accent, fontSize: 12)
```

---

## PASO 5 — lib/screens/manager/tasks_screen.dart

- Todos los orbitron() / exo2() -> sustituir por tabla del Paso 1
- TaskCard titles -> AppTheme.cardTitle(size: 14)
- Task descriptions -> AppTheme.label(size: 12)
- Completada: color textSecondary, sin tachado (strikethrough = error visual)
- Rechazada: borde izquierdo 3dp statusAlert, fondo statusAlertBg
- timeAgo, fechas -> AppTheme.mono(size: 11)
- Filter chips seleccionados: accent border + accentDim background,
  border-radius 6 (no pill)
- Bottom sheet headers ('NUEVA TAREA', 'ASIGNACIÓN', etc.) -> sectionLabel()

---

## PASO 6 — lib/screens/manager/incidents_screen.dart

- Incidencias abiertas: borde izquierdo 3dp statusAlert, fondo statusAlertBg
- Incidencias cerradas/resueltas: borderSubtle, surface01, sin color de estado
- orbitron() / exo2() -> sustituir por tabla del Paso 1
- Fechas y IDs -> AppTheme.mono()
- Section headers -> AppTheme.sectionLabel()

---

## PASO 7 — lib/screens/manager/certificates_screen.dart

- Vencidos: borde izquierdo 3dp statusAlert, fondo statusAlertBg
- <= 15 días: borde izquierdo statusAlert, fondo statusAlertBg
- <= 30 días: borde izquierdo statusWarn, fondo statusWarnBg
- <= 60 días: borde izquierdo statusWarn, fondo Color(0x0BE09020)
- Válidos (OK): borderSubtle, surface01, sin color
- Fechas de vencimiento -> AppTheme.mono()
- Días restantes (número) -> AppTheme.mono(weight: FontWeight.w700) en color de estado
- orbitron() / exo2() -> sustituir

---

## PASO 8 — lib/screens/manager/inventory_screen.dart

- SIN STOCK: borde izquierdo 3dp statusAlert, fondo statusAlertBg
- BAJO: borde izquierdo statusWarn, fondo statusWarnBg
- OK: borderSubtle, surface01
- Contadores de stock -> AppTheme.mono()
- orbitron() / exo2() -> sustituir

---

## PASO 9 — lib/screens/manager/crew_screen.dart

- Cards de tripulante: surface01, borderSubtle — sin color de estado salvo
  que un cert de ese tripulante esté venciendo (en ese caso borde izq statusWarn)
- Nombres -> AppTheme.cardTitle(size: 14)
- Rol/posición -> AppTheme.label(size: 12)
- Avatares con iniciales: Container con accentDim background, texto en accent
  con AppTheme.displayCondensed(size: 18)
- orbitron() / exo2() -> sustituir

---

## PASO 10 — lib/screens/manager/owner_preferences_screen.dart

- Sin lógica de estado — todo es neutral
- Cards: surface01, borderSubtle
- Category headers -> AppTheme.sectionLabel()
- PrefTypeIcon: mantener los colores de categoría (son de identidad, no estado)
- orbitron() / exo2() -> sustituir

---

## PASO 11 — lib/screens/manager/document_scan_screen.dart

- Lista de documentos: surface01, borderSubtle
- Timestamps -> AppTheme.mono()
- Botones de acción -> theme ElevatedButton / OutlinedButton, sin override de color
- orbitron() / exo2() -> sustituir

---

## PASO 12 — lib/screens/crew/hey_yat_screen.dart

- Indicador de actividad de voz -> solo color accent
- Respuestas de texto -> AppTheme.label(size: 14, color: AppTheme.textPrimary)
- Sin Card surfaces adicionales salvo que el contenido lo requiera
- orbitron() / exo2() -> sustituir

---

## PASO 13 — lib/screens/crew/my_tasks_screen.dart

- Mismas reglas de card que tasks_screen.dart
- Badges y chips ya actualizados desde common_widgets
- orbitron() / exo2() -> sustituir

---

## PASO 14 — lib/screens/force_pin_change_screen.dart

Logo en la parte superior, centrado:

```dart
import '../widgets/smartyat_logo.dart';

// En el build, antes del primer campo:
SmartYatLogo(width: 150),
const SizedBox(height: 32),
```

- PIN digit inputs custom: borde borderActive, foco en accent,
  dígitos con AppTheme.displayCondensed(size: 24)
- orbitron() / exo2() -> sustituir

---

## PASO 15 — lib/screens/manager_home.dart y crew_home.dart

El NavigationBar necesita un borde superior de 1px. Envolver en Column:

```dart
Column(
  mainAxisSize: MainAxisSize.min,
  children: [
    const Divider(height: 1, thickness: 1, color: AppTheme.borderSubtle),
    NavigationBar(
      backgroundColor: AppTheme.navBg,
      // ... destinations sin cambios
    ),
  ],
)
```

Sin píldora indicadora — ya configurado en el theme con
indicatorColor: Colors.transparent.

orbitron() / exo2() en estos archivos -> sustituir.

---

## Logo — archivos ya en el proyecto

Los siguientes archivos ya están creados y no deben modificarse:

  lib/widgets/smartyat_logo.dart
  assets/images/smartyat_logo.svg
  assets/images/smartyat_logo_tagline.svg

El widget SmartYatLogo usa google_fonts (Barlow Condensed), escala
desde el parámetro width, y posiciona la línea cyan bajo "YAT".

Uso:

```dart
import '../widgets/smartyat_logo.dart';    // desde lib/screens/
import '../../widgets/smartyat_logo.dart'; // desde lib/screens/manager/ o crew/

SmartYatLogo(width: 200, showTagline: true) // login
SmartYatLogo(width: 150)                    // PIN screen
```

El logo aparece SOLO en pantallas pre-autenticación (login, PIN).
No añadir en ninguna pantalla post-login.

---

## Lo que NO tocar

- lib/models/models.dart
- lib/providers/app_provider.dart
- lib/services/
- lib/config/api_config.dart
- pubspec.lock
- Lógica de negocio, navegación, llamadas a Provider
- _YachtPainter y _YachtLogo en login_screen.dart (mantener, solo dejar
  de usarlos en _WelcomeView)

---

## Checklist de verificación

Después de cada archivo, verificar:

- Sin referencias a AppTheme.orbitron() ni GoogleFonts.orbitron()
- Sin referencias a GoogleFonts.exo2() ni exo2TextTheme
- Sin AppTheme.successColor — el estado OK usa AppTheme.accent
- Cards con count == 0 no tienen color de estado (solo accent)
- Bordes de color solo en el lado izquierdo (3dp), nunca en los 4 lados
- Números de dashboard usan displayCondensed(size: 34)
- Cabeceras de sección usan sectionLabel() en MAYÚSCULAS
- NavigationBar sin píldora indicadora, con borde superior 1px
- Ningún hex hardcodeado — todos los colores via AppTheme.*
