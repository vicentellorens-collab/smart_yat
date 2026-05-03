import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../config/theme.dart';
import '../../providers/app_provider.dart';
import '../../services/language_service.dart';

class LanguageScreen extends StatelessWidget {
  const LanguageScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final languageService = context.watch<LanguageService>();
    final currentCode = languageService.currentLanguageCode;
    final userId = context.read<AppProvider>().currentUser?.id ?? '';

    return Scaffold(
      appBar: AppBar(
        title: const Text('Language / Idioma'),
      ),
      body: ListView(
        children: LanguageService.supportedLanguages.map((lang) {
          final isSelected = lang['code'] == currentCode;
          return ListTile(
            leading: Text(
              lang['flag']!,
              style: const TextStyle(fontSize: 24),
            ),
            title: Text(
              lang['name']!,
              style: AppTheme.label(
                color: isSelected ? AppTheme.accent : AppTheme.textPrimary,
                weight: isSelected ? FontWeight.w700 : FontWeight.w400,
              ),
            ),
            trailing: isSelected
                ? const Icon(Icons.check_circle, color: AppTheme.accent)
                : null,
            onTap: () {
              if (!isSelected) {
                languageService.setLanguage(userId, lang['code']!);
              }
              Navigator.pop(context);
            },
          );
        }).toList(),
      ),
    );
  }
}
