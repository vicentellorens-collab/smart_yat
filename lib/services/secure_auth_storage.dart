import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Almacena credenciales de Supabase Auth en el Keystore del dispositivo.
/// El usuario nunca ve ni introduce estas credenciales.
class SecureAuthStorage {
  static const _storage = FlutterSecureStorage(
    aOptions: AndroidOptions(encryptedSharedPreferences: true),
  );

  static Future<void> saveCredentials(
      String userId, String email, String password) async {
    await _storage.write(
      key: 'auth_creds_$userId',
      value: jsonEncode({'email': email, 'password': password}),
    );
  }

  static Future<Map<String, String>?> readCredentials(String userId) async {
    final raw = await _storage.read(key: 'auth_creds_$userId');
    if (raw == null) return null;
    final map = jsonDecode(raw) as Map<String, dynamic>;
    return {
      'email': map['email'] as String,
      'password': map['password'] as String,
    };
  }

  static Future<void> deleteCredentials(String userId) async {
    await _storage.delete(key: 'auth_creds_$userId');
  }
}
