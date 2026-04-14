import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'core/services/storage_service.dart';
import 'core/services/locale_service.dart';
import 'core/utils/app_router.dart';
import 'features/settings/viewmodels/theme_viewmodel.dart';
import 'shared/theme/app_theme.dart';
import 'shared/constants/app_strings.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize SharedPreferences storage
  await StorageService.init();

  // Load saved locale immediately before runApp
  final prefs = await SharedPreferences.getInstance();
  final savedLocale = prefs.getString('app_locale') ?? AppStrings.turkish;
  AppStrings.setLocale(savedLocale);

  // Set system UI overlay style
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      systemNavigationBarColor: Colors.transparent,
    ),
  );

  // Set preferred orientations
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  runApp(
    const ProviderScope(
      child: DirectFastApp(),
    ),
  );
}

class DirectFastApp extends ConsumerWidget {
  const DirectFastApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeModeProvider);
    // Watch the locale provider to trigger rebuild when locale changes
    final currentLocale = ref.watch(localeProvider);

    return MaterialApp.router(
      title: 'DirectFast',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: themeMode,
      routerConfig: AppRouter.router,
      // This key ensures MaterialApp rebuilds when locale changes
      key: ValueKey(currentLocale),
    );
  }
}
