import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'storage_service.dart';
import '../utils/date_formatting.dart';
import '../../shared/constants/app_strings.dart';

// Provider for locale
final localeProvider = NotifierProvider<LocaleNotifier, String>(
  LocaleNotifier.new,
);

class LocaleNotifier extends Notifier<String> {
  @override
  String build() {
    final initialLocale = _resolveInitialLocale();
    AppStrings.setLocale(initialLocale);
    return initialLocale;
  }

  Future<void> setLocale(String locale) async {
    final normalized = AppStrings.normalizeLocale(locale);
    if (normalized == state) {
      return;
    }

    await ensureDateFormattingInitialized(normalized);

    state = normalized;
    AppStrings.setLocale(normalized);
    await StorageService.setLocale(normalized);
  }

  String _resolveInitialLocale() {
    try {
      final fromStorage = StorageService.getLocale();
      return AppStrings.normalizeLocale(fromStorage);
    } catch (_) {
      // Keep startup robust in isolated tests where storage is not initialized.
      return AppStrings.normalizeLocale(AppStrings.currentLocale);
    }
  }

  String get currentLocale => state;

  bool get isTurkish => state == AppStrings.turkish;
  bool get isEnglish => state == AppStrings.english;
  bool get isSpanish => state == AppStrings.spanish;
  bool get isArabic => state == AppStrings.arabic;
  bool get isHindi => state == AppStrings.hindi;
}
