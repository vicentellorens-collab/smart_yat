import 'package:flutter_tts/flutter_tts.dart';

class TtsService {
  final FlutterTts _tts = FlutterTts();
  bool _initialized = false;

  Future<void> init() async {
    try {
      await _tts.setLanguage('en-US');
      await _tts.setSpeechRate(0.9);
      await _tts.setVolume(1.0);
      _initialized = true;
    } catch (_) {}
  }

  Future<void> setLanguage(String bcp47Locale) async {
    try {
      await _tts.setLanguage(bcp47Locale);
    } catch (_) {}
  }

  Future<void> speak(String text) async {
    if (!_initialized) return;
    try {
      await _tts.stop();
      await _tts.speak(text);
    } catch (_) {}
  }

  Future<void> stop() async {
    try {
      await _tts.stop();
    } catch (_) {}
  }
}
