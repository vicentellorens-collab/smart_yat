# CLAUDE.md — SmartYat

Este archivo orienta a Claude Code al trabajar en este repositorio.
Léelo antes de empezar cualquier tarea.

## Proyecto

SmartYat es una app Flutter de gestión operativa inteligente para yates:
tareas, tripulación, certificados, inventario, incidencias, asistente de voz HEY YAT.

Slogan: **"Enhance your crew."**

El nombre canónico es **SmartYat**. Los nombres "Smart Yat OS" y "SmartCrew"
aparecen en documentos antiguos pero ya no se usan. Si los ves en código o docs,
trátalos como erratas históricas — el naming actual es SmartYat.

## Stack

- **Flutter** (Dart) — Android primero, iOS previsto
- **Supabase** — PostgreSQL, Storage, Auth (pendiente), Edge Functions (pendiente)
  - URL: `https://egetcuorhgmpygxcpfjk.supabase.co`
- **Anthropic Claude API** — clasificación de voz HEY YAT, OCR de certificados,
  traducción canónica a inglés (`canonical_english`) para multiidioma

## Comandos clave

```bash
flutter pub get              # Instalar dependencias
flutter run                  # Ejecutar en emulador o dispositivo conectado
flutter analyze              # Linter
flutter test                 # Tests
flutter build apk --debug    # APK de pruebas
flutter build apk --release  # APK de producción
```

## Estructura esperada

```
smart_yat/
├── lib/
│   ├── config/          # api_config.dart, supabase_config.dart (gitignored)
│   ├── constants/       # listas predefinidas: cargos, certificados, departamentos, unidades
│   ├── models/          # modelos de datos (Task, CrewMember, Certificate, Incident, etc.)
│   ├── screens/         # UI agrupada por módulo
│   │   ├── auth/
│   │   ├── crew/
│   │   ├── tasks/
│   │   ├── certificates/
│   │   ├── inventory/
│   │   ├── incidents/
│   │   ├── dashboard/
│   │   └── voice/       # HEY YAT
│   ├── services/        # supabase_service, voice_classification_service, etc.
│   ├── widgets/         # widgets reutilizables
│   ├── l10n/            # archivos de localización (EN, ES, FR, RU, ZH)
│   └── main.dart
├── assets/              # imágenes, logo, fuentes
├── android/             # config nativa Android
├── ios/                 # config nativa iOS (futuro)
└── pubspec.yaml
```

Si la estructura real difiere, prioriza la real e infórmame antes de moverla.

## Convenciones de código

- Variables, funciones y archivos en inglés
- Strings de UI en el sistema multiidioma — nunca hardcodear textos visibles
- Indentación de 2 espacios (estándar Dart)
- `async/await`, no `.then()`
- `const` cuando se pueda; `final` por defecto sobre `var`
- Pantallas: `StatefulWidget` solo si tienen estado interno; en otro caso `StatelessWidget`
- Servicios externos (Supabase, Claude API) como singletons inyectables
- Nombres de tablas Supabase en `snake_case` plural (`crew_members`, `inventory_items`)
- Nombres de campos en `snake_case` (`created_at`, `yacht_id`, `canonical_english`)

## Configuración y secretos

- API keys NUNCA se commitean
- `lib/config/api_config.dart` está en `.gitignore`
- La `anon_key` de Supabase es pública por diseño, pero la `service_role_key` jamás va al cliente
- Si necesitas leer un secreto y no está disponible, pídeselo a Vicente — no lo inventes

## Esquema Supabase actual

11 tablas, todas con `yacht_id` como clave de aislamiento por yate:

`yachts`, `users`, `crew_members`, `tasks`, `certificates`, `inventory_items`,
`incidents`, `voice_commands`, `pending_voice_messages`, `scanned_documents`,
`owner_preferences` (en desuso desde v2.2).

**Aviso de seguridad:** todas las tablas tienen RLS habilitado pero con política
`anon_full_access` que anula la protección. Está documentado en el plan de
seguridad y la Fase 1 (integrar Supabase Auth + políticas RLS por `yacht_id`)
es bloqueante antes de publicar en Google Play. No introduzcas funcionalidad
nueva que dependa de la seguridad actual asumiendo que es correcta — no lo es.

## Workflow de cambios

1. Lee este archivo y los docs relevantes antes de tocar código
2. Revisa los archivos del módulo afectado para conocer las convenciones reales
3. Implementa los cambios siguiendo el estilo existente
4. Si añades dependencias en `pubspec.yaml`, ejecuta `flutter pub get` y justifícalo brevemente
5. Verifica con `flutter analyze` antes de dar por terminado
6. Si el cambio toca BD, genera la migración SQL correspondiente y guárdala en `/supabase/migrations`
7. Al final de la sesión, recuerda al usuario el commit a GitHub:

```bash
git add .
git commit -m "mensaje descriptivo en imperativo"
git push
```

## Cosas que NO hacer

- No cambiar el naming del proyecto: es SmartYat
- No commitear API keys, anon keys con bypass, ni nada en `lib/config/api_config.dart`
- No tocar `android/app/build.gradle` ni `AndroidManifest.xml` salvo necesidad real y avisando antes
- No introducir librerías pesadas sin justificarlo — la app corre en tablets modestas
- No romper el modo offline-first: cualquier nueva funcionalidad debe seguir funcionando sin red
- No hardcodear strings visibles para el usuario — pasan por el sistema de localización
- No asumir que la migración SQL ya está aplicada en Supabase: confirma antes de usar columnas nuevas

## Estilo de respuesta

Directo y técnico. Sin "¡por supuesto!", sin parafrasear la petición, sin entusiasmo de relleno.
Si no sabes algo del código local, léelo antes de inventar.
Si una decisión es del usuario (naming, UX, prioridad), pregunta — no asumas.
Cuando termines una tarea, resume en una frase qué cambió y dónde.
