import 'package:shared_preferences/shared_preferences.dart';
import '../../data/models/chat_history_item.dart';
import '../../data/models/template_item.dart';
import '../constants/app_constants.dart';

class StorageService {
  static SharedPreferences? _prefs;

  // Keys for SharedPreferences
  static const String _historyKey = 'chat_history';
  static const String _templatesKey = 'templates_v1';
  static const String _themeKey = 'theme_mode';
  static const String _themeColorKey = 'theme_color_id';

  /// Initialize SharedPreferences
  static Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  /// Get SharedPreferences instance
  static SharedPreferences get prefs {
    if (_prefs == null) {
      throw Exception(
          'StorageService not initialized. Call StorageService.init() first.',);
    }
    return _prefs!;
  }

  // ===========================
  // HISTORY OPERATIONS
  // ===========================

  /// Add item to history
  static Future<void> addToHistory(ChatHistoryItem item) async {
    final currentHistory = getAllHistory();

    // Check if item already exists (avoid duplicates)
    final existingIndex = currentHistory.indexWhere((h) => h.id == item.id);
    if (existingIndex != -1) {
      // Update existing item
      currentHistory[existingIndex] = item;
    } else {
      // Add new item
      currentHistory.add(item);
    }

    // Save to SharedPreferences
    await _saveHistory(currentHistory);
  }

  /// Get all history items (sorted by timestamp, newest first)
  static List<ChatHistoryItem> getAllHistory() {
    try {
      final jsonString = prefs.getString(_historyKey);

      if (jsonString == null || jsonString.isEmpty) {
        return [];
      }

      final items = ChatHistoryItem.decodeList(jsonString);

      // Sort by timestamp (newest first)
      items.sort((a, b) => b.timestamp.compareTo(a.timestamp));

      return items;
    } catch (e) {
      // Gracefully return empty history on deserialization error
      return [];
    }
  }

  /// Delete history item by id
  static Future<void> deleteHistoryItem(String id) async {
    final currentHistory = getAllHistory();
    currentHistory.removeWhere((item) => item.id == id);
    await _saveHistory(currentHistory);
  }

  /// Clear all history
  static Future<void> clearAllHistory() async {
    await prefs.remove(_historyKey);
  }

  /// Save history list to SharedPreferences
  static Future<void> _saveHistory(List<ChatHistoryItem> items) async {
    final jsonString = ChatHistoryItem.encodeList(items);
    await prefs.setString(_historyKey, jsonString);
  }

  // ===========================
  // TEMPLATE OPERATIONS
  // ===========================

  /// Add or update a template
  static Future<void> addTemplate(TemplateItem item) async {
    final current = getAllTemplates();
    final existing = current.indexWhere((t) => t.id == item.id);
    if (existing != -1) {
      current[existing] = item;
    } else {
      current.add(item);
    }
    await _saveTemplates(current);
  }

  /// Get all templates (newest first)
  static List<TemplateItem> getAllTemplates() {
    try {
      final jsonString = prefs.getString(_templatesKey);
      if (jsonString == null || jsonString.isEmpty) {
        return [];
      }
      final items = TemplateItem.decodeList(jsonString);
      items.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      return items;
    } catch (_) {
      return [];
    }
  }

  /// Delete a template by id
  static Future<void> deleteTemplate(String id) async {
    final current = getAllTemplates();
    current.removeWhere((t) => t.id == id);
    await _saveTemplates(current);
  }

  /// Save templates list to SharedPreferences
  static Future<void> _saveTemplates(List<TemplateItem> items) async {
    await prefs.setString(_templatesKey, TemplateItem.encodeList(items));
  }

  // ===========================
  // SETTINGS OPERATIONS
  // ===========================

  /// Get theme mode
  static String getThemeMode() {
    return prefs.getString(_themeKey) ?? 'system';
  }

  /// Set theme mode
  static Future<void> setThemeMode(String mode) async {
    await prefs.setString(_themeKey, mode);
  }

  /// Get theme color id
  static String getThemeColorId() {
    return prefs.getString(_themeColorKey) ?? 'violet';
  }

  /// Set theme color id
  static Future<void> setThemeColorId(String colorId) async {
    await prefs.setString(_themeColorKey, colorId);
  }

  /// Get locale
  static String getLocale() {
    return prefs.getString(AppConstants.localeKey) ?? 'tr';
  }

  /// Set locale
  static Future<void> setLocale(String locale) async {
    await prefs.setString(AppConstants.localeKey, locale);
  }

  // ===========================
  // UTILITY METHODS
  // ===========================

  /// Clear all data (for debugging or reset)
  static Future<void> clearAll() async {
    await prefs.clear();
  }

  /// Check if history is empty
  static bool isHistoryEmpty() {
    final jsonString = prefs.getString(_historyKey);
    return jsonString == null || jsonString.isEmpty;
  }

  /// Get history count
  static int getHistoryCount() {
    return getAllHistory().length;
  }
}
