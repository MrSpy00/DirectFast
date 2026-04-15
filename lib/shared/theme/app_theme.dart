import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class ThemeColorOption {
  final String id;
  final String labelKey;
  final Color seedColor;

  const ThemeColorOption({
    required this.id,
    required this.labelKey,
    required this.seedColor,
  });
}

class AppTheme {
  AppTheme._();

  static const String defaultColorId = 'violet';

  static const List<ThemeColorOption> colorOptions = [
    ThemeColorOption(
      id: 'violet',
      labelKey: 'color_violet',
      seedColor: Color(0xFF6750A4),
    ),
    ThemeColorOption(
      id: 'blue',
      labelKey: 'color_blue',
      seedColor: Color(0xFF1565C0),
    ),
    ThemeColorOption(
      id: 'teal',
      labelKey: 'color_teal',
      seedColor: Color(0xFF00897B),
    ),
    ThemeColorOption(
      id: 'green',
      labelKey: 'color_green',
      seedColor: Color(0xFF2E7D32),
    ),
    ThemeColorOption(
      id: 'orange',
      labelKey: 'color_orange',
      seedColor: Color(0xFFEF6C00),
    ),
    ThemeColorOption(
      id: 'red',
      labelKey: 'color_red',
      seedColor: Color(0xFFC62828),
    ),
    ThemeColorOption(
      id: 'rose',
      labelKey: 'color_rose',
      seedColor: Color(0xFFAD1457),
    ),
    ThemeColorOption(
      id: 'indigo',
      labelKey: 'color_indigo',
      seedColor: Color(0xFF3949AB),
    ),
  ];

  // ── True-Black OLED surface hierarchy ──────────────────────────────────────
  static const _darkSurface = Color(0xFF000000);
  static const _darkSurfaceContainerLow = Color(0xFF0C0C0C);
  static const _darkSurfaceContainer = Color(0xFF141414);
  static const _darkSurfaceContainerHigh = Color(0xFF1C1C1C);
  static const _darkSurfaceContainerHighest = Color(0xFF242424);

  static ThemeColorOption optionById(String id) {
    return colorOptions.firstWhere(
      (option) => option.id == id,
      orElse: () => colorOptions.first,
    );
  }

  static Color colorById(String id) => optionById(id).seedColor;

  static double _clamp01(double value) {
    return value.clamp(0.0, 1.0).toDouble();
  }

  static LinearGradient primaryGradientFromSeed(Color seedColor) {
    final hsl = HSLColor.fromColor(seedColor);
    final start = hsl.withLightness(_clamp01(hsl.lightness + 0.14)).toColor();
    final end = hsl.withLightness(_clamp01(hsl.lightness - 0.08)).toColor();

    return LinearGradient(
      colors: [start, end],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    );
  }

  static LinearGradient accentGradientFromSeed(Color seedColor) {
    final hsl = HSLColor.fromColor(seedColor);
    final shifted = hsl.withHue((hsl.hue + 28) % 360);

    return LinearGradient(
      colors: [
        shifted.withLightness(_clamp01(hsl.lightness + 0.1)).toColor(),
        hsl.withLightness(_clamp01(hsl.lightness - 0.02)).toColor(),
      ],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    );
  }

  static LinearGradient darkGradientFromSeed(Color seedColor) {
    final tint = Color.lerp(_darkSurfaceContainerLow, seedColor, 0.14)!;
    return LinearGradient(
      colors: [_darkSurface, tint, _darkSurfaceContainer],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    );
  }

  static LinearGradient primaryGradientFor(BuildContext context) {
    return primaryGradientFromSeed(Theme.of(context).colorScheme.primary);
  }

  static LinearGradient accentGradientFor(BuildContext context) {
    return accentGradientFromSeed(Theme.of(context).colorScheme.primary);
  }

  static LinearGradient darkGradientFor(BuildContext context) {
    return darkGradientFromSeed(Theme.of(context).colorScheme.primary);
  }

  // ── Text Theme ─────────────────────────────────────────────────────────────
  static TextTheme _buildTextTheme(Brightness brightness) {
    final baseTextTheme = GoogleFonts.interTextTheme();
    final color =
        brightness == Brightness.light ? Colors.black87 : Colors.white;

    return baseTextTheme.copyWith(
      displayLarge: GoogleFonts.inter(
        fontSize: 57,
        fontWeight: FontWeight.w400,
        letterSpacing: -0.25,
        color: color,
      ),
      displayMedium: GoogleFonts.inter(
        fontSize: 45,
        fontWeight: FontWeight.w400,
        color: color,
      ),
      displaySmall: GoogleFonts.inter(
        fontSize: 36,
        fontWeight: FontWeight.w400,
        color: color,
      ),
      headlineLarge: GoogleFonts.inter(
        fontSize: 32,
        fontWeight: FontWeight.w600,
        color: color,
      ),
      headlineMedium: GoogleFonts.inter(
        fontSize: 28,
        fontWeight: FontWeight.w600,
        color: color,
      ),
      headlineSmall: GoogleFonts.inter(
        fontSize: 24,
        fontWeight: FontWeight.w600,
        color: color,
      ),
      titleLarge: GoogleFonts.inter(
        fontSize: 22,
        fontWeight: FontWeight.w500,
        color: color,
      ),
      titleMedium: GoogleFonts.inter(
        fontSize: 16,
        fontWeight: FontWeight.w500,
        letterSpacing: 0.15,
        color: color,
      ),
      titleSmall: GoogleFonts.inter(
        fontSize: 14,
        fontWeight: FontWeight.w500,
        letterSpacing: 0.1,
        color: color,
      ),
      bodyLarge: GoogleFonts.inter(
        fontSize: 16,
        fontWeight: FontWeight.w400,
        letterSpacing: 0.5,
        color: color,
      ),
      bodyMedium: GoogleFonts.inter(
        fontSize: 14,
        fontWeight: FontWeight.w400,
        letterSpacing: 0.25,
        color: color,
      ),
      bodySmall: GoogleFonts.inter(
        fontSize: 12,
        fontWeight: FontWeight.w400,
        letterSpacing: 0.4,
        color: color,
      ),
      labelLarge: GoogleFonts.inter(
        fontSize: 14,
        fontWeight: FontWeight.w500,
        letterSpacing: 0.1,
        color: color,
      ),
      labelMedium: GoogleFonts.inter(
        fontSize: 12,
        fontWeight: FontWeight.w500,
        letterSpacing: 0.5,
        color: color,
      ),
      labelSmall: GoogleFonts.inter(
        fontSize: 11,
        fontWeight: FontWeight.w500,
        letterSpacing: 0.5,
        color: color,
      ),
    );
  }

  // ── Light Theme ────────────────────────────────────────────────────────────
  static ThemeData lightTheme({required Color seedColor}) {
    final colorScheme = ColorScheme.fromSeed(
      seedColor: seedColor,
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      textTheme: _buildTextTheme(Brightness.light),
      scaffoldBackgroundColor: const Color(0xFFFFFBFE),
      appBarTheme: AppBarTheme(
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.transparent,
        foregroundColor: colorScheme.onSurface,
      ),
      cardTheme: CardThemeData(
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        color: colorScheme.surface,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          textStyle: GoogleFonts.inter(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        isDense: true,
        filled: true,
        fillColor: colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
        prefixIconColor: colorScheme.primary,
        suffixIconColor: colorScheme.onSurfaceVariant,
        prefixIconConstraints: const BoxConstraints(minWidth: 44, minHeight: 44),
        suffixIconConstraints: const BoxConstraints(minWidth: 44, minHeight: 44),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: colorScheme.primary, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: colorScheme.error),
        ),
        contentPadding:
          const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: colorScheme.surfaceContainerHighest,
        labelStyle: GoogleFonts.inter(fontSize: 14),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }

  // ── Dark Theme (True Black / OLED) ─────────────────────────────────────────
  static ThemeData darkTheme({required Color seedColor}) {
    // Seed gives us the accent/primary palette; we override all surfaces to
    // true black so OLED panels display pure pixels.
    final hsl = HSLColor.fromColor(seedColor);
    final colorScheme = ColorScheme.fromSeed(
      seedColor: seedColor,
      brightness: Brightness.dark,
    ).copyWith(
      primary: hsl.withLightness(_clamp01(hsl.lightness + 0.35)).toColor(),
      secondary: hsl.withHue((hsl.hue + 20) % 360).withLightness(0.75).toColor(),
      tertiary: hsl.withHue((hsl.hue + 35) % 360).withLightness(0.8).toColor(),
      surface: _darkSurface,
      surfaceContainerLowest: _darkSurface,
      surfaceContainerLow: _darkSurfaceContainerLow,
      surfaceContainer: _darkSurfaceContainer,
      surfaceContainerHigh: _darkSurfaceContainerHigh,
      surfaceContainerHighest: _darkSurfaceContainerHighest,
      onSurface: Colors.white,
      onSurfaceVariant: const Color(0xFFCAC4D0),
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      textTheme: _buildTextTheme(Brightness.dark),
      scaffoldBackgroundColor: _darkSurface,
      appBarTheme: AppBarTheme(
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.transparent,
        foregroundColor: colorScheme.onSurface,
      ),
      cardTheme: CardThemeData(
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        color: colorScheme.surfaceContainerLow,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          textStyle: GoogleFonts.inter(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        isDense: true,
        filled: true,
        // Use a fixed dark fill so the field is always legible on black
        fillColor: _darkSurfaceContainerHighest.withValues(alpha: 0.8),
        prefixIconColor: colorScheme.primary,
        suffixIconColor: colorScheme.onSurfaceVariant,
        prefixIconConstraints: const BoxConstraints(minWidth: 44, minHeight: 44),
        suffixIconConstraints: const BoxConstraints(minWidth: 44, minHeight: 44),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: colorScheme.primary, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: colorScheme.error),
        ),
        contentPadding:
          const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: colorScheme.surfaceContainerHighest,
        labelStyle: GoogleFonts.inter(fontSize: 14),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }
}
