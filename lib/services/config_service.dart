import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../config/app_config.dart';
import 'firebase_service.dart';

class ConfigService {
  AppConfig _config = AppConfig.defaults();
  
  AppConfig get config => _config;

  Future<void> init() async {
    // 1. Load from Local Assets (Fallback)
    await _loadLocalConfig();

    // 2. Load from Firebase Remote Config (if enabled)
    // We do this after initial basic config to see if firebase is theoretically enabled/setup
    
    // 3. Load from WordPress API
    try {
      final apiConfig = await _fetchFromApi();
      if (apiConfig != null) {
        _config = apiConfig;
      }
    } catch (e) {
      if (kDebugMode) print('Error fetching API config: $e');
    }
  }

  Future<void> _loadLocalConfig() async {
    try {
      final String response = await rootBundle.loadString('assets/config/app_config.json');
      final data = await json.decode(response);
      _config = AppConfig.fromJson(data);
    } catch (e) {
      if (kDebugMode) print('Local config not found or invalid, using defaults.');
    }
  }

  Future<AppConfig?> _fetchFromApi() async {
    // If apiBaseUrl is empty, we can't fetch.
    if (_config.apiBaseUrl.isEmpty) {
       return null;
    }

    try {
        final uri = Uri.parse('${_config.apiBaseUrl}/app-config?app_id=com.kloudboy.alisha');
        final response = await http.get(uri);
        
        if (response.statusCode == 200) {
          return AppConfig.fromJson(json.decode(response.body));
        }
    } catch (e) {
       // fail silently or log in debug
       if (kDebugMode) print('Error fetching API config: $e');
    }
    return null;
  }
}
