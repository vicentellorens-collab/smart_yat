# SmartCrew — Guía de Implementación: Supabase Auth

## Objetivo

Integrar Supabase Auth por debajo del sistema de PIN actual.
El usuario NO nota ningún cambio. El PIN sigue siendo la única
interfaz visible. Supabase Auth funciona internamente para que
las políticas RLS de aislamiento por yate sean efectivas.

## Contexto técnico actual

- La app usa `supabase_flutter` para conectarse con anon key
- Login actual: el usuario introduce un PIN de 4 dígitos
- La app busca en la tabla `users` un registro cuyo `pin_hash` coincida
- No hay cuentas de Supabase Auth; todo es anon
- Proyecto Supabase: egetcuorhgmpygxcpfjk
- URL: https://egetcuorhgmpygxcpfjk.supabase.co

## Arquitectura objetivo

```
USUARIO          APP FLUTTER              SUPABASE
  |                  |                       |
  |-- PIN 1234 -->   |                       |
  |                  |-- signIn(email, pwd)-->|  (Supabase Auth)
  |                  |<-- session token ------|
  |                  |-- query con token ---->|  (RLS filtra por yacht_id)
  |                  |<-- datos del yate -----|
```

## Flujo detallado

### 1. Registro del Administrador (primera vez)

Cuando el admin crea su cuenta por primera vez:

```dart
// 1. Crear cuenta en Supabase Auth
final authResponse = await supabase.auth.signUp(
  email: adminEmail,  // email real del admin
  password: _generateSecurePassword(),  // contraseña aleatoria
);

// 2. Guardar la contraseña cifrada en almacenamiento local seguro
// Usar flutter_secure_storage (NO SharedPreferences)
await secureStorage.write(
  key: 'auth_password_${adminEmail}', 
  value: generatedPassword,
);

// 3. Crear registro en tabla users con el auth.uid()
await supabase.from('users').insert({
  'id': authResponse.user!.id,  // USAR el UUID de Supabase Auth
  'name': adminName,
  'email': adminEmail,
  'pin_hash': hashPin(pin),
  'is_admin': true,
  'yacht_id': yachtId,
  'role': 'gestor',
});
```

### 2. Login del Administrador

```dart
// 1. Buscar usuario por email (esto funciona con anon porque
//    la política RLS permite SELECT anon en users)
final userData = await supabase
  .from('users')
  .select()
  .eq('email', email)
  .single();

// 2. Validar PIN localmente
if (hashPin(inputPin) != userData['pin_hash']) {
  throw Exception('PIN incorrecto');
}

// 3. Recuperar contraseña de auth del almacenamiento seguro
final authPassword = await secureStorage.read(
  key: 'auth_password_${email}',
);

// 4. Si hay contraseña local, hacer signIn con Supabase Auth
if (authPassword != null) {
  await supabase.auth.signInWithPassword(
    email: email,
    password: authPassword,
  );
} else {
  // Nuevo dispositivo: necesita flujo de recuperación
  // Ver sección "Cambio de dispositivo"
}
```

### 3. Creación de Tripulante

```dart
// 1. Generar email interno para el tripulante
final internalEmail = 'crew-${Uuid().v4()}@smartcrew.internal';
final internalPassword = _generateSecurePassword();

// 2. Crear cuenta en Supabase Auth
// IMPORTANTE: usar supabase.auth.admin si es posible,
// o crear una Edge Function para esto
final authResponse = await supabase.auth.signUp(
  email: internalEmail,
  password: internalPassword,
);

// 3. Guardar en tabla users
await supabase.from('users').insert({
  'id': authResponse.user!.id,
  'name': '${nombre} ${apellidos}',
  'email': internalEmail,
  'pin_hash': hashPin('0000'),  // PIN temporal
  'is_admin': false,
  'yacht_id': currentYachtId,
  'role': 'tripulante',
  'must_change_pin': true,
});

// 4. Guardar credenciales del tripulante en almacenamiento seguro
// Para que el admin pueda facilitar el login en el dispositivo del tripulante
await secureStorage.write(
  key: 'auth_credentials_${authResponse.user!.id}',
  value: jsonEncode({'email': internalEmail, 'password': internalPassword}),
);
```

### 4. Login del Tripulante

```dart
// 1. El tripulante introduce su PIN en la PDA
// 2. Buscar en users por yacht_id + pin_hash
final users = await supabase
  .from('users')
  .select()
  .eq('yacht_id', currentYachtId)
  .eq('pin_hash', hashPin(inputPin));

// 3. Recuperar credenciales auth del almacenamiento seguro
final creds = await secureStorage.read(
  key: 'auth_credentials_${user['id']}',
);

// 4. SignIn con Supabase Auth
final credsMap = jsonDecode(creds);
await supabase.auth.signInWithPassword(
  email: credsMap['email'],
  password: credsMap['password'],
);
```

### 5. Cambio de dispositivo (admin)

El admin instala la app en un dispositivo nuevo. No tiene la
contraseña de auth en el almacenamiento local del nuevo dispositivo.

Opción A — Reset de contraseña por email:
```dart
// 1. El admin introduce su email
// 2. Enviar email de reset
await supabase.auth.resetPasswordForEmail(adminEmail);
// 3. El admin recibe el link, establece nueva contraseña
// 4. La app guarda la nueva contraseña en secure storage
```

Opción B — Edge Function de recuperación:
```dart
// 1. El admin introduce email + PIN
// 2. La app llama a una Edge Function que:
//    - Valida email + PIN contra la tabla users
//    - Si es correcto, genera nueva contraseña para Supabase Auth
//    - Devuelve la nueva contraseña cifrada
// 3. La app hace signIn con la nueva contraseña
```

### 6. Cambio de dispositivo (tripulante)

El tripulante recibe una PDA nueva. El admin configura el
dispositivo:

```dart
// 1. El admin hace login en el nuevo dispositivo
// 2. Va a Tripulación > selecciona tripulante
// 3. Opción "Configurar en este dispositivo"
// 4. Genera nuevas credenciales auth para el tripulante
// 5. Las guarda en el secure storage del nuevo dispositivo
// 6. El tripulante ya puede hacer login con su PIN
```

## Archivos a modificar

### Dependencias (pubspec.yaml)
```yaml
dependencies:
  supabase_flutter: ^2.x.x  # ya existente
  flutter_secure_storage: ^9.0.0  # AÑADIR
  uuid: ^4.0.0  # probablemente ya existente
```

### Archivos clave a modificar
1. `lib/services/auth_service.dart` — Añadir lógica de Supabase Auth
2. `lib/services/supabase_service.dart` — Actualizar para usar sesión auth
3. `lib/screens/login_screen.dart` — Integrar signIn después de validar PIN
4. `lib/screens/register_screen.dart` — Integrar signUp al registrar admin
5. `lib/screens/crew/add_crew_screen.dart` — Crear cuenta auth al añadir tripulante

### Nuevo archivo recomendado
`lib/services/secure_auth_storage.dart` — Wrapper de flutter_secure_storage
para gestionar credenciales de Supabase Auth.

## Consideraciones importantes

1. **Orden de operaciones**: 
   - Primero: implementar Supabase Auth en Flutter
   - Segundo: probar que login/registro funciona con auth
   - Tercero: aplicar la migración RLS en Supabase
   - Si se aplica RLS antes de actualizar Flutter, la app se rompe

2. **Generación de contraseñas**: 
   Usar contraseñas aleatorias fuertes (mínimo 32 caracteres).
   El usuario NUNCA ve ni introduce esta contraseña.

3. **flutter_secure_storage**: 
   Almacena en Android Keystore (cifrado por hardware).
   Es diferente de SharedPreferences (texto plano).

4. **Sesión de Supabase Auth**:
   supabase_flutter gestiona automáticamente el refresh del token.
   Una vez hecho signIn, la sesión persiste entre reinicios de la app.

5. **Migración de datos existentes**:
   Si ya hay usuarios en la tabla `users` sin cuenta auth,
   hay que crear una migración que genere cuentas auth para ellos.
   Esto se puede hacer con una Edge Function batch.

6. **IDs de usuario**:
   Actualmente users.id se genera con gen_random_uuid() en Supabase.
   Con Supabase Auth, users.id DEBE ser el UUID del auth.user.
   Esto es fundamental para que auth.uid() funcione en las políticas RLS.

## Test de verificación

Después de implementar, verificar:

1. Registrar admin → se crea cuenta auth + registro en users
2. Login admin con PIN → se hace signIn auth internamente
3. Crear tripulante → se crea cuenta auth + registro en users
4. Login tripulante con PIN → se hace signIn auth internamente
5. Verificar que `supabase.auth.currentUser` no es null tras login
6. Verificar que las queries a tablas funcionan con el token auth
7. Cerrar app y reabrirla → la sesión persiste
8. Aplicar migración RLS → verificar que todo sigue funcionando
