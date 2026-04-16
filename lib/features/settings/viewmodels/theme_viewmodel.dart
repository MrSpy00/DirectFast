import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/services/storage_service.dart';
import '../../../shared/theme/app_theme.dart';

enum AppThemeMode {
  light,
  dark,
  amoled,
  system;

  static AppThemeMode fromStorage(String value) {
    switch (value) {
      case 'light':
        return AppThemeMode.light;
      case 'dark':
        return AppThemeMode.dark;
      case 'amoled':
        return AppThemeMode.amoled;
      default:
        return AppThemeMode.system;
    }
  }

  ThemeMode toMaterialThemeMode() {
    switch (this) {
      case AppThemeMode.light:
        return ThemeMode.light;
      case AppThemeMode.dark:
      case AppThemeMode.amoled:
        return ThemeMode.dark;
      case AppThemeMode.system:
        return ThemeMode.system;
    }
  }

  String toStorageValue() {
    switch (this) {
      case AppThemeMode.light:
        return 'light';
      case AppThemeMode.dark:
        return 'dark';
      case AppThemeMode.amoled:
        return 'amoled';
      case AppThemeMode.system:
        return 'system';
    }
  }
}

final appThemeModeProvider =
    StateNotifierProvider<AppThemeModeNotifier, AppThemeMode>((ref) {
  return AppThemeModeNotifier();
});

final themeModeProvider = Provider<ThemeMode>((ref) {
  return ref.watch(appThemeModeProvider).toMaterialThemeMode();
});

final useAmoledThemeProvider = Provider<bool>((ref) {
  return ref.watch(appThemeModeProvider) == AppThemeMode.amoled;
});

final themeColorIdProvider =
    StateNotifierProvider<ThemeColorNotifier, String>((ref) {
  return ThemeColorNotifier();
});

final customThemeColorProvider =
    StateNotifierProvider<CustomThemeColorNotifier, Color?>((ref) {
  return CustomThemeColorNotifier();
});

class AppThemeModeNotifier extends StateNotifier<AppThemeMode> {
  AppThemeModeNotifier() : super(AppThemeMode.system) {
    _loadThemeMode();
  }

  void _loadThemeMode() {
    final savedMode = StorageService.getThemeMode();
    state = AppThemeMode.fromStorage(savedMode);
  }

  Future<void> setThemeMode(AppThemeMode mode) async {
    state = mode;
    await StorageService.setThemeMode(mode.toStorageValue());
  }
}

class ThemeColorNotifier extends StateNotifier<String> {
  ThemeColorNotifier() : super(AppTheme.defaultColorId) {
    _loadThemeColorId();
  }

  void _loadThemeColorId() {
    final savedId = StorageService.getThemeColorId();
    state = AppTheme.optionById(savedId).id;
  }

  Future<void> setThemeColorId(String colorId) async {
    final normalizedId = colorId == AppTheme.customColorId
        ? AppTheme.customColorId
        : AppTheme.optionById(colorId).id;
    state = normalizedId;
    await StorageService.setThemeColorId(normalizedId);
  }
}

class CustomThemeColorNotifier extends StateNotifier<Color?> {
  CustomThemeColorNotifier() : super(null) {
    _loadCustomColor();
  }

  void _loadCustomColor() {
    final storedValue = StorageService.getCustomThemeColorValue();
    if (storedValue != null) {
      state = Color(storedValue);
    }
  }

  Future<void> setColor(Color color) async {
    state = color;
    await StorageService.setCustomThemeColorValue(color.toARGB32());
  }

  Future<void> clearColor() async {
    state = null;
    await StorageService.setCustomThemeColorValue(null);
  }
}
