import 'package:flutter/material.dart';
import '../config/menu_item.dart';
import '../utils/constants.dart';

class AppConfig {
  final String appName;
  final String developerName;
  final String developerWebsite;
  final String baseWebUrl;
  final String apiBaseUrl;
  final Color primaryColor;
  final Color secondaryColor;
  final bool darkModeEnabled;
  final bool firebaseEnabled;
  final bool pushNotificationsEnabled;
  final bool maintenanceMode;
  final bool adsEnabled;
  final String forceUpdateVersion;
  final String environment;
  final List<MenuItem> drawerMenu;
  final bool drawerMenuEnabled;
  final List<MenuItem> footerMenu;
  final bool footerMenuEnabled;

  AppConfig({
    required this.appName,
    required this.developerName,
    required this.developerWebsite,
    required this.baseWebUrl,
    required this.apiBaseUrl,
    required this.primaryColor,
    required this.secondaryColor,
    required this.darkModeEnabled,
    required this.firebaseEnabled,
    required this.pushNotificationsEnabled,
    required this.maintenanceMode,
    required this.adsEnabled,
    required this.forceUpdateVersion,
    required this.environment,
    required this.drawerMenu,
    required this.drawerMenuEnabled,
    required this.footerMenu,
    required this.footerMenuEnabled,
  });

  factory AppConfig.defaults() {
    const envBaseWebUrl = String.fromEnvironment(
      'ALISHA_BASE_WEB_URL',
      defaultValue: 'https://wpx.bevq.in',
    );
    const envApiBaseUrl = String.fromEnvironment(
      'ALISHA_API_BASE_URL',
      defaultValue: '',
    );
    final normalizedBaseWebUrl = _normalizeUrl(envBaseWebUrl, fallback: 'https://wpx.bevq.in');
    final normalizedApiBaseUrl = _defaultApiBaseUrl(normalizedBaseWebUrl, envApiBaseUrl);

    return AppConfig(
      appName: AppConstants.appName,
      developerName: 'KloudBoy',
      developerWebsite: 'https://kloudboy.com',
      baseWebUrl: normalizedBaseWebUrl,
      apiBaseUrl: normalizedApiBaseUrl,
      primaryColor: const Color(0xFF6200EE),
      secondaryColor: const Color(0xFF03DAC6),
      darkModeEnabled: true,
      firebaseEnabled: false,
      pushNotificationsEnabled: false,
      maintenanceMode: false,
      adsEnabled: false,
      forceUpdateVersion: '1.0.0',
      environment: 'prod',
      drawerMenu: [],
      drawerMenuEnabled: true,
      footerMenu: [],
      footerMenuEnabled: true,
    );
  }

  factory AppConfig.fromJson(Map<String, dynamic> json) {
    var drawerList = <MenuItem>[];
    if (json['menus'] != null && json['menus']['drawer'] != null) {
      if (json['menus']['drawer'] is List) {
        drawerList = (json['menus']['drawer'] as List)
            .map((i) => MenuItem.fromJson(i))
            .toList();
      }
    }

    var footerList = <MenuItem>[];
    if (json['menus'] != null && json['menus']['footer'] != null) {
      if (json['menus']['footer'] is List) {
        footerList = (json['menus']['footer'] as List)
            .map((i) => MenuItem.fromJson(i))
            .toList();
      }
    }

    return AppConfig(
      appName: json['app_name'] ?? 'Alisha',
      developerName: json['developer_name'] ?? 'KloudBoy',
      developerWebsite: json['developer_website'] ?? '',
      baseWebUrl: json['base_web_url'] ?? '',
      apiBaseUrl: json['api_base_url'] ?? '',
      primaryColor: _parseColor(json['styling']?['primary_color']),
      secondaryColor: _parseColor(json['styling']?['secondary_color']),
      darkModeEnabled: json['styling']?['dark_mode_enabled'] ?? true,
      firebaseEnabled: json['features']?['firebase_enabled'] ?? false,
      pushNotificationsEnabled: json['features']?['push_notifications_enabled'] ?? false,
      maintenanceMode: json['features']?['maintenance_mode'] ?? false,
      adsEnabled: json['features']?['ads_enabled'] ?? false,
      forceUpdateVersion: json['updates']?['force_update_version'] ?? '1.0.0',
      environment: json['environment'] ?? 'prod',
      drawerMenu: drawerList,
      drawerMenuEnabled: json['menus']?['drawer_enabled'] ?? true,
      footerMenu: footerList,
      footerMenuEnabled: json['menus']?['footer_enabled'] ?? true,
    );
  }
  
  static Color _parseColor(String? hexString) {
    if (hexString == null || hexString.isEmpty) return const Color(0xFF6200EE);
    try {
      final buffer = StringBuffer();
      if (hexString.length == 6 || hexString.length == 7) buffer.write('ff');
      buffer.write(hexString.replaceFirst('#', ''));
      return Color(int.parse(buffer.toString(), radix: 16));
    } catch (e) {
      return const Color(0xFF6200EE);
    }
  }

  static String _normalizeUrl(String value, {String fallback = ''}) {
    final trimmed = value.trim();
    if (trimmed.isEmpty) return fallback;
    return trimmed.replaceFirst(RegExp(r'/+$'), '');
  }

  static String _defaultApiBaseUrl(String baseWebUrl, String explicitApiBaseUrl) {
    final normalizedExplicit = _normalizeUrl(explicitApiBaseUrl);
    if (normalizedExplicit.isNotEmpty) return normalizedExplicit;

    final normalizedBase = _normalizeUrl(baseWebUrl);
    if (normalizedBase.isEmpty) return '';
    if (normalizedBase.endsWith('/wp-json/alisha/v1')) return normalizedBase;
    if (normalizedBase.endsWith('/wp-json')) return '$normalizedBase/alisha/v1';
    return '$normalizedBase/wp-json/alisha/v1';
  }
}
