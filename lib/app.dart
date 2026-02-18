import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'services/config_service.dart';
import 'config/theme_app.dart';
import 'screens/maintenance_screen.dart';
import 'screens/splash_screen.dart';

class AlishaApp extends StatelessWidget {
  const AlishaApp({super.key});

  @override
  Widget build(BuildContext context) {
    final config = context.read<ConfigService>().config;

    if (config.maintenanceMode) {
      return const MaterialApp(home: MaintenanceScreen());
    }

    return MaterialApp(
      title: config.appName,
      theme: AppTheme.lightTheme(config.primaryColor, config.secondaryColor),
      darkTheme: AppTheme.darkTheme(config.primaryColor, config.secondaryColor),
      themeMode: config.darkModeEnabled ? ThemeMode.system : ThemeMode.light,
      debugShowCheckedModeBanner: false,
      home: const SplashScreen(),
    );
  }
}
