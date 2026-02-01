import 'package:flutter/material.dart';

class OnboardingConfig {
  final bool enabled;
  final String version;
  final String style; // 'fullscreen', 'card', 'minimal'
  final OnboardingSettings settings;
  final List<OnboardingStep> steps;

  OnboardingConfig({
    required this.enabled,
    required this.version,
    required this.style,
    required this.settings,
    required this.steps,
  });

  factory OnboardingConfig.defaults() {
    return OnboardingConfig(
      enabled: false,
      version: '1.0',
      style: 'fullscreen',
      settings: OnboardingSettings.defaults(),
      steps: [],
    );
  }

  factory OnboardingConfig.fromJson(Map<String, dynamic> json) {
    return OnboardingConfig(
      enabled: json['enabled'] ?? false,
      version: json['version'] ?? '1.0',
      style: json['style'] ?? 'fullscreen',
      settings: OnboardingSettings.fromJson(json['settings'] ?? {}),
      steps: (json['steps'] as List?)
              ?.map((e) => OnboardingStep.fromJson(e))
              .toList() ??
          [],
    );
  }
}

class OnboardingSettings {
  final Color primaryColor;
  final Color textColor;
  final double overlayOpacity;
  final bool showSkip;

  OnboardingSettings({
    required this.primaryColor,
    required this.textColor,
    required this.overlayOpacity,
    required this.showSkip,
  });

  factory OnboardingSettings.defaults() {
    return OnboardingSettings(
      primaryColor: const Color(0xFF6200EE),
      textColor: Colors.white,
      overlayOpacity: 0.5,
      showSkip: true,
    );
  }

  factory OnboardingSettings.fromJson(Map<String, dynamic> json) {
    return OnboardingSettings(
      primaryColor: _parseColor(json['primaryColor']),
      textColor: _parseColor(json['textColor'], defaultColor: Colors.white),
      overlayOpacity: (json['overlayOpacity'] as num?)?.toDouble() ?? 0.5,
      showSkip: json['showSkip'] ?? true,
    );
  }

  static Color _parseColor(String? hexString, {Color defaultColor = const Color(0xFF6200EE)}) {
    if (hexString == null || hexString.isEmpty) return defaultColor;
    try {
      final buffer = StringBuffer();
      if (hexString.length == 6 || hexString.length == 7) buffer.write('ff');
      buffer.write(hexString.replaceFirst('#', ''));
      return Color(int.parse(buffer.toString(), radix: 16));
    } catch (e) {
      return defaultColor;
    }
  }
}

class OnboardingStep {
  final String id;
  final String title;
  final String description;
  final String imageUrl;
  final String buttonText;

  OnboardingStep({
    required this.id,
    required this.title,
    required this.description,
    required this.imageUrl,
    required this.buttonText,
  });

  factory OnboardingStep.fromJson(Map<String, dynamic> json) {
    return OnboardingStep(
      id: json['id'] ?? '',
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      imageUrl: json['imageUrl'] ?? '',
      buttonText: json['buttonText'] ?? 'Next',
    );
  }
}
