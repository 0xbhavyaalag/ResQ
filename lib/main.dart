import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'core/theme/app_theme.dart';
import 'core/constants/app_constants.dart';
import 'services/storage_service.dart';
import 'providers/settings_provider.dart';
import 'providers/app_state_provider.dart';
import 'providers/software_safety_provider.dart';
import 'providers/fraud_safety_provider.dart';
import 'screens/splash/splash_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize local persistence
  await StorageService().init();

  runApp(const ResqApp());
}

class ResqApp extends StatelessWidget {
  const ResqApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => SettingsProvider()),
        ChangeNotifierProvider(create: (_) => AppStateProvider()),
        ChangeNotifierProvider(create: (_) => SoftwareSafetyProvider()),
        ChangeNotifierProvider(create: (_) => FraudSafetyProvider()),
      ],
      child: Consumer<SettingsProvider>(
        builder: (context, settings, _) {
          return MaterialApp(
            title: AppConstants.appName,
            debugShowCheckedModeBanner: false,
            theme: AppTheme.lightTheme,
            home: const SplashScreen(),
            builder: (context, child) {
              // Apply presentation mode scaling if active
              if (settings.isPresentationMode) {
                return MediaQuery(
                  data: MediaQuery.of(context).copyWith(
                    textScaler: const TextScaler.linear(1.15),
                  ),
                  child: child!,
                );
              }
              return child!;
            },
          );
        },
      ),
    );
  }
}
