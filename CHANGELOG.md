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

### Bloque 5 — Rediseño del dashboard y navegación (completado)

- **Bottom nav reducido a 5 items** (`lib/screens/manager_home.dart`): Dashboard, Tasks, Incidents, Certificates, Inventory. Eliminado el destino Crew, que ahora vive en el drawer lateral. Cada destino mantiene su Badge con el contador correspondiente (activeTasks, openIncidents, alertCertificates, lowStockItems). Eliminado el Badge duplicado que el Dashboard mostraba con openIncidents.
- **Drawer lateral nuevo** (`lib/screens/manager_home.dart`): el `showModalBottomSheet` que se abría con `more_vert` queda sustituido por un Drawer accesible con icono de hamburguesa. Contiene: header con logo + nombre de usuario + nombre del yate, Tripulación, Calendario (placeholder hasta Bloque 2), Lista de compras (placeholder), Historial de tareas (placeholder), Idioma, Cambiar de usuario y Cerrar sesión (rojo).
- **Logout corregido** (`lib/screens/manager_home.dart`): método `_logout()` extraído y ahora llama a `languageService.resetToDeviceLanguage()` en lugar del antiguo `resetToDefault()`. Cierra el gap del Bloque 1.
- **Tripulación dentro del Scaffold padre** (`lib/screens/manager_home.dart`, `lib/screens/manager/crew_screen.dart`): cuando el usuario abre Tripulación desde el drawer, se activa el flag `_showCrewScreen=true` y el body del Scaffold raíz cambia a `CrewScreen` sin pushear ruta nueva, manteniendo el bottom nav visible. Para evitar doble AppBar, `CrewScreen` ya no tiene `Scaffold.appBar` propio; el título "Crew" lo gestiona el AppBar del Scaffold padre. Body con `Padding(top: 8)` para no quedar pegado al borde superior.
- **Back button Android gestionado** (`lib/screens/manager_home.dart`): `PopScope(canPop: !_showCrewScreen)` envuelve el Scaffold raíz. Cuando estamos en Tripulación, el botón atrás vuelve al Dashboard en lugar de cerrar la app.
- **Dashboard rediseñado** (`lib/screens/manager/dashboard_screen.dart`): GridView de 2×3 a 2×2 con las 4 cards prioritarias (Active tasks, Open incidents, Certificate alerts, Low stock). Eliminadas las cards `rejectedTasks` y `scanDocument`, junto a sus callbacks `onRejectedTasks` y `onDocScan`. Nueva sección "Próximos eventos" con placeholder *"No hay eventos próximos. Próximamente podrás añadirlos desde HEY YAT."* — quedará conectada en el Bloque 2 (Calendario). Mapping de iconos verificado: Certificates con `verified_outlined`, Inventory con `inventory_2_outlined`.

Notas técnicas:
- `flutter analyze` baja de 44 a 43 issues (uno menos porque la variable `user` ahora se usa en el header del drawer).
- `lib/screens/manager/document_scan_screen.dart` y `lib/screens/manager/owner_preferences_screen.dart` siguen existiendo en disco pero ya no se referencian desde el nav. Se mantienen como referencia hasta que Bloque 4 (escaneo de certificados) decida si la lógica de escaneo se reutiliza o se reimplementa.

### Bloque 3 — Certificados con vista jerárquica por tripulante (completado)

- **Pestaña "Del Barco" sin cambios** en `lib/screens/manager/certificates_screen.dart`. La pestaña "Tripulantes" pasa de lista plana a vista de dos niveles.
- **Nivel 1 — lista de tripulantes con resumen** (`_buildLevel1()`): cada `_CrewWithCertsTile` muestra avatar (foto o iniciales), nombre, cargo · departamento, y badges-pill a la derecha con el conteo por estado (🔴 vencidos + <30d, 🟡 30-90d, 🟢 >90d) mediante `_StatusPill`. Tripulantes sin certificados muestran un pill gris "Sin certificados". Orden de la lista: tripulantes con rojos+vencidos descendente → solo amarillos descendente → solo verdes → sin certificados.
- **Grupo "Sin asignar"** (`_OrphanTile` + `_buildOrphansLevel2()`): los certificados con `certCategory='tripulante'` pero `crewMemberId==null` aparecen al final de la lista de nivel 1 con icono `warning_amber` y subtexto del número de certificados huérfanos. Al pulsar, se accede al detalle como un grupo más para poder reasignarlos al editar.
- **Nivel 2 — detalle del tripulante** (`_buildLevel2()`): header con flecha de retorno, avatar, nombre y rol, seguido de la lista de certificados ordenada estrictamente Vencidos → Rojos → Amarillos → Verdes (`_certSortKey()`), y dentro de cada grupo por `daysUntilExpiry` ascendente. Reutiliza el `_CertCard` existente sin tocarlo.
- **Buscador y filtro por departamento** (`_DeptChip`): el buscador filtra tripulantes (nivel 1) o certificados (nivel 2). El chip de departamento (Deck, Interior, Cook, Engine) filtra la lista de tripulantes en nivel 1.
- **FAB añadir certificado** desde nivel 2: el diálogo `_showCertDialog()` ahora acepta `preselectedCrew`; cuando se llama desde el detalle de un tripulante, el dropdown de tripulantes viene ya rellenado con el actual y `certCategory='tripulante'` pre-set.
- **Back button Android gestionado** (`PopScope(canPop: !_inLevel2)`): cuando estamos en nivel 2 (un tripulante seleccionado o el grupo de huérfanos), el botón atrás vuelve a nivel 1 en lugar de salir de la pantalla de Certificados.
- **Reset al cambiar de pestaña**: un listener del `TabController` resetea `_selectedCrew`, `_showOrphans` y `_departmentFilter` cuando el usuario alterna entre Barco y Tripulantes, evitando estados inconsistentes.

Notas técnicas:
- `flutter analyze`: el archivo certificates_screen.dart reporta 10 issues (1 unused_import dart:io, 3 curly_braces_in_flow_control_structures, 1 deprecated `value` en form field y varios `withOpacity` → todos preexistentes o cosméticos, marcados para Bloque 7).

### Bloques pendientes en la Tanda 1 (UI y refactors, sin SQL ni paquetes pesados)

*(todos completados — ver Estado de la Tanda 1 al final)*

### Bloque 7 — Limpieza técnica (pendiente, tras las tres tandas)

Bloque de mantenimiento para resolver los 43 issues actuales de `flutter analyze`. No bloquean publicación pero conviene atacarlos antes de Google Play. Orden de prioridad:

1. **`use_build_context_synchronously`** (2 ocurrencias en `lib/screens/crew/hey_yat_screen.dart`): riesgo real de crash si el widget se desmonta durante un await. Envolver con `if (!mounted) return;` o equivalente tras cada await.
2. **Migración `withOpacity` → `withValues(alpha: ...)`** (~35 ocurrencias en varios archivos): cosmético hoy, pero error en futuras versiones de Flutter. Reemplazo masivo con verificación visual.
3. **Código muerto**: `_YachtLogo` no referenciado en `login_screen.dart`, `import dart:io` sin usar en `certificates_screen.dart`, variable `user` sin usar en otros sitios. Eliminar.
4. **Convenciones de estilo**: `sort_child_properties_last` en `force_pin_change_screen.dart` y `login_screen.dart`, `prefer_interpolation_to_compose_strings` en `auth_service.dart`. Cosmético.

### Estado de la Tanda 1 (UI y refactors, sin SQL ni paquetes pesados)

✅ Bloque 6 — Bugs de UI (overflows y truncados)
✅ Bloque 1 — Selector de idioma en pantalla de login
✅ Bloque 5 — Rediseño del dashboard, drawer lateral y nav reducido
✅ Bloque 3 — Certificados con vista jerárquica por tripulante

Tanda 1 completada. Pendiente de validación visual en dispositivo real antes de arrancar Tanda 2 (Bloque 2 — Calendario, que añade migración SQL y dependencias nuevas).

### Tanda 2 (requiere SQL en Supabase)

- Bloque 2 — Módulo Calendario con `table_calendar`, prompt extendido para EVENTO, recordatorios locales 24h/2h

### Tanda 3 (más compleja)

- Bloque 4 — Escaneo de certificados con IA, generación de PDF multipágina, upload a Supabase Storage, share intent nativo

---

## Estado técnico actual

- Flutter analyze: 43 issues preexistentes, ninguno bloqueante. Mayoría son `withOpacity` deprecado (Flutter pide migrar a `.withValues()`). Se atacarán en un bloque de limpieza posterior.
- Idiomas soportados: EN, ES, FR, RU, ZH. Idioma del dispositivo persistente desde la pantalla de login (Bloque 1); idioma por usuario persistente tras login (M10 previo).
- Supabase: 11 tablas, todas con políticas `anon_full_access` (riesgo CRÍTICO — pendiente de migrar a `auth.uid()` según `SmartCrew_Plan_Seguridad_Arquitectura.docx`).
