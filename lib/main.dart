import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'config/api_config.dart';
import 'config/theme.dart';
import 'providers/app_provider.dart';
import 'services/connectivity_service.dart';
import 'services/tts_service.dart';
import 'screens/login_screen.dart';

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

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: appProvider),
        ChangeNotifierProvider.value(value: connectivityService),
      ],
      child: const SmartCrewApp(),
    ),
  );
}

class SmartCrewApp extends StatelessWidget {
  const SmartCrewApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SmartCrew',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.darkTheme,
      home: const LoginScreen(),
    );
  }
}
