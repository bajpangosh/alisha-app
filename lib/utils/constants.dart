class AppConstants {
  static const String appName = String.fromEnvironment(
    'ALISHA_APP_NAME',
    defaultValue: 'Alisha',
  );
  // App package/bundle identifier used for branding/rename flows.
  static const String appId = String.fromEnvironment(
    'ALISHA_APP_ID',
    defaultValue: 'com.kloudboy.alisha',
  );
  // API auth identifier expected by the WordPress plugin endpoint validation.
  static const String apiAppId = String.fromEnvironment(
    'ALISHA_API_APP_ID',
    defaultValue: 'com.kloudboy.alisha',
  );
  static const String defaultConfigEndpoint = '/wp-json/alisha/v1/app-config';
  // Add other constants here
}
