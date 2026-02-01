import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'app.dart';
import 'services/config_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  final configService = ConfigService();
  await configService.init();

  runApp(
    Provider<ConfigService>.value(
      value: configService,
      child: const AlishaApp(),
    ),
  );
}
