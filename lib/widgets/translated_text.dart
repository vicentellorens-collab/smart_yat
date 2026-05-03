import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/language_service.dart';
import '../services/translation_service.dart';

/// Displays [canonical] (English source) translated to the user's current language.
/// Falls back to [canonical] if translation is unavailable.
class TranslatedText extends StatefulWidget {
  final String canonical;
  final TextStyle? style;
  final int? maxLines;
  final TextOverflow? overflow;

  const TranslatedText(
    this.canonical, {
    super.key,
    this.style,
    this.maxLines,
    this.overflow,
  });

  @override
  State<TranslatedText> createState() => _TranslatedTextState();
}

class _TranslatedTextState extends State<TranslatedText> {
  final _service = TranslationService();
  String? _translated;
  String? _lastLocale;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final locale = context.read<LanguageService>().currentLanguageCode;
    if (locale != _lastLocale) {
      _lastLocale = locale;
      _load(locale);
    }
  }

  Future<void> _load(String locale) async {
    if (locale == 'en') {
      setState(() => _translated = widget.canonical);
      return;
    }
    final result = await _service.translate(widget.canonical, locale);
    if (mounted) setState(() => _translated = result ?? widget.canonical);
  }

  @override
  Widget build(BuildContext context) {
    return Text(
      _translated ?? widget.canonical,
      style: widget.style,
      maxLines: widget.maxLines,
      overflow: widget.overflow,
    );
  }
}
