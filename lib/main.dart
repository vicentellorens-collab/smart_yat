import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'config/api_config.dart';
import 'config/theme.dart';
import 'providers/app_provider.dart';
import 'services/connectivity_service.dart';
import 'services/language_service.dart';
import 'services/tts_service.dart';
import 'screens/login_screen.dart';
import 'package:smart_yat/l10n/app_localizations.dart';

final TtsService ttsService = TtsService();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
    url: ApiConfig.supabaseUrl,
    anonKey: ApiConfig.supabaseAnonKey,
  );

  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: Brightness.light,
  ));

  final connectivityService = ConnectivityService();
  connectivityService.init();

  await ttsService.init();

  final appProvider = AppProvider();
  appProvider.setConnectivityService(connectivityService);
  await appProvider.initialize();

  final languageService = LanguageService();
  await languageService.loadDeviceLanguage();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: appProvider),
        ChangeNotifierProvider.value(value: connectivityService),
        ChangeNotifierProvider.value(value: languageService),
      ],
      child: const SmartYatApp(),
    ),
  );
}

class SmartYatApp extends StatelessWidget {
  const SmartYatApp({super.key});

  @override
  Widget build(BuildContext context) {
    final languageService = context.watch<LanguageService>();
    return MaterialApp(
      title: 'SmartYat',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.darkTheme,
      locale: languageService.currentLocale,
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('en'),
        Locale('es'),
        Locale('fr'),
        Locale('ru'),
        Locale('zh'),
      ],
      home: const LoginScreen(),
    );
  }
}
