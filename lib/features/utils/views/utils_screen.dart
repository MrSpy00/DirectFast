import 'dart:async';
import 'dart:convert';
import 'dart:math' as math;
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:share_plus/share_plus.dart';
import 'package:gal/gal.dart';
import 'package:encrypt/encrypt.dart' as encrypt_lib;
import 'package:crypto/crypto.dart';
import 'package:flutter/rendering.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../core/constants/app_constants.dart';
import '../../../shared/constants/app_strings.dart';
import '../../../shared/widgets/glassmorphic_container.dart';
import '../../../shared/theme/app_theme.dart';
import '../../../core/services/locale_service.dart';
import '../viewmodels/templates_viewmodel.dart';
import '../../../data/models/template_item.dart';

// ── Screen ────────────────────────────────────────────────────────────────────

class UtilsScreen extends ConsumerStatefulWidget {
  final int initialTab;
  const UtilsScreen({super.key, this.initialTab = 0});

  @override
  ConsumerState<UtilsScreen> createState() => _UtilsScreenState();
}

class _UtilsScreenState extends ConsumerState<UtilsScreen> {
  late final PageController _pageController;
  late final ScrollController _segmentScrollController;
  late final List<GlobalKey> _segmentKeys;
  int _currentPage = 0;

  static const _segments = [
    _Segment(icon: Icons.qr_code_2_rounded, labelKey: 'tab_qr'),
    _Segment(icon: Icons.link_off_rounded, labelKey: 'tab_links'),
    _Segment(icon: Icons.bookmarks_outlined, labelKey: 'tab_templates'),
    _Segment(icon: Icons.email_outlined, labelKey: 'tab_gmail'),
    _Segment(icon: Icons.security_rounded, labelKey: 'tab_security'),
  ];

  @override
  void initState() {
    super.initState();
    _currentPage = widget.initialTab.clamp(0, _segments.length - 1);
    _pageController = PageController(initialPage: _currentPage);
    _segmentScrollController = ScrollController();
    _segmentKeys = List<GlobalKey>.generate(
      _segments.length,
      (_) => GlobalKey(),
    );
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _ensureCurrentSegmentVisible(_currentPage, animate: false);
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    _segmentScrollController.dispose();
    super.dispose();
  }

  void _ensureCurrentSegmentVisible(int index, {bool animate = true}) {
    if (index < 0 || index >= _segmentKeys.length) {
      return;
    }
    final targetContext = _segmentKeys[index].currentContext;
    if (targetContext == null) {
      return;
    }
    Scrollable.ensureVisible(
      targetContext,
      alignment: 0.5,
      duration: animate ? const Duration(milliseconds: 260) : Duration.zero,
      curve: Curves.easeOutCubic,
    );
  }

  void _onSegmentTap(int index) {
    if (index == _currentPage) {
      return;
    }
    HapticFeedback.lightImpact();
    _pageController.animateToPage(
      index,
      duration: const Duration(milliseconds: 380),
      curve: Curves.easeInOutCubic,
    );
    _ensureCurrentSegmentVisible(index);
  }

  void _jumpToAdjacentSegment(int delta) {
    final target = (_currentPage + delta).clamp(0, _segments.length - 1);
    if (target == _currentPage) {
      return;
    }
    _onSegmentTap(target);
  }

  @override
  Widget build(BuildContext context) {
    ref.watch(localeProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: isDark
              ? AppTheme.darkGradientFor(context)
              : LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Theme.of(context).colorScheme.surface,
                    Theme.of(context).colorScheme.surfaceContainerHighest,
                  ],
                ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              _buildHeader(),
              const SizedBox(height: 4),
              _buildSegmentedControl(),
              const SizedBox(height: 16),
              Expanded(
                child: PageView(
                  controller: _pageController,
                  physics: const BouncingScrollPhysics(),
                  onPageChanged: (i) {
                    setState(() => _currentPage = i);
                    _ensureCurrentSegmentVisible(i);
                  },
                  children: const [
                    _QRGeneratorPage(),
                    _LinkCleanerPage(),
                    _TemplatesPage(),
                    _GmailComposerPage(),
                    _SecurityToolkitPage(),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 12, 20, 0),
      child: Row(
        children: [
          // Pill-shaped back button
          Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () {
                HapticFeedback.lightImpact();
                context.pop();
              },
              borderRadius: BorderRadius.circular(24),
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                decoration: BoxDecoration(
                  color: Theme.of(context)
                      .colorScheme
                      .surfaceContainerHighest
                      .withValues(alpha: 0.6),
                  borderRadius: BorderRadius.circular(24),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.arrow_back_ios_new_rounded,
                      size: 16,
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ShaderMask(
                  shaderCallback: (bounds) =>
                      AppTheme.primaryGradientFor(context).createShader(bounds),
                  child: Text(
                    AppStrings.tr('utilities'),
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                  ),
                ),
                Text(
                  AppStrings.tr('utils_subtitle'),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(context)
                            .colorScheme
                            .onSurface
                            .withValues(alpha: 0.55),
                        letterSpacing: 0.3,
                      ),
                ),
              ],
            ),
          ),
        ],
      ).animate().fadeIn(duration: 350.ms).slideX(begin: -0.15, end: 0),
    );
  }

  Widget _buildSegmentedControl() {
    final colorScheme = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.bolt_rounded,
                size: 18,
                color: colorScheme.primary,
              ),
              const SizedBox(width: 8),
              Text(
                AppStrings.tr('quick_switch'),
                style: Theme.of(context).textTheme.labelLarge?.copyWith(
                      fontWeight: FontWeight.w800,
                      color: colorScheme.onSurface.withValues(alpha: 0.78),
                    ),
              ),
              const Spacer(),
              Text(
                '${_currentPage + 1}/${_segments.length}',
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      color:
                          colorScheme.onSurfaceVariant.withValues(alpha: 0.72),
                      fontWeight: FontWeight.w700,
                    ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color:
                  colorScheme.surfaceContainerHighest.withValues(alpha: 0.48),
              borderRadius: BorderRadius.circular(18),
              border: Border.all(
                color: colorScheme.outline.withValues(alpha: 0.16),
              ),
            ),
            child: Row(
              children: [
                _QuickNavButton(
                  icon: Icons.chevron_left_rounded,
                  enabled: _currentPage > 0,
                  onTap: () => _jumpToAdjacentSegment(-1),
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: SizedBox(
                    height: 48,
                    child: ListView.separated(
                      controller: _segmentScrollController,
                      scrollDirection: Axis.horizontal,
                      physics: const BouncingScrollPhysics(),
                      padding: const EdgeInsets.symmetric(horizontal: 4),
                      itemCount: _segments.length,
                      separatorBuilder: (_, __) => const SizedBox(width: 8),
                      itemBuilder: (context, index) {
                        final segment = _segments[index];
                        return _SegmentPill(
                          key: _segmentKeys[index],
                          icon: segment.icon,
                          label: AppStrings.tr(segment.labelKey),
                          isSelected: _currentPage == index,
                          onTap: () => _onSegmentTap(index),
                        );
                      },
                    ),
                  ),
                ),
                const SizedBox(width: 6),
                _QuickNavButton(
                  icon: Icons.chevron_right_rounded,
                  enabled: _currentPage < _segments.length - 1,
                  onTap: () => _jumpToAdjacentSegment(1),
                ),
              ],
            ),
          ),
        ],
      ),
    ).animate().fadeIn(duration: 350.ms, delay: 80.ms);
  }
}

// ── Premium Segmented Control ─────────────────────────────────────────────────

class _Segment {
  final IconData icon;
  final String labelKey;
  const _Segment({required this.icon, required this.labelKey});
}

class _SegmentPill extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _SegmentPill({
    required this.icon,
    required this.label,
    required this.isSelected,
    required this.onTap,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final onSurface = Theme.of(context).colorScheme.onSurface;
    final onSurfaceVariant = Theme.of(context).colorScheme.onSurfaceVariant;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(13),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 220),
          curve: Curves.easeOutCubic,
          constraints: const BoxConstraints(minWidth: 106, maxWidth: 150),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
          decoration: BoxDecoration(
            gradient: isSelected ? AppTheme.primaryGradientFor(context) : null,
            color: isSelected
                ? null
                : Theme.of(context).colorScheme.surface.withValues(alpha: 0.85),
            borderRadius: BorderRadius.circular(13),
            border: Border.all(
              color: isSelected
                  ? Theme.of(context).colorScheme.primary.withValues(alpha: 0.5)
                  : Theme.of(context)
                      .colorScheme
                      .outline
                      .withValues(alpha: 0.2),
            ),
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: Theme.of(context)
                          .colorScheme
                          .primary
                          .withValues(alpha: 0.24),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ]
                : null,
          ),
          child: Row(
            children: [
              Icon(
                icon,
                size: 16,
                color: isSelected
                    ? Colors.white
                    : onSurfaceVariant.withValues(alpha: 0.86),
              ),
              const SizedBox(width: 7),
              Flexible(
                child: Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: isSelected ? FontWeight.w700 : FontWeight.w600,
                    color: isSelected
                        ? Colors.white
                        : onSurface.withValues(alpha: 0.9),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _QuickNavButton extends StatelessWidget {
  final IconData icon;
  final bool enabled;
  final VoidCallback onTap;

  const _QuickNavButton({
    required this.icon,
    required this.enabled,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedOpacity(
      duration: const Duration(milliseconds: 180),
      opacity: enabled ? 1 : 0.35,
      child: Material(
        color: Theme.of(context).colorScheme.surface.withValues(alpha: 0.7),
        borderRadius: BorderRadius.circular(12),
        child: InkWell(
          onTap: enabled ? onTap : null,
          borderRadius: BorderRadius.circular(12),
          child: SizedBox(
            width: 34,
            height: 34,
            child: Icon(
              icon,
              size: 20,
              color: Theme.of(context)
                  .colorScheme
                  .onSurface
                  .withValues(alpha: 0.8),
            ),
          ),
        ),
      ),
    );
  }
}

enum _QrCenterImageSource {
  none,
  appLogo,
  custom,
}

enum _QrPayloadType {
  raw,
  url,
  email,
  phone,
  sms,
  wifi,
  vcard,
  geo,
}

class _QrStylePreset {
  final String id;
  final String labelKey;
  final Color foreground;
  final Color background;
  final QrEyeShape eyeShape;
  final QrDataModuleShape moduleShape;
  final int errorLevel;
  final bool gapless;
  final double padding;
  final double cornerRadius;
  final Color frameColor;
  final double frameWidth;
  final double shadowBlur;

  const _QrStylePreset({
    required this.id,
    required this.labelKey,
    required this.foreground,
    required this.background,
    required this.eyeShape,
    required this.moduleShape,
    required this.errorLevel,
    required this.gapless,
    required this.padding,
    required this.cornerRadius,
    required this.frameColor,
    required this.frameWidth,
    required this.shadowBlur,
  });
}

// ── QR Generator Page ─────────────────────────────────────────────────────────

class _QRGeneratorPage extends StatefulWidget {
  const _QRGeneratorPage();

  @override
  State<_QRGeneratorPage> createState() => _QRGeneratorPageState();
}

class _QRGeneratorPageState extends State<_QRGeneratorPage> {
  final TextEditingController _textController = TextEditingController();
  final GlobalKey _qrKey = GlobalKey();
  final ImagePicker _imagePicker = ImagePicker();
  String _qrData = 'https://github.com/MrSpy00/DirectFast';
  Color _fgColor = Colors.black;
  Color _bgColor = Colors.white;
  double _qrSize = 220;
  double _qrPadding = 16;
  double _logoScale = 0.18;
  double _exportPixelRatio = 4.0;
  double _cornerRadius = 14;
  double _frameWidth = 0;
  double _frameShadow = 0;
  bool _gapless = true;
  bool _isPickingCenterImage = false;
  Color _frameColor = Colors.black;
  String _activePresetId = 'qr_preset_classic';
  _QrCenterImageSource _centerImageSource = _QrCenterImageSource.none;
  Uint8List? _customCenterImageBytes;
  QrEyeShape _eyeShape = QrEyeShape.square;
  QrDataModuleShape _moduleShape = QrDataModuleShape.square;
  int _errorLevel = QrErrorCorrectLevel.H;

  static const List<Color> _colorPresets = [
    Colors.black,
    Colors.white,
    Color(0xFF6750A4),
    Color(0xFF1565C0),
    Color(0xFF00695C),
    Color(0xFFC62828),
    Color(0xFFE65100),
  ];

  static const List<_QrStylePreset> _stylePresets = [
    _QrStylePreset(
      id: 'qr_preset_classic',
      labelKey: 'qr_preset_classic',
      foreground: Colors.black,
      background: Colors.white,
      eyeShape: QrEyeShape.square,
      moduleShape: QrDataModuleShape.square,
      errorLevel: QrErrorCorrectLevel.H,
      gapless: true,
      padding: 16,
      cornerRadius: 14,
      frameColor: Colors.black,
      frameWidth: 0,
      shadowBlur: 0,
    ),
    _QrStylePreset(
      id: 'qr_preset_modern',
      labelKey: 'qr_preset_modern',
      foreground: Color(0xFF1E293B),
      background: Color(0xFFF8FAFC),
      eyeShape: QrEyeShape.circle,
      moduleShape: QrDataModuleShape.square,
      errorLevel: QrErrorCorrectLevel.Q,
      gapless: true,
      padding: 18,
      cornerRadius: 18,
      frameColor: Color(0xFF334155),
      frameWidth: 1.5,
      shadowBlur: 8,
    ),
    _QrStylePreset(
      id: 'qr_preset_midnight',
      labelKey: 'qr_preset_midnight',
      foreground: Color(0xFFE2E8F0),
      background: Color(0xFF0F172A),
      eyeShape: QrEyeShape.square,
      moduleShape: QrDataModuleShape.circle,
      errorLevel: QrErrorCorrectLevel.H,
      gapless: true,
      padding: 20,
      cornerRadius: 20,
      frameColor: Color(0xFF1D4ED8),
      frameWidth: 2,
      shadowBlur: 10,
    ),
    _QrStylePreset(
      id: 'qr_preset_ocean',
      labelKey: 'qr_preset_ocean',
      foreground: Color(0xFF0A66C2),
      background: Color(0xFFF4FAFF),
      eyeShape: QrEyeShape.circle,
      moduleShape: QrDataModuleShape.circle,
      errorLevel: QrErrorCorrectLevel.Q,
      gapless: true,
      padding: 16,
      cornerRadius: 16,
      frameColor: Color(0xFF7CC4FF),
      frameWidth: 1,
      shadowBlur: 6,
    ),
    _QrStylePreset(
      id: 'qr_preset_neon',
      labelKey: 'qr_preset_neon',
      foreground: Color(0xFF39FF14),
      background: Color(0xFF050505),
      eyeShape: QrEyeShape.square,
      moduleShape: QrDataModuleShape.square,
      errorLevel: QrErrorCorrectLevel.H,
      gapless: false,
      padding: 18,
      cornerRadius: 12,
      frameColor: Color(0xFF39FF14),
      frameWidth: 2,
      shadowBlur: 14,
    ),
  ];

  static const Map<String, String> _payloadTemplates = {
    'qr_template_url': 'https://example.com',
    'qr_template_email': 'mailto:hello@example.com',
    'qr_template_phone': 'tel:+905551112233',
    'qr_template_sms': 'sms:+905551112233?body=Merhaba',
    'qr_template_wifi': 'WIFI:T:WPA;S:DirectFast;P:supersecret123;;',
  };

  void _markPresetAsCustom() {
    _activePresetId = 'qr_preset_custom';
  }

  void _applyPreset(_QrStylePreset preset) {
    HapticFeedback.selectionClick();
    setState(() {
      _activePresetId = preset.id;
      _fgColor = preset.foreground;
      _bgColor = preset.background;
      _eyeShape = preset.eyeShape;
      _moduleShape = preset.moduleShape;
      _errorLevel = preset.errorLevel;
      _gapless = preset.gapless;
      _qrPadding = preset.padding;
      _cornerRadius = preset.cornerRadius;
      _frameColor = preset.frameColor;
      _frameWidth = preset.frameWidth;
      _frameShadow = preset.shadowBlur;
    });
  }

  void _onForegroundColorChanged(Color color) {
    setState(() {
      _fgColor = color;
      _markPresetAsCustom();
    });
  }

  void _onBackgroundColorChanged(Color color) {
    setState(() {
      _bgColor = color;
      _markPresetAsCustom();
    });
  }

  void _onFrameColorChanged(Color color) {
    setState(() {
      _frameColor = color;
      _markPresetAsCustom();
    });
  }

  void _swapColors() {
    HapticFeedback.selectionClick();
    setState(() {
      final previousForeground = _fgColor;
      _fgColor = _bgColor;
      _bgColor = previousForeground;
      _markPresetAsCustom();
    });
  }

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  void _generateQR() {
    final text = _textController.text.trim();
    if (text.isNotEmpty) {
      if (text.length > 1800) {
        _showSnackBar(
          context,
          AppStrings.tr('qr_data_too_long'),
          isError: true,
        );
        return;
      }
      HapticFeedback.lightImpact();
      setState(() => _qrData = text);
    }
  }

  void _copyPayload() {
    HapticFeedback.lightImpact();
    Clipboard.setData(ClipboardData(text: _qrData));
    _showSnackBar(context, AppStrings.tr('qr_payload_copied'));
  }

  void _clearInput() {
    HapticFeedback.selectionClick();
    _textController.clear();
  }

  void _resetStyle() {
    HapticFeedback.selectionClick();
    setState(() {
      _fgColor = Colors.black;
      _bgColor = Colors.white;
      _qrSize = 220;
      _qrPadding = 16;
      _logoScale = 0.18;
      _exportPixelRatio = 4.0;
      _cornerRadius = 14;
      _frameWidth = 0;
      _frameShadow = 0;
      _frameColor = Colors.black;
      _gapless = true;
      _isPickingCenterImage = false;
      _activePresetId = 'qr_preset_classic';
      _centerImageSource = _QrCenterImageSource.none;
      _customCenterImageBytes = null;
      _eyeShape = QrEyeShape.square;
      _moduleShape = QrDataModuleShape.square;
      _errorLevel = QrErrorCorrectLevel.H;
    });
  }

  ImageProvider<Object>? _embeddedImageProvider() {
    switch (_centerImageSource) {
      case _QrCenterImageSource.appLogo:
        return const AssetImage('assets/images/logo.png');
      case _QrCenterImageSource.custom:
        if (_customCenterImageBytes == null) {
          return null;
        }
        return MemoryImage(_customCenterImageBytes!);
      case _QrCenterImageSource.none:
        return null;
    }
  }

  Future<void> _pickCenterImage({
    ImageSource source = ImageSource.gallery,
  }) async {
    if (_isPickingCenterImage) {
      return;
    }

    setState(() => _isPickingCenterImage = true);
    try {
      final file = await _imagePicker.pickImage(
        source: source,
        imageQuality: 95,
        maxWidth: 1200,
        maxHeight: 1200,
      );

      if (file == null) {
        if (mounted) {
          _showSnackBar(context, AppStrings.tr('qr_image_pick_cancelled'));
        }
        return;
      }

      final bytes = await file.readAsBytes();
      if (bytes.isEmpty) {
        if (mounted) {
          _showSnackBar(
            context,
            AppStrings.tr('qr_image_pick_failed'),
            isError: true,
          );
        }
        return;
      }

      if (!mounted) {
        return;
      }
      setState(() {
        _customCenterImageBytes = bytes;
        _centerImageSource = _QrCenterImageSource.custom;
      });
      _showSnackBar(context, AppStrings.tr('qr_image_selected'));
    } catch (e) {
      if (mounted) {
        _showSnackBar(
          context,
          '${AppStrings.tr('qr_image_pick_failed')}: $e',
          isError: true,
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isPickingCenterImage = false);
      }
    }
  }

  Future<void> _showCenterImageSourcePicker() async {
    await showModalBottomSheet<void>(
      context: context,
      useSafeArea: true,
      showDragHandle: true,
      builder: (sheetContext) {
        return Padding(
          padding: const EdgeInsets.fromLTRB(18, 6, 18, 18),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                AppStrings.tr('qr_pick_source'),
                style: Theme.of(sheetContext).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
              ),
              const SizedBox(height: 10),
              FilledButton.icon(
                onPressed: () {
                  Navigator.of(sheetContext).pop();
                  _pickCenterImage();
                },
                icon: const Icon(Icons.photo_library_outlined),
                label: Text(AppStrings.tr('qr_pick_gallery')),
              ),
              const SizedBox(height: 8),
              OutlinedButton.icon(
                onPressed: () {
                  Navigator.of(sheetContext).pop();
                  _pickCenterImage(source: ImageSource.camera);
                },
                icon: const Icon(Icons.photo_camera_outlined),
                label: Text(AppStrings.tr('qr_pick_camera')),
              ),
            ],
          ),
        );
      },
    );
  }

  void _setCenterImageSource(_QrCenterImageSource source) {
    HapticFeedback.selectionClick();
    if (source == _QrCenterImageSource.custom &&
        _customCenterImageBytes == null) {
      _showCenterImageSourcePicker();
      return;
    }

    setState(() => _centerImageSource = source);
  }

  void _removeCustomCenterImage() {
    HapticFeedback.selectionClick();
    setState(() {
      _customCenterImageBytes = null;
      if (_centerImageSource == _QrCenterImageSource.custom) {
        _centerImageSource = _QrCenterImageSource.none;
      }
    });
  }

  String _payloadTypeLabelKey(_QrPayloadType type) {
    switch (type) {
      case _QrPayloadType.raw:
        return 'qr_payload_raw';
      case _QrPayloadType.url:
        return 'qr_payload_url';
      case _QrPayloadType.email:
        return 'qr_payload_email';
      case _QrPayloadType.phone:
        return 'qr_payload_phone';
      case _QrPayloadType.sms:
        return 'qr_payload_sms';
      case _QrPayloadType.wifi:
        return 'qr_payload_wifi';
      case _QrPayloadType.vcard:
        return 'qr_payload_vcard';
      case _QrPayloadType.geo:
        return 'qr_payload_geo';
    }
  }

  String _buildPayload({
    required _QrPayloadType type,
    required String primary,
    required String secondary,
    required String tertiary,
  }) {
    switch (type) {
      case _QrPayloadType.raw:
        return primary;
      case _QrPayloadType.url:
        if (primary.startsWith('http://') || primary.startsWith('https://')) {
          return primary;
        }
        return 'https://$primary';
      case _QrPayloadType.email:
        final params = <String, String>{
          if (secondary.isNotEmpty) 'subject': secondary,
          if (tertiary.isNotEmpty) 'body': tertiary,
        };
        final uri = Uri(
          scheme: 'mailto',
          path: primary,
          queryParameters: params.isEmpty ? null : params,
        );
        return uri.toString();
      case _QrPayloadType.phone:
        return 'tel:$primary';
      case _QrPayloadType.sms:
        final body = tertiary.isNotEmpty ? tertiary : secondary;
        if (body.isEmpty) {
          return 'sms:$primary';
        }
        return 'sms:$primary?body=${Uri.encodeComponent(body)}';
      case _QrPayloadType.wifi:
        final authType = tertiary.isEmpty ? 'WPA' : tertiary.toUpperCase();
        return 'WIFI:T:$authType;S:$primary;P:$secondary;;';
      case _QrPayloadType.vcard:
        final buffer = StringBuffer()
          ..writeln('BEGIN:VCARD')
          ..writeln('VERSION:3.0')
          ..writeln('FN:$primary');
        if (secondary.isNotEmpty) {
          buffer.writeln('TEL:$secondary');
        }
        if (tertiary.isNotEmpty) {
          buffer.writeln('EMAIL:$tertiary');
        }
        buffer.write('END:VCARD');
        return buffer.toString();
      case _QrPayloadType.geo:
        return 'geo:$primary,$secondary';
    }
  }

  Future<void> _showPayloadBuilderSheet() async {
    var payloadType = _QrPayloadType.url;
    final primaryController = TextEditingController();
    final secondaryController = TextEditingController();
    final tertiaryController = TextEditingController();

    String payloadPreview() {
      return _buildPayload(
        type: payloadType,
        primary: primaryController.text.trim(),
        secondary: secondaryController.text.trim(),
        tertiary: tertiaryController.text.trim(),
      );
    }

    String primaryHint() {
      switch (payloadType) {
        case _QrPayloadType.raw:
          return AppStrings.tr('enter_text');
        case _QrPayloadType.url:
          return AppStrings.tr('enter_url');
        case _QrPayloadType.email:
          return AppStrings.tr('enter_email');
        case _QrPayloadType.phone:
        case _QrPayloadType.sms:
          return AppStrings.tr('enter_phone');
        case _QrPayloadType.wifi:
          return AppStrings.tr('qr_payload_ssid');
        case _QrPayloadType.vcard:
          return AppStrings.tr('qr_payload_name');
        case _QrPayloadType.geo:
          return AppStrings.tr('qr_payload_latitude');
      }
    }

    String secondaryHint() {
      switch (payloadType) {
        case _QrPayloadType.raw:
        case _QrPayloadType.url:
        case _QrPayloadType.phone:
          return '';
        case _QrPayloadType.email:
          return AppStrings.tr('gmail_subject_label');
        case _QrPayloadType.sms:
          return AppStrings.tr('enter_message');
        case _QrPayloadType.wifi:
          return AppStrings.tr('qr_payload_password');
        case _QrPayloadType.vcard:
          return AppStrings.tr('enter_phone');
        case _QrPayloadType.geo:
          return AppStrings.tr('qr_payload_longitude');
      }
    }

    String tertiaryHint() {
      switch (payloadType) {
        case _QrPayloadType.email:
          return AppStrings.tr('gmail_body_label');
        case _QrPayloadType.wifi:
          return AppStrings.tr('qr_payload_security');
        case _QrPayloadType.vcard:
          return AppStrings.tr('enter_email');
        default:
          return '';
      }
    }

    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      showDragHandle: true,
      builder: (sheetContext) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            final preview = payloadPreview();
            return Padding(
              padding: EdgeInsets.fromLTRB(
                20,
                8,
                20,
                20 + MediaQuery.of(context).viewInsets.bottom,
              ),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      AppStrings.tr('qr_payload_builder'),
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                    ),
                    const SizedBox(height: 10),
                    DropdownButtonFormField<_QrPayloadType>(
                      initialValue: payloadType,
                      decoration: InputDecoration(
                        labelText: AppStrings.tr('qr_payload_type'),
                        prefixIcon: const Icon(Icons.auto_awesome_rounded),
                      ),
                      items: _QrPayloadType.values
                          .map(
                            (type) => DropdownMenuItem<_QrPayloadType>(
                              value: type,
                              child: Text(
                                AppStrings.tr(_payloadTypeLabelKey(type)),
                              ),
                            ),
                          )
                          .toList(),
                      onChanged: (value) {
                        if (value == null) {
                          return;
                        }
                        setModalState(() {
                          payloadType = value;
                        });
                      },
                    ),
                    const SizedBox(height: 10),
                    TextField(
                      controller: primaryController,
                      decoration: InputDecoration(
                        hintText: primaryHint(),
                      ),
                      onChanged: (_) => setModalState(() {}),
                    ),
                    if (secondaryHint().isNotEmpty) ...[
                      const SizedBox(height: 10),
                      TextField(
                        controller: secondaryController,
                        decoration: InputDecoration(
                          hintText: secondaryHint(),
                        ),
                        onChanged: (_) => setModalState(() {}),
                      ),
                    ],
                    if (tertiaryHint().isNotEmpty) ...[
                      const SizedBox(height: 10),
                      TextField(
                        controller: tertiaryController,
                        decoration: InputDecoration(
                          hintText: tertiaryHint(),
                        ),
                        onChanged: (_) => setModalState(() {}),
                      ),
                    ],
                    const SizedBox(height: 12),
                    Text(
                      AppStrings.tr('qr_payload_preview'),
                      style: Theme.of(context).textTheme.labelLarge?.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                    ),
                    const SizedBox(height: 6),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        color: Theme.of(context)
                            .colorScheme
                            .surfaceContainerHighest
                            .withValues(alpha: 0.46),
                      ),
                      child: SelectableText(
                        preview.isEmpty ? '-' : preview,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              fontFamily: 'monospace',
                            ),
                      ),
                    ),
                    const SizedBox(height: 14),
                    FilledButton.icon(
                      onPressed: () {
                        if (preview.trim().isEmpty) {
                          _showSnackBar(
                            context,
                            AppStrings.tr('fill_all_fields'),
                            isError: true,
                          );
                          return;
                        }
                        setState(() {
                          _textController.text = preview;
                          _qrData = preview;
                        });
                        Navigator.of(context).pop();
                        _showSnackBar(
                          this.context,
                          AppStrings.tr('qr_payload_applied'),
                        );
                      },
                      icon: const Icon(Icons.check_rounded),
                      label: Text(AppStrings.tr('qr_payload_apply')),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
    primaryController.dispose();
    secondaryController.dispose();
    tertiaryController.dispose();
  }

  void _applyPayloadTemplate(String key) {
    final value = _payloadTemplates[key];
    if (value == null) {
      return;
    }
    HapticFeedback.selectionClick();
    setState(() {
      _textController.text = value;
      _qrData = value;
    });
  }

  double _contrastRatio() {
    final fg = _fgColor.computeLuminance();
    final bg = _bgColor.computeLuminance();
    final light = math.max(fg, bg);
    final dark = math.min(fg, bg);
    return (light + 0.05) / (dark + 0.05);
  }

  Future<void> _pickColor({
    required Color initialColor,
    required ValueChanged<Color> onPicked,
  }) async {
    var red = (initialColor.r * 255).roundToDouble();
    var green = (initialColor.g * 255).roundToDouble();
    var blue = (initialColor.b * 255).roundToDouble();

    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      showDragHandle: true,
      builder: (sheetContext) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            final pickedColor = Color.fromARGB(
              0xFF,
              red.round(),
              green.round(),
              blue.round(),
            );
            final hex =
                '#${pickedColor.toARGB32().toRadixString(16).padLeft(8, '0').substring(2).toUpperCase()}';

            return Padding(
              padding: EdgeInsets.fromLTRB(
                20,
                10,
                20,
                20 + MediaQuery.of(context).viewInsets.bottom,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    AppStrings.tr('pick_color'),
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 12),
                  Container(
                    height: 62,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: pickedColor,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      hex,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color:
                            ThemeData.estimateBrightnessForColor(pickedColor) ==
                                    Brightness.dark
                                ? Colors.white
                                : Colors.black,
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Slider(
                    value: red,
                    max: 255,
                    activeColor: Colors.red,
                    onChanged: (v) => setModalState(() => red = v),
                  ),
                  Slider(
                    value: green,
                    max: 255,
                    activeColor: Colors.green,
                    onChanged: (v) => setModalState(() => green = v),
                  ),
                  Slider(
                    value: blue,
                    max: 255,
                    activeColor: Colors.blue,
                    onChanged: (v) => setModalState(() => blue = v),
                  ),
                  FilledButton.icon(
                    onPressed: () {
                      onPicked(pickedColor);
                      Navigator.of(context).pop();
                    },
                    icon: const Icon(Icons.check_rounded),
                    label: Text(AppStrings.tr('apply_color')),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Future<void> _shareQR() async {
    await HapticFeedback.lightImpact();
    try {
      final boundary =
          _qrKey.currentContext!.findRenderObject() as RenderRepaintBoundary;
      final image = await boundary.toImage(pixelRatio: _exportPixelRatio);
      final bytes = await image.toByteData(format: ui.ImageByteFormat.png);
      final png = bytes!.buffer.asUint8List();
      await Share.shareXFiles(
        [XFile.fromData(png, mimeType: 'image/png', name: 'qr_code.png')],
        text: AppStrings.tr('qr_generator'),
      );
    } catch (e) {
      if (mounted) {
        _showSnackBar(
          context,
          '${AppStrings.tr('error_sharing')}: $e',
          isError: true,
        );
      }
    }
  }

  Future<void> _saveToGallery() async {
    await HapticFeedback.lightImpact();
    try {
      final boundary =
          _qrKey.currentContext!.findRenderObject() as RenderRepaintBoundary;
      final image = await boundary.toImage(pixelRatio: _exportPixelRatio);
      final bytes = await image.toByteData(format: ui.ImageByteFormat.png);
      final png = bytes!.buffer.asUint8List();
      await Gal.putImageBytes(
        png,
        name: 'directfast_qr_${DateTime.now().millisecondsSinceEpoch}.png',
      );
      if (mounted) {
        _showSnackBar(context, AppStrings.tr('qr_saved'));
      }
    } catch (e) {
      if (mounted) {
        _showSnackBar(
          context,
          '${AppStrings.tr('error_saving')}: $e',
          isError: true,
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final contrast = _contrastRatio();
    final embeddedImageProvider = _embeddedImageProvider();
    final hasCenterImage = embeddedImageProvider != null;
    final levelLabel = switch (_errorLevel) {
      QrErrorCorrectLevel.L => AppStrings.tr('qr_error_level_l'),
      QrErrorCorrectLevel.M => AppStrings.tr('qr_error_level_m'),
      QrErrorCorrectLevel.Q => AppStrings.tr('qr_error_level_q'),
      _ => AppStrings.tr('qr_error_level_h'),
    };

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 4, 20, 24),
      physics: const BouncingScrollPhysics(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          GlassmorphicContainer.flat(
            padding: const EdgeInsets.all(24),
            child: Column(
              children: [
                RepaintBoundary(
                  key: _qrKey,
                  child: Container(
                    decoration: BoxDecoration(
                      color: _bgColor,
                      borderRadius: BorderRadius.circular(_cornerRadius),
                      border: _frameWidth > 0
                          ? Border.all(
                              color: _frameColor,
                              width: _frameWidth,
                            )
                          : null,
                      boxShadow: _frameShadow > 0
                          ? [
                              BoxShadow(
                                color: _frameColor.withValues(alpha: 0.28),
                                blurRadius: _frameShadow,
                                spreadRadius: _frameShadow * 0.08,
                                offset: const Offset(0, 4),
                              ),
                            ]
                          : null,
                    ),
                    padding: EdgeInsets.all(_qrPadding),
                    child: QrImageView(
                      data: _qrData,
                      size: _qrSize,
                      backgroundColor: _bgColor,
                      errorCorrectionLevel: _errorLevel,
                      gapless: _gapless,
                      embeddedImage: embeddedImageProvider,
                      embeddedImageStyle: hasCenterImage
                          ? QrEmbeddedImageStyle(
                              size: Size(
                                _qrSize * _logoScale,
                                _qrSize * _logoScale,
                              ),
                            )
                          : null,
                      eyeStyle: QrEyeStyle(
                        eyeShape: _eyeShape,
                        color: _fgColor,
                      ),
                      dataModuleStyle: QrDataModuleStyle(
                        dataModuleShape: _moduleShape,
                        color: _fgColor,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                _QrColorPicker(
                  title: AppStrings.tr('qr_foreground'),
                  presets: _colorPresets,
                  selected: _fgColor,
                  onSelected: _onForegroundColorChanged,
                  onCustomTap: () async {
                    await _pickColor(
                      initialColor: _fgColor,
                      onPicked: _onForegroundColorChanged,
                    );
                  },
                ),
                const SizedBox(height: 14),
                _QrColorPicker(
                  title: AppStrings.tr('qr_background'),
                  presets: _colorPresets,
                  selected: _bgColor,
                  onSelected: _onBackgroundColorChanged,
                  onCustomTap: () async {
                    await _pickColor(
                      initialColor: _bgColor,
                      onPicked: _onBackgroundColorChanged,
                    );
                  },
                ),
                const SizedBox(height: 10),
                Container(
                  width: double.infinity,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  decoration: BoxDecoration(
                    color: Theme.of(context)
                        .colorScheme
                        .surfaceContainerHighest
                        .withValues(alpha: 0.45),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        contrast >= 3
                            ? Icons.verified_rounded
                            : Icons.warning_amber_rounded,
                        size: 18,
                        color: contrast >= 3
                            ? Colors.lightGreen
                            : Theme.of(context).colorScheme.error,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          AppStrings.tr(
                            contrast >= 3
                                ? 'qr_contrast_good'
                                : 'qr_contrast_low',
                            args: [contrast.toStringAsFixed(2)],
                          ),
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 10),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    OutlinedButton.icon(
                      onPressed: _swapColors,
                      icon: const Icon(Icons.swap_horiz_rounded),
                      label: Text(AppStrings.tr('qr_swap_colors')),
                    ),
                    OutlinedButton.icon(
                      onPressed: _resetStyle,
                      icon: const Icon(Icons.refresh_rounded),
                      label: Text(AppStrings.tr('qr_reset_style')),
                    ),
                  ],
                ),
              ],
            ),
          )
              .animate()
              .fadeIn(duration: 500.ms)
              .scale(begin: const Offset(0.94, 0.94)),
          const SizedBox(height: 16),
          GlassmorphicContainer.flat(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  AppStrings.tr('your_info'),
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _textController,
                  maxLines: 3,
                  minLines: 3,
                  decoration: InputDecoration(
                    hintText: AppStrings.tr('enter_text'),
                  ),
                  textAlignVertical: TextAlignVertical.top,
                  onSubmitted: (_) => _generateQR(),
                ),
                const SizedBox(height: 10),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: _payloadTemplates.keys.map((key) {
                    return ActionChip(
                      avatar: const Icon(Icons.bolt_rounded, size: 16),
                      label: Text(AppStrings.tr(key)),
                      onPressed: () => _applyPayloadTemplate(key),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 10),
                OutlinedButton.icon(
                  onPressed: _showPayloadBuilderSheet,
                  icon: const Icon(Icons.auto_awesome_rounded),
                  label: Text(AppStrings.tr('qr_payload_builder')),
                ),
                const SizedBox(height: 16),
                Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  children: [
                    SizedBox(
                      width: 180,
                      child: _GradientButton(
                        onPressed: _generateQR,
                        icon: Icons.qr_code_scanner_rounded,
                        label: AppStrings.tr('generate'),
                      ),
                    ),
                    SizedBox(
                      width: 150,
                      child: OutlinedButton.icon(
                        onPressed: _copyPayload,
                        icon: const Icon(Icons.copy_rounded),
                        label: Text(AppStrings.tr('copy_payload')),
                      ),
                    ),
                    SizedBox(
                      width: 140,
                      child: OutlinedButton.icon(
                        onPressed: _clearInput,
                        icon: const Icon(Icons.clear_rounded),
                        label: Text(AppStrings.tr('clear')),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ).animate().fadeIn(duration: 500.ms, delay: 100.ms),
          const SizedBox(height: 14),
          GlassmorphicContainer.flat(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  AppStrings.tr('qr_style'),
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                ),
                const SizedBox(height: 8),
                Text(
                  AppStrings.tr('qr_style_presets'),
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(context)
                            .colorScheme
                            .onSurface
                            .withValues(alpha: 0.68),
                      ),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    ..._stylePresets.map(
                      (preset) => ChoiceChip(
                        label: Text(AppStrings.tr(preset.labelKey)),
                        selected: _activePresetId == preset.id,
                        onSelected: (_) => _applyPreset(preset),
                      ),
                    ),
                    ChoiceChip(
                      label: Text(AppStrings.tr('qr_preset_custom')),
                      selected: _activePresetId == 'qr_preset_custom',
                      onSelected: (_) {
                        setState(() {
                          _markPresetAsCustom();
                        });
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: DropdownButtonFormField<int>(
                        initialValue: _errorLevel,
                        decoration: InputDecoration(
                          labelText: AppStrings.tr('qr_error_level'),
                          prefixIcon: const Icon(Icons.security_rounded),
                        ),
                        items: <DropdownMenuItem<int>>[
                          DropdownMenuItem<int>(
                            value: QrErrorCorrectLevel.L,
                            child: Text(AppStrings.tr('qr_error_level_l')),
                          ),
                          DropdownMenuItem<int>(
                            value: QrErrorCorrectLevel.M,
                            child: Text(AppStrings.tr('qr_error_level_m')),
                          ),
                          DropdownMenuItem<int>(
                            value: QrErrorCorrectLevel.Q,
                            child: Text(AppStrings.tr('qr_error_level_q')),
                          ),
                          DropdownMenuItem<int>(
                            value: QrErrorCorrectLevel.H,
                            child: Text(AppStrings.tr('qr_error_level_h')),
                          ),
                        ],
                        onChanged: (value) {
                          if (value != null) {
                            setState(() {
                              _errorLevel = value;
                              _markPresetAsCustom();
                            });
                          }
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  '${AppStrings.tr('qr_size')}: ${_qrSize.round()} px',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
                Slider(
                  value: _qrSize,
                  min: 140,
                  max: 340,
                  divisions: 20,
                  label: _qrSize.round().toString(),
                  onChanged: (value) {
                    setState(() {
                      _qrSize = value;
                      _markPresetAsCustom();
                    });
                  },
                ),
                Text(
                  '${AppStrings.tr('qr_padding')}: ${_qrPadding.round()} px',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
                Slider(
                  value: _qrPadding,
                  max: 36,
                  divisions: 18,
                  label: _qrPadding.round().toString(),
                  onChanged: (value) {
                    setState(() {
                      _qrPadding = value;
                      _markPresetAsCustom();
                    });
                  },
                ),
                Text(
                  '${AppStrings.tr('qr_corner_radius')}: ${_cornerRadius.round()} px',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
                Slider(
                  value: _cornerRadius,
                  max: 32,
                  divisions: 16,
                  label: _cornerRadius.round().toString(),
                  onChanged: (value) {
                    setState(() {
                      _cornerRadius = value;
                      _markPresetAsCustom();
                    });
                  },
                ),
                Text(
                  '${AppStrings.tr('qr_frame_width')}: ${_frameWidth.toStringAsFixed(1)} px',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
                Slider(
                  value: _frameWidth,
                  max: 8,
                  divisions: 16,
                  label: _frameWidth.toStringAsFixed(1),
                  onChanged: (value) {
                    setState(() {
                      _frameWidth = value;
                      _markPresetAsCustom();
                    });
                  },
                ),
                if (_frameWidth > 0) ...[
                  _QrColorPicker(
                    title: AppStrings.tr('qr_frame_color'),
                    presets: _colorPresets,
                    selected: _frameColor,
                    onSelected: _onFrameColorChanged,
                    onCustomTap: () async {
                      await _pickColor(
                        initialColor: _frameColor,
                        onPicked: _onFrameColorChanged,
                      );
                    },
                  ),
                  const SizedBox(height: 10),
                ],
                Text(
                  '${AppStrings.tr('qr_frame_shadow')}: ${_frameShadow.round()}',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
                Slider(
                  value: _frameShadow,
                  max: 24,
                  divisions: 12,
                  label: _frameShadow.round().toString(),
                  onChanged: (value) {
                    setState(() {
                      _frameShadow = value;
                      _markPresetAsCustom();
                    });
                  },
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    ChoiceChip(
                      label: Text(AppStrings.tr('qr_eye_square')),
                      selected: _eyeShape == QrEyeShape.square,
                      onSelected: (_) {
                        setState(() {
                          _eyeShape = QrEyeShape.square;
                          _markPresetAsCustom();
                        });
                      },
                    ),
                    ChoiceChip(
                      label: Text(AppStrings.tr('qr_eye_circle')),
                      selected: _eyeShape == QrEyeShape.circle,
                      onSelected: (_) {
                        setState(() {
                          _eyeShape = QrEyeShape.circle;
                          _markPresetAsCustom();
                        });
                      },
                    ),
                    ChoiceChip(
                      label: Text(AppStrings.tr('qr_data_square')),
                      selected: _moduleShape == QrDataModuleShape.square,
                      onSelected: (_) {
                        setState(() {
                          _moduleShape = QrDataModuleShape.square;
                          _markPresetAsCustom();
                        });
                      },
                    ),
                    ChoiceChip(
                      label: Text(AppStrings.tr('qr_data_circle')),
                      selected: _moduleShape == QrDataModuleShape.circle,
                      onSelected: (_) {
                        setState(() {
                          _moduleShape = QrDataModuleShape.circle;
                          _markPresetAsCustom();
                        });
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                SwitchListTile.adaptive(
                  contentPadding: EdgeInsets.zero,
                  title: Text(AppStrings.tr('qr_smooth')),
                  value: _gapless,
                  onChanged: (value) {
                    setState(() {
                      _gapless = value;
                      _markPresetAsCustom();
                    });
                  },
                ),
                const SizedBox(height: 6),
                Text(
                  AppStrings.tr(
                    'qr_content_length',
                    args: [_qrData.length.toString()],
                  ),
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(context)
                            .colorScheme
                            .onSurface
                            .withValues(alpha: 0.68),
                      ),
                ),
                const SizedBox(height: 10),
                Text(
                  AppStrings.tr('qr_center_image'),
                  style: Theme.of(context).textTheme.labelLarge?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    ChoiceChip(
                      label: Text(AppStrings.tr('qr_center_none')),
                      selected: _centerImageSource == _QrCenterImageSource.none,
                      onSelected: (_) =>
                          _setCenterImageSource(_QrCenterImageSource.none),
                    ),
                    ChoiceChip(
                      label: Text(AppStrings.tr('qr_center_logo')),
                      selected:
                          _centerImageSource == _QrCenterImageSource.appLogo,
                      onSelected: (_) =>
                          _setCenterImageSource(_QrCenterImageSource.appLogo),
                    ),
                    ChoiceChip(
                      label: Text(AppStrings.tr('qr_center_custom')),
                      selected:
                          _centerImageSource == _QrCenterImageSource.custom,
                      onSelected: (_) =>
                          _setCenterImageSource(_QrCenterImageSource.custom),
                    ),
                  ],
                ),
                if (_centerImageSource == _QrCenterImageSource.custom ||
                    _customCenterImageBytes != null) ...[
                  const SizedBox(height: 10),
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Theme.of(context)
                          .colorScheme
                          .surfaceContainerHighest
                          .withValues(alpha: 0.45),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Row(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Container(
                            width: 46,
                            height: 46,
                            color: Theme.of(context)
                                .colorScheme
                                .surface
                                .withValues(alpha: 0.7),
                            child: _customCenterImageBytes != null
                                ? Image.memory(
                                    _customCenterImageBytes!,
                                    fit: BoxFit.cover,
                                  )
                                : Icon(
                                    Icons.image_outlined,
                                    color: Theme.of(context)
                                        .colorScheme
                                        .onSurface
                                        .withValues(alpha: 0.5),
                                  ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            _customCenterImageBytes != null
                                ? AppStrings.tr('qr_image_selected')
                                : AppStrings.tr('qr_no_custom_image'),
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      OutlinedButton.icon(
                        onPressed: _isPickingCenterImage
                            ? null
                            : _showCenterImageSourcePicker,
                        icon: const Icon(Icons.photo_library_outlined),
                        label: Text(
                          _customCenterImageBytes == null
                              ? AppStrings.tr('qr_pick_gallery')
                              : AppStrings.tr('qr_change_image'),
                        ),
                      ),
                      if (_customCenterImageBytes != null)
                        TextButton.icon(
                          onPressed: _removeCustomCenterImage,
                          icon: const Icon(Icons.delete_outline_rounded),
                          label: Text(AppStrings.tr('qr_remove_image')),
                        ),
                    ],
                  ),
                ],
                if (hasCenterImage) ...[
                  Text(
                    '${AppStrings.tr('qr_logo_size')}: ${(_logoScale * 100).round()}%',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                  Slider(
                    value: _logoScale,
                    min: 0.12,
                    max: 0.28,
                    divisions: 16,
                    label: '${(_logoScale * 100).round()}%',
                    onChanged: (value) {
                      setState(() {
                        _logoScale = value;
                        _markPresetAsCustom();
                      });
                    },
                  ),
                  Text(
                    AppStrings.tr('qr_center_image_hint'),
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Theme.of(context)
                              .colorScheme
                              .onSurface
                              .withValues(alpha: 0.64),
                        ),
                  ),
                  const SizedBox(height: 8),
                ],
                Text(
                  '${AppStrings.tr('qr_export_quality')}: x${_exportPixelRatio.toStringAsFixed(1)}',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
                Slider(
                  value: _exportPixelRatio,
                  min: 2.0,
                  max: 6.0,
                  divisions: 8,
                  label: 'x${_exportPixelRatio.toStringAsFixed(1)}',
                  onChanged: (value) {
                    setState(() {
                      _exportPixelRatio = value;
                      _markPresetAsCustom();
                    });
                  },
                ),
                const SizedBox(height: 8),
                Text(
                  '${AppStrings.tr('qr_error_level')}: $levelLabel',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(context)
                            .colorScheme
                            .onSurface
                            .withValues(alpha: 0.65),
                      ),
                ),
              ],
            ),
          ).animate().fadeIn(duration: 500.ms, delay: 150.ms),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: _shareQR,
                  icon: const Icon(Icons.share_rounded),
                  label: Text(AppStrings.tr('share')),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: _saveToGallery,
                  icon: const Icon(Icons.save_alt_rounded),
                  label: Text(AppStrings.tr('save')),
                ),
              ),
            ],
          ).animate().fadeIn(duration: 500.ms, delay: 180.ms),
        ],
      ),
    );
  }
}

/// Row of colour swatches for QR foreground colour.
class _QrColorPicker extends StatelessWidget {
  final String title;
  final List<Color> presets;
  final Color selected;
  final ValueChanged<Color> onSelected;
  final VoidCallback onCustomTap;

  const _QrColorPicker({
    required this.title,
    required this.presets,
    required this.selected,
    required this.onSelected,
    required this.onCustomTap,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Theme.of(context)
                    .colorScheme
                    .onSurface
                    .withValues(alpha: 0.7),
                fontWeight: FontWeight.w600,
              ),
        ),
        const SizedBox(height: 10),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: presets.map((color) {
            final isSelected = color == selected;
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 6),
              child: GestureDetector(
                onTap: () => onSelected(color),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 180),
                  width: isSelected ? 36 : 30,
                  height: isSelected ? 36 : 30,
                  decoration: BoxDecoration(
                    color: color,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: isSelected
                          ? Theme.of(context).colorScheme.primary
                          : Colors.white.withValues(alpha: 0.4),
                      width: isSelected ? 3 : 1.5,
                    ),
                    boxShadow: isSelected
                        ? [
                            BoxShadow(
                              color: color.withValues(alpha: 0.5),
                              blurRadius: 8,
                              spreadRadius: 1,
                            ),
                          ]
                        : null,
                  ),
                ),
              ),
            );
          }).toList(),
        ),
        const SizedBox(height: 10),
        Align(
          alignment: Alignment.centerRight,
          child: OutlinedButton.icon(
            onPressed: onCustomTap,
            icon: const Icon(Icons.colorize_rounded, size: 18),
            label: Text(AppStrings.tr('pick_color')),
          ),
        ),
      ],
    );
  }
}

// ── Link Cleaner Page ─────────────────────────────────────────────────────────

class _LinkCleanerPage extends StatefulWidget {
  const _LinkCleanerPage();

  @override
  State<_LinkCleanerPage> createState() => _LinkCleanerPageState();
}

class _LinkCleanerPageState extends State<_LinkCleanerPage> {
  final TextEditingController _urlController = TextEditingController();
  String? _cleanedUrl;

  static const _trackingParams = [
    'utm_source',
    'utm_medium',
    'utm_campaign',
    'utm_term',
    'utm_content',
    'fbclid',
    'gclid',
    'msclkid',
    'mc_cid',
    'mc_eid',
    '_hsenc',
    '_hsmi',
    'mkt_tok',
    'ref',
    'referrer',
  ];

  @override
  void dispose() {
    _urlController.dispose();
    super.dispose();
  }

  Future<void> _pasteFromClipboard() async {
    await HapticFeedback.lightImpact();
    final data = await Clipboard.getData(Clipboard.kTextPlain);
    if (data?.text != null) {
      _urlController.text = data!.text!;
    }
  }

  void _cleanLink() {
    HapticFeedback.lightImpact();
    final url = _urlController.text.trim();
    if (url.isEmpty) {
      return;
    }

    try {
      final uri = Uri.parse(url);
      if (!uri.hasScheme) {
        throw const FormatException('missing scheme');
      }

      final params = Map<String, List<String>>.from(uri.queryParametersAll);
      for (final p in _trackingParams) {
        params.remove(p);
      }

      final cleaned =
          uri.replace(queryParameters: params.isEmpty ? null : params);
      setState(() => _cleanedUrl = cleaned.toString());

      Clipboard.setData(ClipboardData(text: _cleanedUrl!));
      _showSnackBar(context, AppStrings.tr('link_cleaned'));
    } catch (_) {
      _showSnackBar(context, AppStrings.tr('invalid_url'), isError: true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 4, 20, 24),
      physics: const BouncingScrollPhysics(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          GlassmorphicContainer.flat(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Tool header
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        gradient: AppTheme.accentGradientFor(context),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(
                        Icons.link_off_rounded,
                        color: Colors.white,
                        size: 22,
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            AppStrings.tr('link_cleaner'),
                            style: Theme.of(context)
                                .textTheme
                                .titleMedium
                                ?.copyWith(fontWeight: FontWeight.w700),
                          ),
                          Text(
                            AppStrings.tr('link_cleaner_desc'),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style:
                                Theme.of(context).textTheme.bodySmall?.copyWith(
                                      color: Theme.of(context)
                                          .colorScheme
                                          .onSurface
                                          .withValues(alpha: 0.55),
                                    ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                TextField(
                  controller: _urlController,
                  decoration: InputDecoration(
                    hintText: AppStrings.tr('enter_url'),
                    suffixIcon: IconButton(
                      icon: const Icon(Icons.content_paste_rounded),
                      onPressed: _pasteFromClipboard,
                      tooltip: AppStrings.tr('quick_paste'),
                    ),
                  ),
                  textAlignVertical: TextAlignVertical.top,
                  minLines: 2,
                  maxLines: 2,
                ),
                const SizedBox(height: 16),
                _GradientButton(
                  onPressed: _cleanLink,
                  icon: Icons.auto_fix_high_rounded,
                  label: AppStrings.tr('clean_link'),
                  gradient: AppTheme.accentGradientFor(context),
                ),
              ],
            ),
          ).animate().fadeIn(duration: 500.ms),
          if (_cleanedUrl != null) ...[
            const SizedBox(height: 16),
            GlassmorphicContainer.flat(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.check_circle_rounded,
                        color: Theme.of(context).colorScheme.primary,
                        size: 20,
                      ),
                      const SizedBox(width: 10),
                      Text(
                        AppStrings.tr('cleaned_url'),
                        style: Theme.of(context).textTheme.titleSmall?.copyWith(
                              fontWeight: FontWeight.w700,
                            ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Theme.of(context)
                          .colorScheme
                          .surfaceContainerHighest
                          .withValues(alpha: 0.5),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: SelectableText(
                      _cleanedUrl!,
                      style: Theme.of(context)
                          .textTheme
                          .bodySmall
                          ?.copyWith(fontFamily: 'monospace'),
                    ),
                  ),
                  const SizedBox(height: 12),
                  OutlinedButton.icon(
                    onPressed: () {
                      HapticFeedback.lightImpact();
                      Clipboard.setData(ClipboardData(text: _cleanedUrl!));
                      _showSnackBar(context, AppStrings.tr('clipboard_copied'));
                    },
                    icon: const Icon(Icons.copy_rounded, size: 16),
                    label: Text(AppStrings.tr('copy')),
                  ),
                ],
              ),
            ).animate().fadeIn().slideY(begin: 0.08, end: 0),
          ],
        ],
      ),
    );
  }
}

// ── Password Generator Page ─────────────────────────────────────────────────

class _PasswordGeneratorSection extends StatefulWidget {
  const _PasswordGeneratorSection();

  @override
  State<_PasswordGeneratorSection> createState() =>
      _PasswordGeneratorSectionState();
}

class _PasswordGeneratorSectionState extends State<_PasswordGeneratorSection> {
  late final math.Random _random = _createRandom();

  int _length = 16;
  bool _includeUppercase = true;
  bool _includeLowercase = true;
  bool _includeNumbers = true;
  bool _includeSymbols = true;
  bool _excludeAmbiguous = true;

  String _password = '';
  double _entropyBits = 0;

  static const _uppercase = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ';
  static const _lowercase = 'abcdefghijklmnopqrstuvwxyz';
  static const _numbers = '0123456789';
  static const _symbols = '!@#\$%^&*()-_=+[]{}|;:,.<>?/';

  static math.Random _createRandom() {
    try {
      return math.Random.secure();
    } catch (_) {
      return math.Random();
    }
  }

  @override
  void initState() {
    super.initState();
    _generatePassword(showError: false);
  }

  String _buildCharset() {
    final buffer = StringBuffer();
    if (_includeUppercase) {
      buffer.write(_uppercase);
    }
    if (_includeLowercase) {
      buffer.write(_lowercase);
    }
    if (_includeNumbers) {
      buffer.write(_numbers);
    }
    if (_includeSymbols) {
      buffer.write(_symbols);
    }

    var charset = buffer.toString();
    if (_excludeAmbiguous) {
      charset = charset.replaceAll(RegExp('[O0Il1]'), '');
    }

    return charset;
  }

  String _strengthKey(double entropyBits) {
    if (entropyBits < 40) {
      return 'password_strength_weak';
    }
    if (entropyBits < 56) {
      return 'password_strength_fair';
    }
    if (entropyBits < 72) {
      return 'password_strength_good';
    }
    if (entropyBits < 96) {
      return 'password_strength_strong';
    }
    return 'password_strength_very_strong';
  }

  Color _strengthColor(BuildContext context, double entropyBits) {
    final scheme = Theme.of(context).colorScheme;
    if (entropyBits < 40) {
      return scheme.error;
    }
    if (entropyBits < 56) {
      return Colors.orange;
    }
    if (entropyBits < 72) {
      return Colors.amber;
    }
    if (entropyBits < 96) {
      return Colors.lightGreen;
    }
    return scheme.primary;
  }

  void _updateOptions(VoidCallback update) {
    setState(update);
    _generatePassword(showError: false);
  }

  void _generatePassword({bool showError = true}) {
    final charset = _buildCharset();
    if (charset.isEmpty) {
      setState(() {
        _password = '';
        _entropyBits = 0;
      });
      if (showError) {
        _showSnackBar(
          context,
          AppStrings.tr('at_least_one_charset'),
          isError: true,
        );
      }
      return;
    }

    final chars = charset.split('');
    final out = StringBuffer();
    for (var i = 0; i < _length; i++) {
      out.write(chars[_random.nextInt(chars.length)]);
    }

    final entropy = _length * (math.log(chars.length) / math.ln2);

    setState(() {
      _password = out.toString();
      _entropyBits = entropy;
    });
  }

  void _copyPassword() {
    if (_password.isEmpty) {
      _showSnackBar(
        context,
        AppStrings.tr('at_least_one_charset'),
        isError: true,
      );
      return;
    }
    HapticFeedback.lightImpact();
    Clipboard.setData(ClipboardData(text: _password));
    _showSnackBar(context, AppStrings.tr('password_copied'));
  }

  @override
  Widget build(BuildContext context) {
    final strengthKey = _strengthKey(_entropyBits);
    final strengthColor = _strengthColor(context, _entropyBits);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        GlassmorphicContainer.flat(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      gradient: AppTheme.primaryGradientFor(context),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.password_rounded,
                      color: Colors.white,
                      size: 22,
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          AppStrings.tr('password_generator'),
                          style: Theme.of(context)
                              .textTheme
                              .titleMedium
                              ?.copyWith(fontWeight: FontWeight.w700),
                        ),
                        Text(
                          AppStrings.tr('password_generator_desc'),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style:
                              Theme.of(context).textTheme.bodySmall?.copyWith(
                                    color: Theme.of(context)
                                        .colorScheme
                                        .onSurface
                                        .withValues(alpha: 0.55),
                                  ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 18),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    AppStrings.tr('password_length'),
                    style: Theme.of(context).textTheme.labelLarge?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 5,
                    ),
                    decoration: BoxDecoration(
                      gradient: AppTheme.accentGradientFor(context),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      '$_length',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ],
              ),
              Slider(
                value: _length.toDouble(),
                min: 8,
                max: 64,
                divisions: 56,
                label: '$_length',
                onChanged: (value) {
                  _updateOptions(() => _length = value.round());
                },
              ),
              const SizedBox(height: 6),
              _PasswordOptionTile(
                label: AppStrings.tr('include_uppercase'),
                value: _includeUppercase,
                onChanged: (value) =>
                    _updateOptions(() => _includeUppercase = value),
              ),
              _PasswordOptionTile(
                label: AppStrings.tr('include_lowercase'),
                value: _includeLowercase,
                onChanged: (value) =>
                    _updateOptions(() => _includeLowercase = value),
              ),
              _PasswordOptionTile(
                label: AppStrings.tr('include_numbers'),
                value: _includeNumbers,
                onChanged: (value) =>
                    _updateOptions(() => _includeNumbers = value),
              ),
              _PasswordOptionTile(
                label: AppStrings.tr('include_symbols'),
                value: _includeSymbols,
                onChanged: (value) =>
                    _updateOptions(() => _includeSymbols = value),
              ),
              _PasswordOptionTile(
                label: AppStrings.tr('exclude_ambiguous_chars'),
                value: _excludeAmbiguous,
                onChanged: (value) =>
                    _updateOptions(() => _excludeAmbiguous = value),
              ),
              const SizedBox(height: 14),
              _GradientButton(
                onPressed: () {
                  HapticFeedback.mediumImpact();
                  _generatePassword();
                },
                icon: Icons.casino_rounded,
                label: AppStrings.tr('generate'),
                gradient: AppTheme.primaryGradientFor(context),
              ),
            ],
          ),
        ).animate().fadeIn(duration: 450.ms),
        const SizedBox(height: 14),
        GlassmorphicContainer.flat(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  Text(
                    AppStrings.tr('generated_password'),
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                  ),
                  const Spacer(),
                  Text(
                    AppStrings.tr(strengthKey),
                    style: Theme.of(context).textTheme.labelMedium?.copyWith(
                          color: strengthColor,
                          fontWeight: FontWeight.w700,
                        ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Theme.of(context)
                      .colorScheme
                      .surfaceContainerHighest
                      .withValues(alpha: 0.45),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: SelectableText(
                  _password,
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        fontFamily: 'monospace',
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.5,
                      ),
                ),
              ),
              const SizedBox(height: 10),
              Text(
                AppStrings.tr(
                  'entropy_bits',
                  args: [_entropyBits.toStringAsFixed(0)],
                ),
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(context)
                          .colorScheme
                          .onSurface
                          .withValues(alpha: 0.65),
                    ),
              ),
              const SizedBox(height: 12),
              OutlinedButton.icon(
                onPressed: _copyPassword,
                icon: const Icon(Icons.copy_rounded),
                label: Text(AppStrings.tr('copy_password')),
              ),
            ],
          ),
        ).animate().fadeIn(duration: 450.ms, delay: 80.ms),
      ],
    );
  }
}

class _PasswordOptionTile extends StatelessWidget {
  final String label;
  final bool value;
  final ValueChanged<bool> onChanged;

  const _PasswordOptionTile({
    required this.label,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(top: 9),
              child: Text(
                label,
                maxLines: 3,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w500,
                      height: 1.2,
                    ),
              ),
            ),
          ),
          const SizedBox(width: 8),
          Switch(
            value: value,
            onChanged: onChanged,
          ),
        ],
      ),
    );
  }
}

// ── Shared widgets ─────────────────────────────────────────────────────────────

/// Gradient-filled primary action button used by every tool page.
class _GradientButton extends StatelessWidget {
  final VoidCallback onPressed;
  final IconData icon;
  final String label;
  final LinearGradient? gradient;

  const _GradientButton({
    required this.onPressed,
    required this.icon,
    required this.label,
    this.gradient,
  });

  @override
  Widget build(BuildContext context) {
    final grad = gradient ?? AppTheme.primaryGradientFor(context);

    return _TappableScale(
      onTap: onPressed,
      child: Container(
        height: 52,
        decoration: BoxDecoration(
          gradient: grad,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: grad.colors.first.withValues(alpha: 0.4),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: Colors.white, size: 20),
            const SizedBox(width: 10),
            Flexible(
              child: Text(
                label,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.3,
                  height: 1.15,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ModeButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool isSelected;
  final VoidCallback onTap;

  const _ModeButton({
    required this.label,
    required this.icon,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 220),
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          gradient: isSelected
              ? LinearGradient(
                  colors: [
                    Theme.of(context).colorScheme.primary,
                    Theme.of(context).colorScheme.secondary,
                  ],
                )
              : null,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 18,
              color: isSelected
                  ? Colors.white
                  : Theme.of(context)
                      .colorScheme
                      .onSurface
                      .withValues(alpha: 0.55),
            ),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                fontSize: 14,
                color: isSelected
                    ? Colors.white
                    : Theme.of(context)
                        .colorScheme
                        .onSurface
                        .withValues(alpha: 0.55),
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
              ),
            ),
          ],
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
        scale: _pressed ? 0.95 : 1.0,
        duration: const Duration(milliseconds: 100),
        curve: Curves.easeInOut,
        child: widget.child,
      ),
    );
  }
}

// ── Templates Page ────────────────────────────────────────────────────────────

class _TemplatesPage extends ConsumerStatefulWidget {
  const _TemplatesPage();

  @override
  ConsumerState<_TemplatesPage> createState() => _TemplatesPageState();
}

class _TemplatesPageState extends ConsumerState<_TemplatesPage> {
  void _openAddSheet() {
    unawaited(HapticFeedback.lightImpact());
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _AddTemplateSheet(
        onSave: (name, message) async {
          await ref
              .read(templatesProvider.notifier)
              .addTemplate(name: name, message: message);
          if (mounted) {
            _showSnackBar(context, AppStrings.tr('template_saved'));
          }
        },
      ),
    );
  }

  Future<bool> _confirmDelete() async {
    unawaited(HapticFeedback.selectionClick());
    return await showDialog<bool>(
          context: context,
          builder: (dialogContext) => AlertDialog(
            title: Text(AppStrings.tr('delete')),
            content: Text(AppStrings.tr('delete_this_chat')),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(dialogContext).pop(false),
                child: Text(AppStrings.tr('cancel')),
              ),
              TextButton(
                onPressed: () => Navigator.of(dialogContext).pop(true),
                child: Text(
                  AppStrings.tr('delete'),
                  style: TextStyle(
                    color: Theme.of(dialogContext).colorScheme.error,
                  ),
                ),
              ),
            ],
          ),
        ) ??
        false;
  }

  @override
  Widget build(BuildContext context) {
    final templates = ref.watch(templatesProvider);

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 4, 20, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (templates.isEmpty) ...[
            Expanded(
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        gradient: AppTheme.primaryGradientFor(context),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.bookmarks_outlined,
                        color: Colors.white,
                        size: 40,
                      ),
                    ),
                    const SizedBox(height: 20),
                    Text(
                      AppStrings.tr('no_templates'),
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      AppStrings.tr('create_your_first'),
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Theme.of(context)
                                .colorScheme
                                .onSurface
                                .withValues(alpha: 0.55),
                          ),
                    ),
                    const SizedBox(height: 32),
                    _GradientButton(
                      onPressed: _openAddSheet,
                      icon: Icons.add_rounded,
                      label: AppStrings.tr('add_template'),
                    ),
                  ],
                ),
              ).animate().fadeIn(duration: 500.ms).scale(
                    begin: const Offset(0.94, 0.94),
                  ),
            ),
          ] else ...[
            Expanded(
              child: ListView.separated(
                physics: const BouncingScrollPhysics(),
                itemCount: templates.length,
                separatorBuilder: (_, __) => const SizedBox(height: 10),
                itemBuilder: (context, index) {
                  final tpl = templates[index];
                  return _TemplateCard(
                    template: tpl,
                    onDelete: () async {
                      final confirmed = await _confirmDelete();
                      if (confirmed && mounted) {
                        await ref
                            .read(templatesProvider.notifier)
                            .deleteTemplate(tpl.id);
                        if (mounted) {
                          _showSnackBar(
                            this.context,
                            AppStrings.tr('template_deleted'),
                          );
                        }
                      }
                    },
                  ).animate().fadeIn(
                        duration: 350.ms,
                        delay: Duration(milliseconds: index * 40),
                      );
                },
              ),
            ),
            const SizedBox(height: 14),
            _GradientButton(
              onPressed: _openAddSheet,
              icon: Icons.add_rounded,
              label: AppStrings.tr('add_template'),
            ),
          ],
        ],
      ),
    );
  }
}

// ── Template Card ─────────────────────────────────────────────────────────────

class _TemplateCard extends StatelessWidget {
  final TemplateItem template;
  final VoidCallback onDelete;

  const _TemplateCard({required this.template, required this.onDelete});

  @override
  Widget build(BuildContext context) {
    return GlassmorphicContainer.flat(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Gradient icon badge
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              gradient: AppTheme.primaryGradientFor(context),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(
              Icons.bookmark_rounded,
              color: Colors.white,
              size: 18,
            ),
          ),
          const SizedBox(width: 14),
          // Name + message preview
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  template.name,
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 3),
                Text(
                  template.message,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(context)
                            .colorScheme
                            .onSurface
                            .withValues(alpha: 0.6),
                      ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          // Action buttons
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _IconAction(
                icon: Icons.copy_rounded,
                tooltip: AppStrings.tr('copy'),
                onTap: () {
                  HapticFeedback.lightImpact();
                  Clipboard.setData(ClipboardData(text: template.message));
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(AppStrings.tr('clipboard_copied')),
                      backgroundColor: Theme.of(context).colorScheme.primary,
                      behavior: SnackBarBehavior.floating,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  );
                },
              ),
              const SizedBox(height: 4),
              _IconAction(
                icon: Icons.delete_outline_rounded,
                tooltip: AppStrings.tr('delete'),
                color: Theme.of(context).colorScheme.error,
                onTap: onDelete,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _IconAction extends StatelessWidget {
  final IconData icon;
  final String tooltip;
  final VoidCallback onTap;
  final Color? color;

  const _IconAction({
    required this.icon,
    required this.tooltip,
    required this.onTap,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.all(6),
          child: Icon(
            icon,
            size: 18,
            color: color ??
                Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
          ),
        ),
      ),
    );
  }
}

// ── Add Template Bottom Sheet ─────────────────────────────────────────────────

class _AddTemplateSheet extends StatefulWidget {
  final Future<void> Function(String name, String message) onSave;

  const _AddTemplateSheet({required this.onSave});

  @override
  State<_AddTemplateSheet> createState() => _AddTemplateSheetState();
}

class _AddTemplateSheetState extends State<_AddTemplateSheet> {
  final _nameController = TextEditingController();
  final _messageController = TextEditingController();
  bool _saving = false;

  @override
  void dispose() {
    _nameController.dispose();
    _messageController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final name = _nameController.text.trim();
    final message = _messageController.text.trim();

    if (name.isEmpty || message.isEmpty) {
      _showSnackBar(context, AppStrings.tr('fill_all_fields'), isError: true);
      return;
    }

    await HapticFeedback.mediumImpact();
    setState(() => _saving = true);
    await widget.onSave(name, message);
    if (mounted) {
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final bottom = MediaQuery.of(context).viewInsets.bottom;

    return Padding(
      padding: EdgeInsets.only(bottom: bottom),
      child: Container(
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surfaceContainerLow,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        ),
        padding: const EdgeInsets.fromLTRB(24, 16, 24, 28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Drag handle
            Center(
              child: Container(
                width: 36,
                height: 4,
                decoration: BoxDecoration(
                  color: Theme.of(context)
                      .colorScheme
                      .onSurface
                      .withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 20),
            ShaderMask(
              shaderCallback: (b) =>
                  AppTheme.primaryGradientFor(context).createShader(b),
              child: Text(
                AppStrings.tr('add_template'),
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
              ),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: _nameController,
              decoration: InputDecoration(
                hintText: AppStrings.tr('template_name'),
                prefixIcon: const Icon(Icons.label_outline_rounded),
              ),
              textAlignVertical: TextAlignVertical.center,
              textCapitalization: TextCapitalization.words,
            ),
            const SizedBox(height: 14),
            TextField(
              controller: _messageController,
              decoration: InputDecoration(
                hintText: AppStrings.tr('template_message'),
              ),
              textAlignVertical: TextAlignVertical.top,
              minLines: 4,
              maxLines: 4,
              textCapitalization: TextCapitalization.sentences,
            ),
            const SizedBox(height: 20),
            _GradientButton(
              onPressed: _saving ? () {} : _save,
              icon: _saving ? Icons.hourglass_top_rounded : Icons.save_rounded,
              label: AppStrings.tr('save'),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Gmail Composer Page ─────────────────────────────────────────────────────

class _GmailComposerPage extends StatefulWidget {
  const _GmailComposerPage();

  @override
  State<_GmailComposerPage> createState() => _GmailComposerPageState();
}

class _GmailComposerPageState extends State<_GmailComposerPage> {
  final TextEditingController _recipientController = TextEditingController();
  final TextEditingController _ccController = TextEditingController();
  final TextEditingController _bccController = TextEditingController();
  final TextEditingController _subjectController = TextEditingController();
  final TextEditingController _messageController = TextEditingController();

  @override
  void dispose() {
    _recipientController.dispose();
    _ccController.dispose();
    _bccController.dispose();
    _subjectController.dispose();
    _messageController.dispose();
    super.dispose();
  }

  Future<void> _sendEmail() async {
    unawaited(HapticFeedback.mediumImpact());

    final recipient = _recipientController.text.trim();
    final cc = _ccController.text.trim();
    final bcc = _bccController.text.trim();
    final subject = _subjectController.text.trim();
    final message = _messageController.text.trim();

    if (!AppConstants.emailRegex.hasMatch(recipient)) {
      _showSnackBar(context, AppStrings.tr('enter_valid_email'), isError: true);
      return;
    }

    if (cc.isNotEmpty && !AppConstants.emailRegex.hasMatch(cc)) {
      _showSnackBar(context, AppStrings.tr('enter_valid_email'), isError: true);
      return;
    }

    if (bcc.isNotEmpty && !AppConstants.emailRegex.hasMatch(bcc)) {
      _showSnackBar(context, AppStrings.tr('enter_valid_email'), isError: true);
      return;
    }

    final mailtoUri = Uri(
      scheme: 'mailto',
      path: recipient,
      queryParameters: {
        if (cc.isNotEmpty) 'cc': cc,
        if (bcc.isNotEmpty) 'bcc': bcc,
        if (subject.isNotEmpty) 'subject': subject,
        if (message.isNotEmpty) 'body': message,
      },
    );

    final gmailWebUri = Uri.https('mail.google.com', '/mail/u/0/', {
      'view': 'cm',
      'fs': '1',
      'to': recipient,
      if (cc.isNotEmpty) 'cc': cc,
      if (bcc.isNotEmpty) 'bcc': bcc,
      if (subject.isNotEmpty) 'su': subject,
      if (message.isNotEmpty) 'body': message,
    });

    try {
      var launched = await launchUrl(
        mailtoUri,
        mode: LaunchMode.externalApplication,
      );

      if (!launched) {
        launched = await launchUrl(
          gmailWebUri,
          mode: LaunchMode.externalApplication,
        );
      }

      if (!mounted) {
        return;
      }

      if (launched) {
        _showSnackBar(context, AppStrings.tr('gmail_opened'));
      } else {
        _showSnackBar(
          context,
          AppStrings.tr('could_not_open_link'),
          isError: true,
        );
      }
    } catch (_) {
      if (!mounted) {
        return;
      }
      _showSnackBar(
        context,
        AppStrings.tr('could_not_open_link'),
        isError: true,
      );
    }
  }

  Widget _buildFieldLabel(BuildContext context, String labelKey) {
    return Padding(
      padding: const EdgeInsets.only(left: 2, bottom: 6),
      child: Text(
        AppStrings.tr(labelKey),
        style: Theme.of(context).textTheme.labelLarge?.copyWith(
              fontWeight: FontWeight.w700,
              color: Theme.of(context)
                  .colorScheme
                  .onSurface
                  .withValues(alpha: 0.8),
            ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 4, 20, 24),
      physics: const BouncingScrollPhysics(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          GlassmorphicContainer.flat(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        gradient: AppTheme.accentGradientFor(context),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(
                        Icons.mark_email_read_rounded,
                        color: Colors.white,
                        size: 22,
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            AppStrings.tr('gmail_sender'),
                            style: Theme.of(context)
                                .textTheme
                                .titleMedium
                                ?.copyWith(fontWeight: FontWeight.w700),
                          ),
                          Text(
                            AppStrings.tr('gmail_sender_desc'),
                            maxLines: 3,
                            overflow: TextOverflow.ellipsis,
                            style:
                                Theme.of(context).textTheme.bodySmall?.copyWith(
                                      color: Theme.of(context)
                                          .colorScheme
                                          .onSurface
                                          .withValues(alpha: 0.55),
                                    ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                _buildFieldLabel(context, 'gmail_recipient_label'),
                TextField(
                  controller: _recipientController,
                  keyboardType: TextInputType.emailAddress,
                  decoration: InputDecoration(
                    hintText: AppStrings.tr('gmail_recipient_hint'),
                    prefixIcon: const Icon(Icons.alternate_email_rounded),
                  ),
                  textAlignVertical: TextAlignVertical.center,
                ),
                const SizedBox(height: 14),
                _buildFieldLabel(context, 'gmail_cc_label'),
                TextField(
                  controller: _ccController,
                  keyboardType: TextInputType.emailAddress,
                  decoration: InputDecoration(
                    hintText: AppStrings.tr('gmail_cc_hint'),
                    prefixIcon: const Icon(Icons.people_outline_rounded),
                  ),
                  textAlignVertical: TextAlignVertical.center,
                ),
                const SizedBox(height: 14),
                _buildFieldLabel(context, 'gmail_bcc_label'),
                TextField(
                  controller: _bccController,
                  keyboardType: TextInputType.emailAddress,
                  decoration: InputDecoration(
                    hintText: AppStrings.tr('gmail_bcc_hint'),
                    prefixIcon: const Icon(Icons.visibility_off_outlined),
                  ),
                  textAlignVertical: TextAlignVertical.center,
                ),
                const SizedBox(height: 14),
                _buildFieldLabel(context, 'gmail_subject_label'),
                TextField(
                  controller: _subjectController,
                  decoration: InputDecoration(
                    hintText: AppStrings.tr('gmail_subject_hint'),
                    prefixIcon: const Icon(Icons.title_rounded),
                  ),
                  textAlignVertical: TextAlignVertical.center,
                ),
                const SizedBox(height: 14),
                _buildFieldLabel(context, 'gmail_body_label'),
                TextField(
                  controller: _messageController,
                  minLines: 6,
                  maxLines: 6,
                  textCapitalization: TextCapitalization.sentences,
                  decoration: InputDecoration(
                    hintText: AppStrings.tr('gmail_body_hint'),
                  ),
                  textAlignVertical: TextAlignVertical.top,
                ),
                const SizedBox(height: 16),
                _GradientButton(
                  onPressed: _sendEmail,
                  icon: Icons.send_rounded,
                  label: AppStrings.tr('gmail_send'),
                  gradient: AppTheme.primaryGradientFor(context),
                ),
              ],
            ),
          ).animate().fadeIn(duration: 500.ms),
        ],
      ),
    );
  }
}

enum _TransformKind { base64, url }

class _SecurityToolkitPage extends StatefulWidget {
  const _SecurityToolkitPage();

  @override
  State<_SecurityToolkitPage> createState() => _SecurityToolkitPageState();
}

class _SecurityToolkitPageState extends State<_SecurityToolkitPage> {
  final TextEditingController _cipherPasswordController =
      TextEditingController();
  final TextEditingController _cipherInputController = TextEditingController();
  final TextEditingController _hashInputController = TextEditingController();
  final TextEditingController _transformInputController =
      TextEditingController();

  bool _cipherEncryptMode = true;
  bool _cipherObscurePassword = true;
  String _cipherResult = '';

  String _hashAlgorithm = 'SHA-256';
  String _hashResult = '';
  bool _encodeMode = true;
  _TransformKind _transformKind = _TransformKind.base64;
  String _transformResult = '';

  int _tokenLength = 32;
  String _tokenResult = '';
  late final math.Random _random = _createRandom();

  static const _tokenCharset =
      'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789-._~';

  static final Map<String, Digest Function(List<int>)> _hashAlgorithms = {
    'SHA-256': sha256.convert,
    'SHA-512': sha512.convert,
    'SHA-1': sha1.convert,
    'MD5': md5.convert,
  };

  static math.Random _createRandom() {
    try {
      return math.Random.secure();
    } catch (_) {
      return math.Random();
    }
  }

  @override
  void initState() {
    super.initState();
    _generateToken();
  }

  @override
  void dispose() {
    _cipherPasswordController.dispose();
    _cipherInputController.dispose();
    _hashInputController.dispose();
    _transformInputController.dispose();
    super.dispose();
  }

  void _processCipher() {
    HapticFeedback.mediumImpact();
    final password = _cipherPasswordController.text;
    final message = _cipherInputController.text.trim();

    if (password.isEmpty || message.isEmpty) {
      _showSnackBar(context, AppStrings.tr('fill_all_fields'), isError: true);
      return;
    }

    try {
      final result = _cipherEncryptMode
          ? _encryptWithPassword(message, password)
          : _decryptWithPassword(message, password);
      setState(() => _cipherResult = result);
      Clipboard.setData(ClipboardData(text: result));
      _showSnackBar(
        context,
        _cipherEncryptMode
            ? AppStrings.tr('copied_encrypted')
            : AppStrings.tr('copied_decrypted'),
      );
    } catch (_) {
      _showSnackBar(
        context,
        _cipherEncryptMode
            ? AppStrings.tr('encryption_failed')
            : AppStrings.tr('decryption_failed'),
        isError: true,
      );
    }
  }

  String _encryptWithPassword(String message, String password) {
    final key = encrypt_lib.Key.fromUtf8(
      sha256.convert(utf8.encode(password)).toString().substring(0, 32),
    );
    final iv = encrypt_lib.IV.fromLength(16);
    final encrypter = encrypt_lib.Encrypter(encrypt_lib.AES(key));
    final encrypted = encrypter.encrypt(message, iv: iv);
    return '${iv.base64}:${encrypted.base64}';
  }

  String _decryptWithPassword(String message, String password) {
    final parts = message.split(':');
    if (parts.length != 2) {
      throw const FormatException('bad format');
    }
    final key = encrypt_lib.Key.fromUtf8(
      sha256.convert(utf8.encode(password)).toString().substring(0, 32),
    );
    final iv = encrypt_lib.IV.fromBase64(parts[0]);
    final encrypter = encrypt_lib.Encrypter(encrypt_lib.AES(key));
    return encrypter.decrypt64(parts[1], iv: iv);
  }

  void _generateHash() {
    final input = _hashInputController.text.trim();
    if (input.isEmpty) {
      _showSnackBar(context, AppStrings.tr('fill_all_fields'), isError: true);
      return;
    }

    final hasher = _hashAlgorithms[_hashAlgorithm] ?? sha256.convert;
    final digest = hasher(utf8.encode(input)).toString();

    setState(() => _hashResult = digest);
  }

  void _runTransform() {
    final input = _transformInputController.text;
    if (input.trim().isEmpty) {
      _showSnackBar(context, AppStrings.tr('fill_all_fields'), isError: true);
      return;
    }

    try {
      late final String result;
      if (_transformKind == _TransformKind.base64) {
        result = _encodeMode
            ? base64Encode(utf8.encode(input))
            : utf8.decode(base64Decode(input));
      } else {
        result = _encodeMode
            ? Uri.encodeComponent(input)
            : Uri.decodeComponent(input);
      }
      setState(() => _transformResult = result);
    } catch (e) {
      _showSnackBar(
        context,
        AppStrings.tr('security_operation_failed', args: [e.toString()]),
        isError: true,
      );
    }
  }

  void _generateToken() {
    final chars = _tokenCharset.split('');
    final out = StringBuffer();
    for (var i = 0; i < _tokenLength; i++) {
      out.write(chars[_random.nextInt(chars.length)]);
    }
    setState(() => _tokenResult = out.toString());
  }

  void _copyToClipboard(String text, String successKey) {
    if (text.isEmpty) {
      _showSnackBar(context, AppStrings.tr('fill_all_fields'), isError: true);
      return;
    }
    HapticFeedback.lightImpact();
    Clipboard.setData(ClipboardData(text: text));
    _showSnackBar(context, AppStrings.tr(successKey));
  }

  Widget _sectionLabel(String key) {
    return Text(
      AppStrings.tr(key),
      style: Theme.of(context).textTheme.labelLarge?.copyWith(
            fontWeight: FontWeight.w700,
            color:
                Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.8),
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 4, 20, 24),
      physics: const BouncingScrollPhysics(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          GlassmorphicContainer.flat(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    gradient: AppTheme.primaryGradientFor(context),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.security_rounded,
                    color: Colors.white,
                    size: 22,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        AppStrings.tr('security_toolkit'),
                        style: Theme.of(context)
                            .textTheme
                            .titleMedium
                            ?.copyWith(fontWeight: FontWeight.w700),
                      ),
                      Text(
                        AppStrings.tr('security_toolkit_desc'),
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: Theme.of(context)
                                  .colorScheme
                                  .onSurface
                                  .withValues(alpha: 0.58),
                            ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ).animate().fadeIn(duration: 450.ms),
          const SizedBox(height: 14),
          GlassmorphicContainer.flat(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _sectionLabel('message_encryptor'),
                const SizedBox(height: 8),
                Text(
                  AppStrings.tr('encryptor_desc'),
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(context)
                            .colorScheme
                            .onSurface
                            .withValues(alpha: 0.6),
                      ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: _ModeButton(
                        label: AppStrings.tr('encrypt'),
                        icon: Icons.lock_rounded,
                        isSelected: _cipherEncryptMode,
                        onTap: () {
                          setState(() {
                            _cipherEncryptMode = true;
                            _cipherResult = '';
                          });
                        },
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: _ModeButton(
                        label: AppStrings.tr('decrypt'),
                        icon: Icons.lock_open_rounded,
                        isSelected: !_cipherEncryptMode,
                        onTap: () {
                          setState(() {
                            _cipherEncryptMode = false;
                            _cipherResult = '';
                          });
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _cipherPasswordController,
                  decoration: InputDecoration(
                    hintText: AppStrings.tr('enter_password'),
                    prefixIcon: const Icon(Icons.key_rounded),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _cipherObscurePassword
                            ? Icons.visibility_off_rounded
                            : Icons.visibility_rounded,
                      ),
                      onPressed: () => setState(
                        () => _cipherObscurePassword = !_cipherObscurePassword,
                      ),
                    ),
                  ),
                  obscureText: _cipherObscurePassword,
                  textAlignVertical: TextAlignVertical.center,
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _cipherInputController,
                  minLines: 3,
                  maxLines: 3,
                  decoration: InputDecoration(
                    hintText: _cipherEncryptMode
                        ? AppStrings.tr('enter_message_to_encrypt')
                        : AppStrings.tr('enter_encrypted_message'),
                  ),
                  textAlignVertical: TextAlignVertical.top,
                ),
                const SizedBox(height: 14),
                _GradientButton(
                  onPressed: _processCipher,
                  icon: _cipherEncryptMode
                      ? Icons.lock_rounded
                      : Icons.lock_open_rounded,
                  label: _cipherEncryptMode
                      ? AppStrings.tr('encrypt')
                      : AppStrings.tr('decrypt'),
                  gradient: AppTheme.accentGradientFor(context),
                ),
                if (_cipherResult.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  _sectionLabel(
                    _cipherEncryptMode
                        ? 'encrypted_message'
                        : 'decrypted_message',
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Theme.of(context)
                          .colorScheme
                          .surfaceContainerHighest
                          .withValues(alpha: 0.45),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: SelectableText(
                      _cipherResult,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            fontFamily: 'monospace',
                          ),
                    ),
                  ),
                ],
              ],
            ),
          ).animate().fadeIn(duration: 450.ms, delay: 60.ms),
          const SizedBox(height: 14),
          GlassmorphicContainer.flat(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _sectionLabel('security_input'),
                const SizedBox(height: 8),
                TextField(
                  controller: _hashInputController,
                  decoration: InputDecoration(
                    hintText: AppStrings.tr('security_input_hint'),
                  ),
                  textAlignVertical: TextAlignVertical.top,
                  minLines: 2,
                  maxLines: 2,
                ),
                const SizedBox(height: 12),
                _sectionLabel('hash_algorithm'),
                const SizedBox(height: 8),
                DropdownButtonFormField<String>(
                  initialValue: _hashAlgorithm,
                  isExpanded: true,
                  decoration: const InputDecoration(
                    prefixIcon: Icon(Icons.fingerprint_rounded),
                  ),
                  items: _hashAlgorithms.keys
                      .map(
                        (algo) => DropdownMenuItem<String>(
                          value: algo,
                          child: Text(algo),
                        ),
                      )
                      .toList(),
                  onChanged: (value) {
                    if (value != null) {
                      setState(() => _hashAlgorithm = value);
                    }
                  },
                ),
                const SizedBox(height: 14),
                _GradientButton(
                  onPressed: _generateHash,
                  icon: Icons.fingerprint_rounded,
                  label: AppStrings.tr('run_hash'),
                ),
                if (_hashResult.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  _sectionLabel('hash_result'),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Theme.of(context)
                          .colorScheme
                          .surfaceContainerHighest
                          .withValues(alpha: 0.45),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: SelectableText(
                      _hashResult,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            fontFamily: 'monospace',
                            height: 1.35,
                          ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  OutlinedButton.icon(
                    onPressed: () => _copyToClipboard(
                      _hashResult,
                      'clipboard_copied',
                    ),
                    icon: const Icon(Icons.copy_rounded, size: 16),
                    label: Text(AppStrings.tr('copy')),
                  ),
                ],
              ],
            ),
          ).animate().fadeIn(duration: 450.ms, delay: 60.ms),
          const SizedBox(height: 14),
          GlassmorphicContainer.flat(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _sectionLabel('transform_mode'),
                const SizedBox(height: 10),
                Wrap(
                  spacing: 8,
                  children: [
                    ChoiceChip(
                      label: Text(AppStrings.tr('base64_mode')),
                      selected: _transformKind == _TransformKind.base64,
                      onSelected: (_) => setState(
                        () => _transformKind = _TransformKind.base64,
                      ),
                    ),
                    ChoiceChip(
                      label: Text(AppStrings.tr('url_mode')),
                      selected: _transformKind == _TransformKind.url,
                      onSelected: (_) =>
                          setState(() => _transformKind = _TransformKind.url),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: _ModeButton(
                        label: AppStrings.tr('encode'),
                        icon: Icons.arrow_downward_rounded,
                        isSelected: _encodeMode,
                        onTap: () => setState(() => _encodeMode = true),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: _ModeButton(
                        label: AppStrings.tr('decode'),
                        icon: Icons.arrow_upward_rounded,
                        isSelected: !_encodeMode,
                        onTap: () => setState(() => _encodeMode = false),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _transformInputController,
                  decoration: InputDecoration(
                    hintText: AppStrings.tr('security_input_hint'),
                  ),
                  textAlignVertical: TextAlignVertical.top,
                  minLines: 3,
                  maxLines: 3,
                ),
                const SizedBox(height: 14),
                _GradientButton(
                  onPressed: _runTransform,
                  icon: Icons.auto_fix_high_rounded,
                  label: _encodeMode
                      ? AppStrings.tr('encode')
                      : AppStrings.tr('decode'),
                  gradient: AppTheme.accentGradientFor(context),
                ),
                if (_transformResult.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  _sectionLabel('transformed_result'),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Theme.of(context)
                          .colorScheme
                          .surfaceContainerHighest
                          .withValues(alpha: 0.45),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: SelectableText(
                      _transformResult,
                      style: Theme.of(context)
                          .textTheme
                          .bodySmall
                          ?.copyWith(fontFamily: 'monospace'),
                    ),
                  ),
                  const SizedBox(height: 10),
                  OutlinedButton.icon(
                    onPressed: () => _copyToClipboard(
                      _transformResult,
                      'clipboard_copied',
                    ),
                    icon: const Icon(Icons.copy_rounded, size: 16),
                    label: Text(AppStrings.tr('copy')),
                  ),
                ],
              ],
            ),
          ).animate().fadeIn(duration: 450.ms, delay: 140.ms),
          const SizedBox(height: 14),
          GlassmorphicContainer.flat(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  children: [
                    _sectionLabel('token_length'),
                    const Spacer(),
                    Text(
                      '$_tokenLength',
                      style: Theme.of(context).textTheme.labelLarge?.copyWith(
                            fontWeight: FontWeight.w700,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                    ),
                  ],
                ),
                Slider(
                  value: _tokenLength.toDouble(),
                  min: 16,
                  max: 128,
                  divisions: 112,
                  label: '$_tokenLength',
                  onChanged: (value) =>
                      setState(() => _tokenLength = value.round()),
                ),
                _GradientButton(
                  onPressed: _generateToken,
                  icon: Icons.generating_tokens_rounded,
                  label: AppStrings.tr('generate_token'),
                  gradient: AppTheme.primaryGradientFor(context),
                ),
                if (_tokenResult.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  _sectionLabel('generated_token'),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Theme.of(context)
                          .colorScheme
                          .surfaceContainerHighest
                          .withValues(alpha: 0.45),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: SelectableText(
                      _tokenResult,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            fontFamily: 'monospace',
                            height: 1.35,
                          ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  OutlinedButton.icon(
                    onPressed: () =>
                        _copyToClipboard(_tokenResult, 'token_copied'),
                    icon: const Icon(Icons.copy_rounded, size: 16),
                    label: Text(AppStrings.tr('copy')),
                  ),
                ],
              ],
            ),
          ).animate().fadeIn(duration: 450.ms, delay: 200.ms),
          const SizedBox(height: 14),
          const _PasswordGeneratorSection(),
        ],
      ),
    );
  }
}

// ── Global helper ─────────────────────────────────────────────────────────────

void _showSnackBar(
  BuildContext context,
  String message, {
  bool isError = false,
}) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text(message),
      backgroundColor: isError
          ? Theme.of(context).colorScheme.error
          : Theme.of(context).colorScheme.primary,
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    ),
  );
}
