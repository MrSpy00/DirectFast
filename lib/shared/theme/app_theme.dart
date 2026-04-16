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
  static const String customColorId = 'custom';

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
    ThemeColorOption(
      id: 'cyan',
      labelKey: 'color_cyan',
      seedColor: Color(0xFF00ACC1),
    ),
    ThemeColorOption(
      id: 'mint',
      labelKey: 'color_mint',
      seedColor: Color(0xFF00C853),
    ),
    ThemeColorOption(
      id: 'lime',
      labelKey: 'color_lime',
      seedColor: Color(0xFFAFB42B),
    ),
    ThemeColorOption(
      id: 'amber',
      labelKey: 'color_amber',
      seedColor: Color(0xFFFFB300),
    ),
    ThemeColorOption(
      id: 'gold',
      labelKey: 'color_gold',
      seedColor: Color(0xFFF9A825),
    ),
    ThemeColorOption(
      id: 'magenta',
      labelKey: 'color_magenta',
      seedColor: Color(0xFFD81B60),
    ),
    ThemeColorOption(
      id: 'purple',
      labelKey: 'color_purple',
      seedColor: Color(0xFF7B1FA2),
    ),
    ThemeColorOption(
      id: 'brown',
      labelKey: 'color_brown',
      seedColor: Color(0xFF6D4C41),
    ),
    ThemeColorOption(
      id: 'slate',
      labelKey: 'color_slate',
      seedColor: Color(0xFF455A64),
    ),
    ThemeColorOption(
      id: 'coral',
      labelKey: 'color_coral',
      seedColor: Color(0xFFFF7043),
    ),
  ];

  // ── Dark/AMOLED surface hierarchies ────────────────────────────────────────
  static const _darkSurface = Color(0xFF121212);
  static const _darkSurfaceContainerLow = Color(0xFF1A1A1A);
  static const _darkSurfaceContainer = Color(0xFF202020);
  static const _darkSurfaceContainerHigh = Color(0xFF262626);
  static const _darkSurfaceContainerHighest = Color(0xFF2F2F2F);

  static const _amoledSurface = Color(0xFF000000);
  static const _amoledSurfaceContainerLow = Color(0xFF0C0C0C);
  static const _amoledSurfaceContainer = Color(0xFF141414);
  static const _amoledSurfaceContainerHigh = Color(0xFF1C1C1C);
  static const _amoledSurfaceContainerHighest = Color(0xFF242424);

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

  static Color _mix(Color a, Color b, double amount) {
    return Color.lerp(a, b, _clamp01(amount))!;
  }

  static Color _onColor(Color color) {
    return ThemeData.estimateBrightnessForColor(color) == Brightness.dark
        ? Colors.white
        : Colors.black;
  }

  static LinearGradient primaryGradientFromSeed(Color seedColor) {
    final hsl = HSLColor.fromColor(seedColor);
    final end = hsl
        .withSaturation(_clamp01(hsl.saturation + 0.08))
        .withLightness(_clamp01(hsl.lightness - 0.14))
        .toColor();

    return LinearGradient(
      colors: [seedColor, end],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    );
  }

  static LinearGradient accentGradientFromSeed(Color seedColor) {
    final hsl = HSLColor.fromColor(seedColor);
    final shifted = hsl
        .withHue((hsl.hue + 34) % 360)
        .withSaturation(_clamp01(hsl.saturation + 0.16));

    return LinearGradient(
      colors: [
        shifted.toColor(),
        seedColor,
      ],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    );
  }

  static LinearGradient darkGradientFromSeed(Color seedColor) {
    final tint = Color.lerp(_darkSurfaceContainerLow, seedColor, 0.32)!;
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
    final scheme = Theme.of(context).colorScheme;
    final tint = Color.lerp(scheme.surfaceContainerLow, scheme.primary, 0.28)!;
    return LinearGradient(
      colors: [scheme.surface, tint, scheme.surfaceContainer],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    );
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
    final hsl = HSLColor.fromColor(seedColor);
    final accent = hsl
        .withHue((hsl.hue + 24) % 360)
        .withSaturation(_clamp01(hsl.saturation + 0.12))
        .withLightness(_clamp01(hsl.lightness * 0.9))
        .toColor();
    final tertiary = hsl
        .withHue((hsl.hue + 48) % 360)
        .withSaturation(_clamp01(hsl.saturation + 0.1))
        .withLightness(_clamp01(hsl.lightness * 0.95))
        .toColor();
    final primaryContainer = _mix(seedColor, Colors.white, 0.74);
    final secondaryContainer = _mix(accent, Colors.white, 0.78);
    final tertiaryContainer = _mix(tertiary, Colors.white, 0.8);

    final colorScheme = ColorScheme.fromSeed(
      seedColor: seedColor,
      dynamicSchemeVariant: DynamicSchemeVariant.vibrant,
    ).copyWith(
      primary: seedColor,
      onPrimary: _onColor(seedColor),
      secondary: accent,
      onSecondary: _onColor(accent),
      tertiary: tertiary,
      onTertiary: _onColor(tertiary),
      primaryContainer: primaryContainer,
      onPrimaryContainer: _onColor(primaryContainer),
      secondaryContainer: secondaryContainer,
      onSecondaryContainer: _onColor(secondaryContainer),
      tertiaryContainer: tertiaryContainer,
      onTertiaryContainer: _onColor(tertiaryContainer),
      surfaceTint: seedColor,
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
        isDense: false,
        filled: true,
        fillColor: colorScheme.surfaceContainerHighest.withValues(alpha: 0.44),
        prefixIconColor: colorScheme.primary,
        suffixIconColor: colorScheme.onSurfaceVariant,
        alignLabelWithHint: true,
        prefixIconConstraints:
            const BoxConstraints(minWidth: 46, minHeight: 46),
        suffixIconConstraints:
            const BoxConstraints(minWidth: 46, minHeight: 46),
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
            const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
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

  static ThemeData _buildDarkTheme({
    required Color seedColor,
    required bool amoled,
  }) {
    final hsl = HSLColor.fromColor(seedColor);
    final primary = hsl
        .withSaturation(_clamp01(hsl.saturation + 0.2))
        .withLightness(0.66)
        .toColor();
    final secondary = hsl
        .withHue((hsl.hue + 24) % 360)
        .withSaturation(_clamp01(hsl.saturation + 0.2))
        .withLightness(0.64)
        .toColor();
    final tertiary = hsl
        .withHue((hsl.hue + 48) % 360)
        .withSaturation(_clamp01(hsl.saturation + 0.16))
        .withLightness(0.63)
        .toColor();
    final primaryContainer = _mix(primary, Colors.black, 0.55);
    final secondaryContainer = _mix(secondary, Colors.black, 0.58);
    final tertiaryContainer = _mix(tertiary, Colors.black, 0.58);
    final surface = amoled ? _amoledSurface : _darkSurface;
    final surfaceLow =
        amoled ? _amoledSurfaceContainerLow : _darkSurfaceContainerLow;
    final surfaceContainer =
        amoled ? _amoledSurfaceContainer : _darkSurfaceContainer;
    final surfaceHigh =
        amoled ? _amoledSurfaceContainerHigh : _darkSurfaceContainerHigh;
    final surfaceHighest =
        amoled ? _amoledSurfaceContainerHighest : _darkSurfaceContainerHighest;

    final colorScheme = ColorScheme.fromSeed(
      seedColor: seedColor,
      brightness: Brightness.dark,
      dynamicSchemeVariant: DynamicSchemeVariant.vibrant,
    ).copyWith(
      primary: primary,
      onPrimary: _onColor(primary),
      secondary: secondary,
      onSecondary: _onColor(secondary),
      tertiary: tertiary,
      onTertiary: _onColor(tertiary),
      primaryContainer: primaryContainer,
      onPrimaryContainer: Colors.white,
      secondaryContainer: secondaryContainer,
      onSecondaryContainer: Colors.white,
      tertiaryContainer: tertiaryContainer,
      onTertiaryContainer: Colors.white,
      surface: surface,
      surfaceContainerLowest: surface,
      surfaceContainerLow: surfaceLow,
      surfaceContainer: surfaceContainer,
      surfaceContainerHigh: surfaceHigh,
      surfaceContainerHighest: surfaceHighest,
      onSurface: Colors.white,
      onSurfaceVariant: const Color(0xFFCAC4D0),
      surfaceTint: primary,
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      textTheme: _buildTextTheme(Brightness.dark),
      scaffoldBackgroundColor: surface,
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
        isDense: false,
        filled: true,
        fillColor: surfaceHighest.withValues(alpha: 0.86),
        prefixIconColor: colorScheme.primary,
        suffixIconColor: colorScheme.onSurfaceVariant,
        alignLabelWithHint: true,
        prefixIconConstraints:
            const BoxConstraints(minWidth: 46, minHeight: 46),
        suffixIconConstraints:
            const BoxConstraints(minWidth: 46, minHeight: 46),
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
            const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
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

  // ── Dark Theme ──────────────────────────────────────────────────────────────
  static ThemeData darkTheme({required Color seedColor}) {
    return _buildDarkTheme(seedColor: seedColor, amoled: false);
  }

  // ── AMOLED Theme (True Black) ───────────────────────────────────────────────
  static ThemeData amoledTheme({required Color seedColor}) {
    return _buildDarkTheme(seedColor: seedColor, amoled: true);
  }
}
