import 'dart:convert';

class AuthService {
  static String hashPin(String pin) {
    final input = pin + 'smartcrew_salt_2024';
    final bytes = utf8.encode(input);
    return base64.encode(bytes);
  }

  static bool verifyPin(String pin, String hash) {
    return hashPin(pin) == hash;
  }
}
