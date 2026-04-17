import 'package:flutter/services.dart';
import '../constants/app_constants.dart';

class ClipboardService {
  static final RegExp _phoneCandidateRegex =
      RegExp(r'(?:(?:\+|00)?\d[\d\s().-]{5,}\d)');
  static final RegExp _mentionRegex = RegExp('@([a-zA-Z0-9_.-]{2,50})');
  static final RegExp _emailSearchRegex = RegExp(
    r'[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}',
  );

  /// Get clipboard content
  static Future<String?> getClipboardContent() async {
    try {
      final data = await Clipboard.getData(Clipboard.kTextPlain);
      return data?.text;
    } catch (e) {
      return null;
    }
  }

  /// Check if clipboard contains a phone number
  static Future<bool> hasPhoneNumber() async {
    final text = await getClipboardContent();
    if (text == null || text.isEmpty) {
      return false;
    }

    return extractPhoneCandidates(text).isNotEmpty;
  }

  /// Check if clipboard contains a username
  static Future<bool> hasUsername() async {
    return (await getUsername()) != null;
  }

  /// Get parsed phone number from clipboard
  static Future<String?> getPhoneNumber() async {
    final text = await getClipboardContent();
    if (text == null || text.isEmpty) {
      return null;
    }

    final candidates = extractPhoneCandidates(text);
    if (candidates.isEmpty) {
      return null;
    }

    return candidates.first;
  }

  /// Get parsed username from clipboard
  static Future<String?> getUsername() async {
    final text = await getClipboardContent();
    if (text == null || text.isEmpty) {
      return null;
    }

    final trimmed = text.trim();

    // Case 1: direct username value or @username format.
    final direct = _sanitizeUsername(trimmed);
    if (direct != null) {
      return direct;
    }

    // Case 2: mention inside text.
    final mention = _mentionRegex.firstMatch(trimmed)?.group(1);
    if (mention != null &&
        AppConstants.genericUsernameRegex.hasMatch(mention)) {
      return mention;
    }

    // Case 3: username embedded in URL path.
    final fromUrl = _extractUsernameFromUrl(trimmed);
    if (fromUrl != null) {
      return fromUrl;
    }

    return null;
  }

  /// Get parsed email from clipboard
  static Future<String?> getEmail() async {
    final text = await getClipboardContent();
    if (text == null || text.isEmpty) {
      return null;
    }

    final trimmed = text.trim();

    if (AppConstants.emailRegex.hasMatch(trimmed)) {
      return trimmed;
    }

    // Also support free-form text that contains an email.
    final match = _emailSearchRegex.firstMatch(trimmed);
    if (match != null) {
      final value = match.group(0);
      if (value != null && AppConstants.emailRegex.hasMatch(value)) {
        return value;
      }
    }

    return null;
  }

  /// Extracts normalized phone candidates from any text.
  static List<String> extractPhoneCandidates(String text) {
    final matches = _phoneCandidateRegex.allMatches(text);
    final result = <String>[];
    final seen = <String>{};

    for (final match in matches) {
      final raw = match.group(0);
      if (raw == null) {
        continue;
      }

      final normalized = _normalizePhone(raw);
      if (normalized == null || seen.contains(normalized)) {
        continue;
      }

      seen.add(normalized);
      result.add(normalized);
    }

    return result;
  }

  static String? _normalizePhone(String raw) {
    var normalized = raw.trim();

    // Keep digits and an optional leading plus.
    final startsWithPlus = normalized.startsWith('+');
    normalized = normalized.replaceAll(RegExp(r'[^\d+]'), '');

    if (normalized.startsWith('00')) {
      normalized = '+${normalized.substring(2)}';
    } else if (startsWithPlus) {
      normalized = '+${normalized.replaceAll('+', '')}';
    } else {
      normalized = normalized.replaceAll('+', '');
    }

    final digitCount = normalized.replaceAll(RegExp(r'\D'), '').length;
    if (digitCount < 7 || digitCount > 15) {
      return null;
    }

    if (!RegExp(r'^\+?\d{7,15}$').hasMatch(normalized)) {
      return null;
    }

    return normalized;
  }

  static String? _sanitizeUsername(String value) {
    final username = value.startsWith('@') ? value.substring(1) : value;
    if (AppConstants.genericUsernameRegex.hasMatch(username)) {
      return username;
    }
    return null;
  }

  static String? _extractUsernameFromUrl(String text) {
    final uri = Uri.tryParse(text);
    if (uri == null || uri.host.isEmpty) {
      return null;
    }

    final segments = uri.pathSegments.where((s) => s.isNotEmpty).toList();
    if (segments.isEmpty) {
      return null;
    }

    final candidate = segments.last;
    return _sanitizeUsername(candidate);
  }

  /// Copy text to clipboard
  static Future<void> copyToClipboard(String text) async {
    await Clipboard.setData(ClipboardData(text: text));
  }
}
