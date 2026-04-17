import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../utils/date_formatting.dart';
import '../../shared/constants/app_strings.dart';

// Provider for locale
final localeProvider = StateNotifierProvider<LocaleNotifier, String>((ref) {
  return LocaleNotifier();
});

class LocaleNotifier extends StateNotifier<String> {
  LocaleNotifier() : super(AppStrings.turkish) {
    _loadLocale();
  }

  static const String _localeKey = 'app_locale';

  Future<void> _loadLocale() async {
    final prefs = await SharedPreferences.getInstance();
    final savedLocale = AppStrings.normalizeLocale(
      prefs.getString(_localeKey) ?? AppStrings.turkish,
    );

    await ensureDateFormattingInitialized(savedLocale);

    state = savedLocale;
    AppStrings.setLocale(savedLocale);
  }

  Future<void> setLocale(String locale) async {
    final normalized = AppStrings.normalizeLocale(locale);

    await ensureDateFormattingInitialized(normalized);

    state = normalized;
    AppStrings.setLocale(normalized);

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_localeKey, normalized);
  }

  String get currentLocale => state;

  bool get isTurkish => state == AppStrings.turkish;
  bool get isEnglish => state == AppStrings.english;
  bool get isSpanish => state == AppStrings.spanish;
  bool get isArabic => state == AppStrings.arabic;
  bool get isHindi => state == AppStrings.hindi;
}
