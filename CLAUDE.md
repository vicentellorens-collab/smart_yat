# Contexto persistente del proyecto

**Lee siempre CHANGELOG.md antes de empezar una sesión nueva.** Contiene el estado funcional actual del proyecto, los cambios aplicados recientemente y el plan de trabajo en curso.

Plan de trabajo actual: `SmartCrew_Correcciones_v2_4_para_Claude_Code.md`.

---

# Smart Yat – CLAUDE.md

## Qué es este proyecto
Smart Yat es una app móvil (Android/iOS) de gestión de tripulación para superyates.
Permite a armadores y capitanes gestionar documentación, certificados y comunicación
de la tripulación desde un dispositivo. Slogan: "Intelligent yatch management".

## Stack técnico
- **Frontend:** Flutter / Dart
- **Backend:** Supabase (base de datos, autenticación, storage)
- **AI:** Claude API (Anthropic) – asistente de voz HEY YAT
- **Pagos:** Stripe (pendiente de implementar)
- **Target:** Android + iOS (también configurado para Linux, macOS, Web, Windows)

## Estructura real del proyecto

lib/
  main.dart
  config/
    api_config.dart          ← claves y configuración de APIs
    api_config.example.dart  ← plantilla sin datos sensibles
    theme.dart               ← tema visual de la app
  l10n/                      ← internacionalización (EN, ES, FR, RU, ZH)
  models/
    models.dart
  providers/
    app_provider.dart        ← gestión de estado global
  screens/
    login_screen.dart
    force_pin_change_screen.dart
    crew_home.dart
    manager_home.dart
    crew/                    ← pantallas de tripulante
    manager/                 ← pantallas de manager/capitán
    settings/
  services/
    ai_service.dart          ← integración Claude API (HEY YAT)
    auth_service.dart
    connectivity_service.dart
    document_scan_service.dart
    language_service.dart
    secure_auth_storage.dart ← credenciales seguras
    storage_service.dart     ← Supabase storage
    supabase_service.dart    ← cliente Supabase principal
    translation_service.dart
    tts_service.dart         ← text-to-speech (voz HEY YAT)
  widgets/
    common_widgets.dart
    smartyat_logo.dart
    translated_text.dart

assets/
  images/
    smartyat_logo.svg
    smartyat_logo_tagline.svg

supabase/
  migrations/
    20260502_multilingual.sql

## Plugins Flutter en uso
- local_auth_android – biometría y PIN
- flutter_secure_storage – almacenamiento seguro
- speech_to_text – entrada de voz (HEY YAT)
- flutter_tts – text-to-speech (respuesta HEY YAT)
- camera_android_camerax – escaneo de documentos
- image_picker_android – selección de imágenes
- file_picker – selección de archivos
- connectivity_plus – detección de conectividad
- permission_handler_android – permisos
- url_launcher_android – URLs externas

## Roles de usuario
- **Crew (tripulante):** acceso a su perfil y documentos
- **Manager / Capitán:** acceso completo a gestión de tripulación

## Funcionalidades implementadas o en desarrollo
- Login con PIN y biometría
- Cambio forzado de PIN en primer acceso
- Gestión de tripulantes (perfil, documentos, certificados)
- Escaneo de documentos con cámara
- Asistente de voz HEY YAT (Claude API + TTS + speech-to-text)
- Soporte multiidioma: inglés, español, francés, ruso, chino
- Detección de conectividad

## Convenciones de código
- Nombrado en inglés (código, variables, funciones)
- Comentarios en español preferiblemente
- No modificar tablas de Supabase sin crear una migración en supabase/migrations/
- Toda integración con Claude API debe pasar por /services/ai_service.dart
- Las claves de API van en api_config.dart (ignorado en git, nunca hardcodeadas)

## Comandos habituales
flutter run                  # lanzar en emulador
flutter build apk            # build Android
flutter test                 # tests
supabase db push             # aplicar migraciones

## Restricciones importantes
- No hardcodear API keys. Usar api_config.dart (ver api_config.example.dart como plantilla).
- No modificar Supabase directamente en producción; siempre mediante migraciones.
- HEY YAT no debe almacenar transcripciones de voz en claro.
- api_config.dart está en .gitignore; nunca subirlo al repositorio.

## Contexto de negocio relevante
- El desarrollador principal no tiene background técnico previo.
  Priorizar siempre explicaciones claras y soluciones simples.
- Fase actual: MVP en desarrollo.
- Modelo de negocio: pendiente de definir (hardware + software, turnkey).
- Mercado objetivo: superyates (24m+), hubs en Palma, Antibes, Fort Lauderdale.

## Documentación interna relevante
- guia_supabase_auth_flutter.md – autenticación Supabase
- SmartCrew_Multiidioma_v2.4_para_Claude_Code.md – contexto multiidioma
- smartyat_claude_code_prompt.md – prompt de referencia para Claude Code