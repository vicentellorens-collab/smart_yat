import 'dart:convert';
import 'dart:math';

class AuthService {
  static String hashPin(String pin) {
    final input = pin + 'smartcrew_salt_2024';
    final bytes = utf8.encode(input);
    return base64.encode(bytes);
  }

  static bool verifyPin(String pin, String hash) {
    return hashPin(pin) == hash;
  }

  /// Genera una contraseña aleatoria fuerte de 32 caracteres.
  /// El usuario nunca ve ni introduce esta contraseña.
  static String generateSecurePassword() {
    const chars =
        'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789!@#\$%^&*';
    final rng = Random.secure();
    return List.generate(32, (_) => chars[rng.nextInt(chars.length)]).join();
  }
}
