import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/platform_type.dart';
import '../../../shared/constants/app_strings.dart';
import '../../../shared/widgets/glassmorphic_container.dart';
import '../../../shared/widgets/app_logo.dart';
import '../../../shared/widgets/brand_icon.dart';
import '../viewmodels/home_viewmodel.dart';
import '../../history/viewmodels/history_viewmodel.dart';
import '../../../data/models/chat_history_item.dart';
import '../../../shared/theme/app_theme.dart';
import '../../../core/utils/app_router.dart';
import '../../../core/services/clipboard_service.dart';
import '../../../core/services/locale_service.dart';

/// HomeScreen — premium micro-interactions, smart clipboard overlay,
/// recent contacts carousel, haptic feedback throughout.
///
/// Performance notes:
/// - [_CyberBackground] is a plain [StatelessWidget] — zero repaint cost.
/// - Platform grid tiles are wrapped in [RepaintBoundary].
/// - [GlassmorphicContainer.flat] (no BackdropFilter) used for inner cards.
/// - Single BackdropFilter reserved for the [_SmartClipboardBanner] pill.
class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  final TextEditingController _contactController = TextEditingController();
  String? _errorMessage;
  bool _clipboardBannerDismissed = false;

  @override
  void initState() {
    super.initState();
    // Pre-warm clipboard check so the banner appears without delay.
    ClipboardService.getClipboardContent();
  }

  @override
  void dispose() {
    _contactController.dispose();
    super.dispose();
  }

  Future<void> _quickPaste() async {
    await HapticFeedback.lightImpact();
    final content = await ClipboardService.getClipboardContent();
    if (content != null && mounted) {
      _contactController.text = content;
    }
  }

  Future<void> _launchChat() async {
    await HapticFeedback.mediumImpact();
    final platform = ref.read(selectedPlatformProvider);
    final contact = _contactController.text.trim();

    setState(() => _errorMessage = null);

    final launcher = ref.read(chatLauncherProvider);
    final result =
        await launcher.launchChat(platform: platform, contact: contact);

    if (!mounted) {
      return;
    }

    if (!result.success) {
      setState(() => _errorMessage = result.error);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            result.error ??
                AppStrings.tr('failed_to_open', args: [platform.displayName]),
          ),
          backgroundColor: Theme.of(context).colorScheme.error,
          behavior: SnackBarBehavior.floating,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
    } else {
      _contactController.clear();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            result.message ??
                AppStrings.tr('opening', args: [platform.displayName]),
          ),
          backgroundColor: platform.color,
          behavior: SnackBarBehavior.floating,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
    }
  }

  // ── Build ─────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    ref.watch(localeProvider);
    final selectedPlatform = ref.watch(selectedPlatformProvider);
    final selectedCategory = ref.watch(selectedCategoryProvider);
    final clipboardSuggestion = ref.watch(clipboardSuggestionProvider);
    final recentHistory = ref.watch(historyProvider);

    // Reset banner dismiss when the user switches platform — new context means
    // the clipboard content might be relevant again.
    ref.listen<PlatformType>(selectedPlatformProvider, (_, __) {
      if (_clipboardBannerDismissed) {
        setState(() => _clipboardBannerDismissed = false);
      }
    });

    final platformsByCategory = PlatformType.values
        .where((p) => p.category == selectedCategory)
        .toList();

    final showBanner = !_clipboardBannerDismissed &&
        clipboardSuggestion.value != null &&
        selectedCategory != PlatformCategory.utility;

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        title: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            RepaintBoundary(child: AppLogo(size: 32)),
            SizedBox(width: 12),
            _AppTitle(),
          ],
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.history_rounded),
            onPressed: () {
              HapticFeedback.lightImpact();
              context.push(AppRouter.history);
            },
            tooltip: AppStrings.tr('history'),
          ),
          IconButton(
            icon: const Icon(Icons.settings_rounded),
            onPressed: () {
              HapticFeedback.lightImpact();
              context.push(AppRouter.settings);
            },
            tooltip: AppStrings.tr('settings'),
          ),
        ],
      ),
      body: Stack(
        children: [
          // Static gradient background — zero frame cost.
          const RepaintBoundary(child: _CyberBackground()),

          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              physics: const BouncingScrollPhysics(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Reserve space for the floating banner (avoids content jump).
                  if (showBanner) const SizedBox(height: 56),
                  const SizedBox(height: 8),

                  _buildHeroSection(),
                  const SizedBox(height: 24),

                  // Recent contacts carousel — only when history exists and
                  // we are in a messaging category.
                  if (recentHistory.isNotEmpty &&
                      selectedCategory != PlatformCategory.utility) ...[
                    _buildRecentContacts(recentHistory, selectedPlatform),
                    const SizedBox(height: 20),
                  ],

                  _buildCategoryTabs(selectedCategory),
                  const SizedBox(height: 24),

                  if (selectedCategory == PlatformCategory.utility)
                    _buildUtilitiesPanel()
                  else ...[
                    RepaintBoundary(
                      child: _buildPlatformGrid(
                        platformsByCategory,
                        selectedPlatform,
                      ),
                    ),
                    const SizedBox(height: 24),
                    _buildInputSection(selectedPlatform),
                  ],

                  const SizedBox(height: 24),
                  const _InfoCard(),
                ],
              ),
            ),
          ),

          // ── Smart Clipboard Banner (floating pill) ─────────────────────────
          if (showBanner)
            SafeArea(
              child: Align(
                alignment: Alignment.topCenter,
                child: _SmartClipboardBanner(
                  content: clipboardSuggestion.value!,
                  onUse: () {
                    HapticFeedback.lightImpact();
                    _contactController.text = clipboardSuggestion.value!;
                    setState(() => _clipboardBannerDismissed = true);
                  },
                  onDismiss: () {
                    HapticFeedback.selectionClick();
                    setState(() => _clipboardBannerDismissed = true);
                  },
                )
                    .animate()
                    .slideY(
                      begin: -1.5,
                      end: 0,
                      duration: 500.ms,
                      curve: Curves.easeOutBack,
                    )
                    .fadeIn(duration: 300.ms),
              ),
            ),
        ],
      ),
    );
  }

  // ── Section builders ──────────────────────────────────────────────────────

  Widget _buildHeroSection() {
    return RepaintBoundary(
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: AppTheme.primaryGradientFor(context),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color:
                  Theme.of(context).colorScheme.primary.withValues(alpha: 0.3),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(Icons.flash_on, color: Colors.white, size: 32),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    AppStrings.tr('quick_connect'),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.5,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    AppStrings.tr('chat_without_saving'),
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.9),
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ).animate().fadeIn(duration: 600.ms).slideY(begin: -0.2, end: 0),
    );
  }

  /// Horizontally scrolling row of the last 3 unique contacts, deduped by
  /// `platformName:contact`. Tap fills the input field and selects the
  /// matching platform.
  Widget _buildRecentContacts(
    List<ChatHistoryItem> history,
    PlatformType selectedPlatform,
  ) {
    // Deduplicate: keep first occurrence of each platform+contact combo.
    final seen = <String>{};
    final unique = <ChatHistoryItem>[];
    for (final item in history) {
      final key = '${item.platformName}:${item.contact}';
      if (seen.add(key)) {
        unique.add(item);
        if (unique.length == 3) {
          break;
        }
      }
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 10),
          child: Text(
            AppStrings.tr('recent_contacts'),
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: Theme.of(context)
                      .colorScheme
                      .onSurface
                      .withValues(alpha: 0.7),
                ),
          ),
        ),
        SizedBox(
          height: 46,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            itemCount: unique.length,
            separatorBuilder: (_, __) => const SizedBox(width: 8),
            itemBuilder: (context, index) {
              final item = unique[index];
              final isActive = item.platform == selectedPlatform;
              return _TappableScale(
                onTap: () {
                  HapticFeedback.lightImpact();
                  // Switch to matching platform and fill the contact field.
                  ref.read(selectedCategoryProvider.notifier).state =
                      item.platform.category;
                  ref.read(selectedPlatformProvider.notifier).state =
                      item.platform;
                  _contactController.text = item.contact;
                  setState(() => _errorMessage = null);
                },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  decoration: BoxDecoration(
                    gradient: isActive
                        ? LinearGradient(colors: item.platform.gradientColors)
                        : null,
                    color: isActive
                        ? null
                        : Theme.of(context)
                            .colorScheme
                            .surfaceContainerHighest
                            .withValues(alpha: 0.7),
                    borderRadius: BorderRadius.circular(22),
                    border: Border.all(
                      color: isActive
                          ? Colors.transparent
                          : Theme.of(context)
                              .colorScheme
                              .outline
                              .withValues(alpha: 0.25),
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      _buildSmallPlatformIcon(item.platform, isActive),
                      const SizedBox(width: 8),
                      Text(
                        item.contact,
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: isActive
                              ? Colors.white
                              : Theme.of(context).colorScheme.onSurface,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    ).animate().fadeIn(duration: 400.ms, delay: 60.ms);
  }

  Widget _buildCategoryTabs(PlatformCategory selectedCategory) {
    return GlassmorphicContainer(
      padding: const EdgeInsets.all(8),
      child: Row(
        children: PlatformCategory.values.map((category) {
          final isSelected = category == selectedCategory;
          return Expanded(
            child: _TappableScale(
              onTap: () {
                HapticFeedback.lightImpact();
                ref.read(selectedCategoryProvider.notifier).state = category;
                final first = PlatformType.values
                    .firstWhere((p) => p.category == category);
                ref.read(selectedPlatformProvider.notifier).state = first;
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                margin: const EdgeInsets.symmetric(horizontal: 4),
                padding: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  gradient:
                      isSelected ? AppTheme.primaryGradientFor(context) : null,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      category.icon,
                      color: isSelected
                          ? Colors.white
                          : Theme.of(context)
                              .colorScheme
                              .onSurface
                              .withValues(alpha: 0.6),
                      size: 24,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      AppStrings.tr(
                        category.name == 'chat'
                            ? 'chat_apps'
                            : category.name == 'social'
                                ? 'social_media'
                                : 'utilities',
                      ),
                      style: TextStyle(
                        color: isSelected
                            ? Colors.white
                            : Theme.of(context).colorScheme.onSurface,
                        fontSize: 11,
                        fontWeight:
                            isSelected ? FontWeight.bold : FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }).toList(),
      ),
    ).animate().fadeIn(duration: 400.ms, delay: 100.ms);
  }

  Widget _buildPlatformGrid(
    List<PlatformType> platforms,
    PlatformType selectedPlatform,
  ) {
    return GlassmorphicContainer(
      padding: const EdgeInsets.all(16),
      child: GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 4,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          childAspectRatio: 0.85,
        ),
        itemCount: platforms.length,
        itemBuilder: (context, index) {
          final platform = platforms[index];
          final isSelected = platform == selectedPlatform;

          return RepaintBoundary(
            child: _TappableScale(
              onTap: () {
                HapticFeedback.lightImpact();
                ref.read(selectedPlatformProvider.notifier).state = platform;
                setState(() => _errorMessage = null);
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                decoration: BoxDecoration(
                  gradient: isSelected
                      ? LinearGradient(
                          colors: platform.gradientColors,
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        )
                      : null,
                  color: isSelected
                      ? null
                      : Theme.of(context)
                          .colorScheme
                          .surfaceContainerHighest
                          .withValues(alpha: 0.5),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: isSelected
                        ? platform.color
                        : Theme.of(context)
                            .colorScheme
                            .outline
                            .withValues(alpha: 0.2),
                    width: isSelected ? 2.5 : 1,
                  ),
                  boxShadow: isSelected
                      ? [
                          BoxShadow(
                            color: platform.color.withValues(alpha: 0.4),
                            blurRadius: 12,
                            offset: const Offset(0, 4),
                          ),
                        ]
                      : null,
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _getPlatformIcon(platform, isSelected),
                    const SizedBox(height: 6),
                    Text(
                      platform.displayName,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: isSelected
                            ? Colors.white
                            : Theme.of(context).colorScheme.onSurface,
                        fontSize: 10,
                        fontWeight:
                            isSelected ? FontWeight.bold : FontWeight.w500,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    ).animate().fadeIn(duration: 400.ms, delay: 200.ms);
  }

  Widget _buildInputSection(PlatformType platform) {
    return GlassmorphicContainer(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          TextField(
            controller: _contactController,
            decoration: InputDecoration(
              hintText: AppStrings.tr(
                platform.requiresPhoneNumber
                    ? 'enter_phone'
                    : platform.requiresEmail
                        ? 'enter_email'
                        : 'enter_username',
              ),
              prefixIcon: _buildPrefixIcon(platform),
              suffixIcon: IconButton(
                icon: const Icon(Icons.content_paste),
                onPressed: _quickPaste,
                tooltip: AppStrings.tr('quick_paste'),
              ),
              errorText: _errorMessage,
            ),
            textAlignVertical: TextAlignVertical.center,
            keyboardType: platform.requiresPhoneNumber
                ? TextInputType.phone
                : platform.requiresEmail
                    ? TextInputType.emailAddress
                    : TextInputType.text,
            onSubmitted: (_) => _launchChat(),
          ),
          const SizedBox(height: 20),
          _TappableScale(
            onTap: _launchChat,
            child: Container(
              height: 56,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: platform.gradientColors,
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: platform.color.withValues(alpha: 0.4),
                    blurRadius: 14,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _getPlatformIcon(platform, true),
                  const SizedBox(width: 12),
                  Text(
                    AppStrings.tr(
                      'open_platform',
                      args: [platform.displayName],
                    ),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.5,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    ).animate().fadeIn(duration: 400.ms, delay: 300.ms);
  }

  /// Utilities panel — shown when the Utilities category tab is active.
  Widget _buildUtilitiesPanel() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        GlassmorphicContainer.flat(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  gradient: AppTheme.primaryGradientFor(context),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.auto_awesome_rounded,
                  color: Colors.white,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      AppStrings.tr('utilities'),
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      AppStrings.tr('utils_subtitle'),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Theme.of(context)
                                .colorScheme
                                .onSurface
                                .withValues(alpha: 0.65),
                          ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ).animate().fadeIn(duration: 350.ms, delay: 130.ms),
        const SizedBox(height: 14),
        RepaintBoundary(
          child: LayoutBuilder(
            builder: (context, constraints) {
              final cardWidth = (constraints.maxWidth - 12) / 2;
              return Wrap(
                spacing: 12,
                runSpacing: 12,
                children: [
                  SizedBox(
                    width: cardWidth,
                    child: _UtilityShortcutCard(
                      icon: Icons.qr_code_2,
                      label: AppStrings.tr('qr_generator'),
                      gradient: AppTheme.primaryGradientFor(context),
                      onTap: () {
                        HapticFeedback.lightImpact();
                        context.push(AppRouter.utils);
                      },
                    ),
                  ),
                  SizedBox(
                    width: cardWidth,
                    child: _UtilityShortcutCard(
                      icon: Icons.link_off,
                      label: AppStrings.tr('link_cleaner'),
                      gradient: AppTheme.accentGradientFor(context),
                      onTap: () {
                        HapticFeedback.lightImpact();
                        context.push(AppRouter.utils, extra: 1);
                      },
                    ),
                  ),
                  SizedBox(
                    width: cardWidth,
                    child: _UtilityShortcutCard(
                      icon: Icons.bookmarks_outlined,
                      label: AppStrings.tr('templates'),
                      gradient: LinearGradient(
                        colors: [
                          Theme.of(context).colorScheme.secondary,
                          Theme.of(context).colorScheme.tertiary,
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      onTap: () {
                        HapticFeedback.lightImpact();
                        context.push(AppRouter.utils, extra: 2);
                      },
                    ),
                  ),
                  SizedBox(
                    width: cardWidth,
                    child: _UtilityShortcutCard(
                      icon: Icons.password_rounded,
                      label: AppStrings.tr('password_generator'),
                      gradient: LinearGradient(
                        colors: [
                          Theme.of(context).colorScheme.primary,
                          Theme.of(context).colorScheme.secondary,
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      onTap: () {
                        HapticFeedback.lightImpact();
                        context.push(AppRouter.utils, extra: 3);
                      },
                    ),
                  ),
                  SizedBox(
                    width: cardWidth,
                    child: _UtilityShortcutCard(
                      icon: Icons.email_outlined,
                      label: AppStrings.tr('gmail_sender'),
                      gradient: LinearGradient(
                        colors: [
                          Theme.of(context).colorScheme.tertiary,
                          Theme.of(context).colorScheme.secondary,
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      onTap: () {
                        HapticFeedback.lightImpact();
                        context.push(AppRouter.utils, extra: 4);
                      },
                    ),
                  ),
                  SizedBox(
                    width: cardWidth,
                    child: _UtilityShortcutCard(
                      icon: Icons.lock_person_rounded,
                      label: AppStrings.tr('security_toolkit'),
                      gradient: LinearGradient(
                        colors: [
                          Theme.of(context).colorScheme.primary,
                          Theme.of(context).colorScheme.tertiary,
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      onTap: () {
                        HapticFeedback.lightImpact();
                        context.push(AppRouter.utils, extra: 5);
                      },
                    ),
                  ),
                ],
              );
            },
          ),
        ).animate().fadeIn(duration: 400.ms, delay: 200.ms),
      ],
    );
  }

  // ── Icon helpers ──────────────────────────────────────────────────────────

  /// Icon for platform grid tiles and the launch button (28 dp).
  /// Always tinted to prevent SVG background artifacts.
  Widget _getPlatformIcon(PlatformType platform, bool isSelected) {
    final name = _svgNameFor(platform);
    if (name != null) {
      return BrandIcon(
        iconName: name,
        color: isSelected ? Colors.white : platform.color,
      );
    }
    return Icon(
      platform.icon,
      color: isSelected ? Colors.white : platform.color,
      size: 28,
    );
  }

  /// Small icon for recent-contacts chips (20 dp).
  Widget _buildSmallPlatformIcon(PlatformType platform, bool isSelected) {
    final name = _svgNameFor(platform);
    if (name != null) {
      return BrandIcon(
        iconName: name,
        size: 18,
        color: isSelected ? Colors.white : platform.color,
      );
    }
    return Icon(
      platform.icon,
      color: isSelected ? Colors.white : platform.color,
      size: 18,
    );
  }

  /// Properly padded 24 dp icon for [InputDecoration.prefixIcon].
  Widget _buildPrefixIcon(PlatformType platform) {
    final name = _svgNameFor(platform);
    if (name != null) {
      return BrandIcon.asInputIcon(iconName: name, color: platform.color);
    }
    return Icon(platform.icon, color: platform.color);
  }

  /// Returns the SVG bundle asset name for a platform, or null if the
  /// platform uses a Material icon instead.
  static String? _svgNameFor(PlatformType platform) {
    return platform.logoAssetName;
  }
}

// ── Smart Clipboard Banner ────────────────────────────────────────────────────

/// Dynamic Island-style floating pill that appears at the top of the screen
/// when the clipboard contains content relevant to the selected platform.
/// A single [BackdropFilter] gives it depth without stacking blur layers.
class _SmartClipboardBanner extends StatelessWidget {
  final String content;
  final VoidCallback onUse;
  final VoidCallback onDismiss;

  const _SmartClipboardBanner({
    required this.content,
    required this.onUse,
    required this.onDismiss,
  });

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).colorScheme.primary;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(32),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: primary.withValues(alpha: 0.14),
              borderRadius: BorderRadius.circular(32),
              border: Border.all(
                color: primary.withValues(alpha: 0.28),
              ),
            ),
            child: Row(
              children: [
                // Gradient paste icon
                Container(
                  width: 30,
                  height: 30,
                  decoration: BoxDecoration(
                    gradient: AppTheme.accentGradientFor(context),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.content_paste_rounded,
                    color: Colors.white,
                    size: 16,
                  ),
                ),
                const SizedBox(width: 10),
                // Clipboard content preview
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        AppStrings.tr('smart_paste'),
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                          color: primary.withValues(alpha: 0.8),
                          letterSpacing: 0.3,
                        ),
                      ),
                      Text(
                        content,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              fontWeight: FontWeight.w500,
                            ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                // "Use" action
                TextButton(
                  onPressed: onUse,
                  style: TextButton.styleFrom(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    minimumSize: Size.zero,
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    foregroundColor: primary,
                  ),
                  child: Text(
                    AppStrings.tr('use'),
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                    ),
                  ),
                ),
                // Dismiss
                GestureDetector(
                  onTap: onDismiss,
                  child: Icon(
                    Icons.close_rounded,
                    size: 18,
                    color: Theme.of(context)
                        .colorScheme
                        .onSurface
                        .withValues(alpha: 0.5),
                  ),
                ),
                const SizedBox(width: 4),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ── Press-scale wrapper ───────────────────────────────────────────────────────

class _TappableScale extends StatefulWidget {
  final Widget child;
  final VoidCallback? onTap;

  const _TappableScale({required this.child, this.onTap});

  @override
  State<_TappableScale> createState() => _TappableScaleState();
}

class _TappableScaleState extends State<_TappableScale> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _pressed = true),
      onTapUp: (_) {
        setState(() => _pressed = false);
        widget.onTap?.call();
      },
      onTapCancel: () => setState(() => _pressed = false),
      child: AnimatedScale(
        scale: _pressed ? 0.93 : 1.0,
        duration: const Duration(milliseconds: 100),
        curve: Curves.easeInOut,
        child: widget.child,
      ),
    );
  }
}

// ── Private const widgets ─────────────────────────────────────────────────────

class _AppTitle extends StatelessWidget {
  const _AppTitle();

  @override
  Widget build(BuildContext context) {
    return Text(
      AppStrings.tr('app_name'),
      style: Theme.of(context).textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.bold,
            letterSpacing: 1.2,
          ),
    );
  }
}

class _InfoCard extends StatelessWidget {
  const _InfoCard();

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: GlassmorphicContainer(
        padding: const EdgeInsets.all(16),
        opacity: 0.05,
        child: Row(
          children: [
            Icon(
              Icons.shield_outlined,
              color: Theme.of(context).colorScheme.primary,
              size: 24,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                AppStrings.tr('privacy_first'),
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ),
          ],
        ),
      ).animate().fadeIn(duration: 400.ms, delay: 500.ms),
    );
  }
}

/// Shortcut card for a utility tool inside the Utilities tab panel.
class _UtilityShortcutCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final LinearGradient gradient;
  final VoidCallback onTap;

  const _UtilityShortcutCard({
    required this.icon,
    required this.label,
    required this.gradient,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GlassmorphicContainer.flat(
      padding: EdgeInsets.zero,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  gradient: gradient,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: Colors.white, size: 22),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  label,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        fontWeight: FontWeight.w700,
                        height: 1.2,
                      ),
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Icon(
                Icons.chevron_right_rounded,
                size: 20,
                color: Theme.of(context)
                    .colorScheme
                    .onSurface
                    .withValues(alpha: 0.5),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Static gradient background. Stateless → raster-cached permanently.
class _CyberBackground extends StatelessWidget {
  const _CyberBackground();

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final scheme = Theme.of(context).colorScheme;

    final darkMiddle = Color.lerp(Colors.black, scheme.primary, 0.16)!;
    final darkEnd = Color.lerp(Colors.black, scheme.secondary, 0.12)!;

    final lightMiddle =
        Color.lerp(scheme.surface, scheme.primaryContainer, 0.7)!;
    final lightEnd =
        Color.lerp(scheme.surface, scheme.secondaryContainer, 0.65)!;

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: isDark
              ? [
                  Colors.black,
                  darkMiddle,
                  darkEnd,
                ]
              : [
                  scheme.surface,
                  lightMiddle,
                  lightEnd,
                ],
        ),
      ),
    );
  }
}
