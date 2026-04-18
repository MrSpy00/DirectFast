import 'dart:async';

import 'package:app_links/app_links.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'core/services/deep_link_service.dart';
import 'core/utils/date_formatting.dart';
import 'core/services/storage_service.dart';
import 'core/services/locale_service.dart';
import 'core/utils/app_router.dart';
import 'features/home/viewmodels/home_viewmodel.dart';
import 'features/settings/viewmodels/theme_viewmodel.dart';
import 'shared/theme/app_theme.dart';
import 'shared/constants/app_strings.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize SharedPreferences storage
  await StorageService.init();

  // Load saved locale immediately before runApp.
  final savedLocale = AppStrings.normalizeLocale(StorageService.getLocale());
  AppStrings.setLocale(savedLocale);
  await ensureDateFormattingInitialized(savedLocale);

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

class DirectFastApp extends ConsumerStatefulWidget {
  const DirectFastApp({super.key});

  @override
  ConsumerState<DirectFastApp> createState() => _DirectFastAppState();
}

class _DirectFastAppState extends ConsumerState<DirectFastApp> {
  final AppLinks _appLinks = AppLinks();
  StreamSubscription<Uri>? _deepLinkSubscription;

  @override
  void initState() {
    super.initState();
    _initializeDeepLinks();
  }

  @override
  void dispose() {
    _deepLinkSubscription?.cancel();
    super.dispose();
  }

  Future<void> _initializeDeepLinks() async {
    try {
      final initialUri = await _appLinks.getInitialLink();
      if (initialUri != null) {
        _applyDeepLink(initialUri);
      }
    } catch (_) {
      // Ignore malformed startup links to keep app boot stable.
    }

    _deepLinkSubscription = _appLinks.uriLinkStream.listen(
      _applyDeepLink,
      onError: (_) {
        // Ignore stream errors; app behavior should remain deterministic.
      },
    );
  }

  void _applyDeepLink(Uri uri) {
    final request = DeepLinkService.parse(uri);
    if (request == null) {
      return;
    }

    ref.read(selectedCategoryProvider.notifier).state =
        request.platform.category;
    ref.read(selectedPlatformProvider.notifier).state = request.platform;
    ref.read(pendingContactProvider.notifier).state = request.contact;

    AppRouter.router.go(AppRouter.home);
  }

  @override
  Widget build(BuildContext context) {
    final appThemeMode = ref.watch(appThemeModeProvider);
    final themeMode = ref.watch(themeModeProvider);
    final useAmoledTheme = ref.watch(useAmoledThemeProvider);
    final themeColorId = ref.watch(themeColorIdProvider);
    final customThemeColor = ref.watch(customThemeColorProvider);
    // Watch the locale provider to trigger rebuild when locale changes
    final currentLocale = ref.watch(localeProvider);
    final seedColor = themeColorId == AppTheme.customColorId
        ? (customThemeColor ?? AppTheme.colorById(AppTheme.defaultColorId))
        : AppTheme.colorById(themeColorId);

    return MaterialApp.router(
      title: 'DirectFast',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme(seedColor: seedColor),
      darkTheme: useAmoledTheme
          ? AppTheme.amoledTheme(seedColor: seedColor)
          : AppTheme.darkTheme(seedColor: seedColor),
      themeMode: themeMode,
      routerConfig: AppRouter.router,
      // This key ensures MaterialApp rebuilds when locale changes
      key: ValueKey('${currentLocale}_${appThemeMode.name}'),
    );
  }
}
