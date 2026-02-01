import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/onboarding_config.dart';

class OnboardingService {
  static final OnboardingService _instance = OnboardingService._internal();
  factory OnboardingService() => _instance;
  OnboardingService._internal();

  OnboardingConfig _config = OnboardingConfig.defaults();
  OnboardingConfig get config => _config;

  static const String _storageKeyConfig = 'alisha_onboarding_config';
  static const String _storageKeySeenVersion = 'alisha_onboarding_seen_version';

  /// Initialize: Load cached config from disk
  Future<void> init() async {
    final prefs = await SharedPreferences.getInstance();
    final String? cachedString = prefs.getString(_storageKeyConfig);
    if (cachedString != null) {
      try {
        final Map<String, dynamic> jsonMap = json.decode(cachedString);
        _config = OnboardingConfig.fromJson(jsonMap);
      } catch (e) {
        if (kDebugMode) print('Error parsing cached onboarding config: $e');
      }
    }
  }

  /// Fetch from API and update cache
  Future<void> fetchConfig(String baseUrl) async {
    try {
      // Clean URL logic
      String url = baseUrl;
      if (url.endsWith('/')) url = url.substring(0, url.length - 1);
      final uri = Uri.parse('$url/alisha/v1/onboarding');

      final response = await http.get(uri);
      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonMap = json.decode(response.body);
        _config = OnboardingConfig.fromJson(jsonMap);
        
        // Cache it
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString(_storageKeyConfig, response.body);
      } else {
        if (kDebugMode) print('Failed to fetch onboarding: ${response.statusCode}');
      }
    } catch (e) {
      if (kDebugMode) print('Error fetching onboarding config: $e');
    }
  }

  /// Check if we should show onboarding
  Future<bool> shouldShowOnboarding() async {
    if (!_config.enabled || _config.steps.isEmpty) return false;

    final prefs = await SharedPreferences.getInstance();
    final String? seenVersion = prefs.getString(_storageKeySeenVersion);

    // If version changed, show again. If never seen, show.
    return seenVersion != _config.version;
  }

  /// Mark current version as seen
  Future<void> markAsSeen() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_storageKeySeenVersion, _config.version);
  }
}
