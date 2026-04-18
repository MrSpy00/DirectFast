import 'package:intl/date_symbol_data_local.dart';
import 'package:intl/intl.dart';

final Set<String> _initializedLocales = <String>{};
final Set<String> _unavailableLocales = <String>{};

String _normalizeLocale(String locale) {
  final trimmed = locale.trim();
  if (trimmed.isEmpty) {
    return 'en';
  }

  final underscored = trimmed.replaceAll('-', '_');
  return Intl.canonicalizedLocale(underscored);
}

List<String> _localeCandidates(String locale) {
  final canonical = _normalizeLocale(locale);
  final candidates = <String>{canonical};

  final separatorIndex = canonical.indexOf('_');
  if (separatorIndex > 0) {
    candidates.add(canonical.substring(0, separatorIndex));
  }

  candidates.add('en_US');
  candidates.add('en');

  return candidates.toList(growable: false);
}

String _fallbackTime(DateTime value) {
  final hour = value.hour.toString().padLeft(2, '0');
  final minute = value.minute.toString().padLeft(2, '0');
  return '$hour:$minute';
}

String _fallbackDate(DateTime value) {
  final day = value.day.toString().padLeft(2, '0');
  final month = value.month.toString().padLeft(2, '0');
  final year = value.year.toString();
  return '$day.$month.$year';
}

Future<void> ensureDateFormattingInitialized(String locale) async {
  for (final candidate in _localeCandidates(locale)) {
    if (_unavailableLocales.contains(candidate)) {
      continue;
    }

    if (_initializedLocales.contains(candidate)) {
      Intl.defaultLocale = candidate;
      return;
    }

    try {
      await initializeDateFormatting(candidate);
      _initializedLocales.add(candidate);
      _unavailableLocales.remove(candidate);
      Intl.defaultLocale = candidate;
      return;
    } catch (_) {
      _unavailableLocales.add(candidate);
      // Try the next locale candidate.
    }
  }

  Intl.defaultLocale = 'en';
}

Future<void> primeDateFormattingLocales(Iterable<String> locales) async {
  for (final locale in locales) {
    await ensureDateFormattingInitialized(locale);
  }
}

bool _isLocaleReadyForFormatting(String locale) {
  return _initializedLocales.contains(locale);
}

String formatTimeHm(DateTime value, String locale) {
  if (_initializedLocales.isEmpty) {
    return _fallbackTime(value);
  }

  for (final candidate in _localeCandidates(locale)) {
    if (!_isLocaleReadyForFormatting(candidate) ||
        _unavailableLocales.contains(candidate)) {
      continue;
    }

    try {
      return DateFormat.Hm(candidate).format(value);
    } catch (_) {
      _unavailableLocales.add(candidate);
      // Try the next locale candidate.
    }
  }

  return _fallbackTime(value);
}

String formatDateYMd(DateTime value, String locale) {
  if (_initializedLocales.isEmpty) {
    return _fallbackDate(value);
  }

  for (final candidate in _localeCandidates(locale)) {
    if (!_isLocaleReadyForFormatting(candidate) ||
        _unavailableLocales.contains(candidate)) {
      continue;
    }

    try {
      return DateFormat.yMd(candidate).format(value);
    } catch (_) {
      _unavailableLocales.add(candidate);
      // Try the next locale candidate.
    }
  }

  return _fallbackDate(value);
}
