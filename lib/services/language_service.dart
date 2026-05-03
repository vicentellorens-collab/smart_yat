import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LanguageService extends ChangeNotifier {
  static const String _keyPrefix = 'user_language_';
  static const String _defaultLocale = 'en';

  static const List<Map<String, String>> supportedLanguages = [
    {'code': 'en', 'name': 'English',  'flag': '🇬🇧'},
    {'code': 'es', 'name': 'Español',  'flag': '🇪🇸'},
    {'code': 'fr', 'name': 'Français', 'flag': '🇫🇷'},
    {'code': 'ru', 'name': 'Русский',  'flag': '🇷🇺'},
    {'code': 'zh', 'name': '中文',     'flag': '🇨🇳'},
  ];

  Locale _currentLocale = const Locale('en');

  Locale get currentLocale => _currentLocale;
  String get currentLanguageCode => _currentLocale.languageCode;

  /// BCP-47 locale for speech_to_text
  String get speechLocale {
    switch (_currentLocale.languageCode) {
      case 'es': return 'es-ES';
      case 'fr': return 'fr-FR';
      case 'ru': return 'ru-RU';
      case 'zh': return 'zh-CN';
      default:   return 'en-US';
    }
  }

  /// Flag + name for the current language
  Map<String, String> get currentLanguage => supportedLanguages.firstWhere(
        (l) => l['code'] == currentLanguageCode,
        orElse: () => supportedLanguages.first,
      );

  Future<void> loadLanguageForUser(String userId) async {
    final prefs = await SharedPreferences.getInstance();
    final savedCode = prefs.getString('$_keyPrefix$userId') ?? _defaultLocale;
    _currentLocale = Locale(savedCode);
    notifyListeners();
  }

  Future<void> setLanguage(String userId, String languageCode) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('$_keyPrefix$userId', languageCode);
    _currentLocale = Locale(languageCode);
    notifyListeners();
  }

  void resetToDefault() {
    _currentLocale = const Locale(_defaultLocale);
    notifyListeners();
  }
}
