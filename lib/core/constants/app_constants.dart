/// Application-wide constants
class AppConstants {
  AppConstants._();

  // App Info
  static const String appName = 'DirectFast';
  static const String developerName = 'aegis';
  static const String githubUrl = 'https://github.com/MrSpy00';
  static const String coffeeUrl = 'https://buymeacoffee.com/aegissoft';
  static const String appVersion = '1.0.2';

  // Regex Patterns
  static final RegExp phoneNumberRegex = RegExp(r'^\+?[1-9]\d{1,14}$');
  static final RegExp telegramUsernameRegex = RegExp(r'^[a-zA-Z0-9_]{5,32}$');
  static final RegExp genericUsernameRegex = RegExp(r'^[a-zA-Z0-9_.-]{2,50}$');
  static final RegExp viberUsernameRegex = RegExp(r'^[a-zA-Z0-9_]{3,}$');
  static final RegExp emailRegex = RegExp(
    r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
  );

  // URL Templates
  static const String whatsappUrlTemplate = 'https://wa.me/';
  static const String telegramUrlTemplate = 'https://t.me/';
  static const String viberUrlTemplate = 'viber://chat?number=';
  static const String signalUrlTemplate = 'sgnl://signal.me/#p/';

  // Storage Keys
  static const String historyBoxName = 'chat_history';
  static const String settingsBoxName = 'app_settings';
  static const String themeKey = 'theme_mode';
  static const String themeColorKey = 'theme_color_id';
  static const String localeKey = 'app_locale';

  // Animation Durations
  static const Duration shortAnimation = Duration(milliseconds: 200);
  static const Duration mediumAnimation = Duration(milliseconds: 300);
  static const Duration longAnimation = Duration(milliseconds: 500);
}
