# CHANGELOG — SmartCrew

Documento que registra todos los cambios funcionales y de UI del proyecto, sesión a sesión.
Cuando abras Claude Code en una sesión nueva, lee este archivo primero para tener el contexto al día.

---

## v2.4 — En curso (mayo 2026)

Plan completo: `SmartCrew_Correcciones_v2_4_para_Claude_Code.md` en la raíz.

### Bloque 6 — Bugs de UI (completado)

- **Dashboard, KPIs truncados**: en `lib/widgets/common_widgets.dart` el label de `StatCard` ahora admite 2 líneas con `height: 1.15`, `maxLines: 2`, fontSize 12. En `lib/screens/manager/dashboard_screen.dart` el `childAspectRatio` del GridView pasa de 1.4 a 1.1 para dejar más alto a cada card.
- **HEY YAT, overflow de 8px en cards "RECIENTES"**: en `lib/screens/crew/hey_yat_screen.dart`, método `_buildHistory()`, el `SizedBox(height: 68)` se sustituye por `ConstrainedBox(minHeight: 76, maxHeight: 96)`, el padding inferior del ListView pasa de 12 a 8, y el Column de cada card recibe `mainAxisSize: MainAxisSize.min` + `mainAxisAlignment: MainAxisAlignment.center`.
- **HEY YAT, overflow de 31px en el resultado**: en `lib/screens/crew/hey_yat_screen.dart`, método `_buildMain()`, se quita `mainAxisAlignment: MainAxisAlignment.center` del Column principal y `_buildStateContent()` queda envuelto en `Expanded(...)` para que el `SingleChildScrollView` interno de `_buildResultState()` reciba altura acotada y pueda hacer scroll real.

### Bloque 1 — Selector de idioma en pantalla de login (completado)

- **LanguageService ampliado** (`lib/services/language_service.dart`): nueva constante `_deviceKey = 'device_language'`, nuevos métodos `loadDeviceLanguage()` (lee preferencia guardada o cae al idioma del sistema si está entre los 5 soportados, fallback a inglés) y `setDeviceLanguage(code)` (persiste y aplica). Añadido `resetToDeviceLanguage()` para usarse en logout. El método antiguo `resetToDefault()` queda marcado como deprecated.
- **Inicialización al arrancar** (`lib/main.dart`): `await languageService.loadDeviceLanguage()` antes de `runApp()`, para que la pantalla de login aparezca ya en el idioma correcto sin parpadeo.
- **Selector visual en login** (`lib/screens/login_screen.dart`): nuevo widget privado `_LanguagePickerButton` que muestra bandera + código ISO ("🇬🇧 EN") arriba a la derecha. Al pulsar abre un `showModalBottomSheet` con los 5 idiomas (bandera + nombre nativo + check si está seleccionado). Aplicado a las tres vistas (`_WelcomeView`, `_RegisterView`, `_LoginView`) envolviendo el contenido en un Stack.
- **Logout vuelve al idioma del dispositivo** (`lib/screens/manager_home.dart` y `lib/screens/crew_home.dart`): los métodos `_switchProfile()` y `_changeUser()` ahora son async y llaman a `languageService.resetToDeviceLanguage()` en lugar de `resetToDefault()`.

### Bloques pendientes en la Tanda 1 (UI y refactors, sin SQL ni paquetes pesados)

- Bloque 5 — Rediseño del dashboard (estructura nueva, eliminar widget de escanear, consolidar incidencias, mover Tripulación al drawer)
- Bloque 3 — Reorganización de Certificados con vista jerárquica por tripulante

### Tanda 2 (requiere SQL en Supabase)

- Bloque 2 — Módulo Calendario con `table_calendar`, prompt extendido para EVENTO, recordatorios locales 24h/2h

### Tanda 3 (más compleja)

- Bloque 4 — Escaneo de certificados con IA, generación de PDF multipágina, upload a Supabase Storage, share intent nativo

---

## Estado técnico actual

- Flutter analyze: 44 issues preexistentes, ninguno bloqueante. Mayoría son `withOpacity` deprecado (Flutter pide migrar a `.withValues()`). Se atacarán en un bloque de limpieza posterior.
- Idiomas soportados: EN, ES, FR, RU, ZH. Idioma del dispositivo persistente desde la pantalla de login (Bloque 1); idioma por usuario persistente tras login (M10 previo).
- Supabase: 11 tablas, todas con políticas `anon_full_access` (riesgo CRÍTICO — pendiente de migrar a `auth.uid()` según `SmartCrew_Plan_Seguridad_Arquitectura.docx`).
