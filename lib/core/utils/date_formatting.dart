import 'package:intl/date_symbol_data_local.dart';

final Set<String> _initializedLocales = <String>{};

Future<void> ensureDateFormattingInitialized(String locale) async {
  final normalizedLocale = locale.trim().isEmpty ? 'en' : locale.trim();

  if (_initializedLocales.contains(normalizedLocale)) {
    return;
  }

  try {
    await initializeDateFormatting(normalizedLocale);
    _initializedLocales.add(normalizedLocale);
    return;
  } catch (_) {
    if (_initializedLocales.contains('en')) {
      return;
    }
  }

  try {
    await initializeDateFormatting('en');
    _initializedLocales.add('en');
  } catch (_) {
    // Keep app behavior stable even if locale data cannot be loaded.
  }
}
