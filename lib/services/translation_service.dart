import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../config/api_config.dart';

class TranslationService {
  static const String _cachePrefix = 'translation_';

  Future<String?> translate(String text, String targetLanguage) async {
    if (targetLanguage == 'en') return text;
    if (text.trim().isEmpty) return text;

    final cacheKey = '$_cachePrefix${targetLanguage}_${text.hashCode}';
    final prefs = await SharedPreferences.getInstance();
    final cached = prefs.getString(cacheKey);
    if (cached != null) return cached;

    if (ApiConfig.anthropicApiKey == 'YOUR_API_KEY_HERE') return null;

    try {
      final response = await http.post(
        Uri.parse(ApiConfig.anthropicBaseUrl),
        headers: {
          'Content-Type': 'application/json',
          'x-api-key': ApiConfig.anthropicApiKey,
          'anthropic-version': '2023-06-01',
        },
        body: jsonEncode({
          'model': ApiConfig.claudeModel,
          'max_tokens': 256,
          'system': 'You are a translator. Translate the given text to the target language. Respond with ONLY the translated text, no explanations.',
          'messages': [
            {
              'role': 'user',
              'content': 'Translate to $targetLanguage: $text'
            }
          ],
        }),
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        final translated = data['content'][0]['text'] as String;
        await prefs.setString(cacheKey, translated.trim());
        return translated.trim();
      }
    } catch (_) {
      // fall through
    }
    return null;
  }
}
