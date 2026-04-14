import 'package:flutter/services.dart';
import '../constants/app_constants.dart';

class ClipboardService {
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

    // Remove spaces and special characters
    final cleaned = text.replaceAll(RegExp(r'[^\d+]'), '');

    // Check if it looks like a phone number (7-15 digits, optionally with +)
    return cleaned.length >= 7 &&
        cleaned.length <= 16 &&
        RegExp(r'^\+?\d{7,15}$').hasMatch(cleaned);
  }

  /// Check if clipboard contains a username
  static Future<bool> hasUsername() async {
    final text = await getClipboardContent();
    if (text == null || text.isEmpty) {
      return false;
    }

    // Remove @ if present
    final username = text.startsWith('@') ? text.substring(1) : text;

    return AppConstants.genericUsernameRegex.hasMatch(username);
  }

  /// Get parsed phone number from clipboard
  static Future<String?> getPhoneNumber() async {
    final text = await getClipboardContent();
    if (text == null || text.isEmpty) {
      return null;
    }

    final cleaned = text.replaceAll(RegExp(r'[^\d+]'), '');

    if (cleaned.length >= 7 && cleaned.length <= 16) {
      return cleaned;
    }

    return null;
  }

  /// Get parsed username from clipboard
  static Future<String?> getUsername() async {
    final text = await getClipboardContent();
    if (text == null || text.isEmpty) {
      return null;
    }

    final username = text.startsWith('@') ? text.substring(1) : text;

    if (AppConstants.genericUsernameRegex.hasMatch(username)) {
      return username;
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

    return null;
  }

  /// Copy text to clipboard
  static Future<void> copyToClipboard(String text) async {
    await Clipboard.setData(ClipboardData(text: text));
  }
}
