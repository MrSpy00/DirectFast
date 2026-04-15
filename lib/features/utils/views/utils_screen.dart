import 'dart:async';
import 'dart:convert';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
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
import '../viewmodels/templates_viewmodel.dart';
import '../../../data/models/template_item.dart';

// ── Screen ────────────────────────────────────────────────────────────────────

class UtilsScreen extends StatefulWidget {
  final int initialTab;
  const UtilsScreen({super.key, this.initialTab = 0});

  @override
  State<UtilsScreen> createState() => _UtilsScreenState();
}

class _UtilsScreenState extends State<UtilsScreen> {
  late final PageController _pageController;
  int _currentPage = 0;

  static const _segments = [
    _Segment(icon: Icons.qr_code_2_rounded, labelKey: 'tab_qr'),
    _Segment(icon: Icons.link_off_rounded, labelKey: 'tab_links'),
    _Segment(icon: Icons.lock_outline_rounded, labelKey: 'tab_encrypt'),
    _Segment(icon: Icons.bookmarks_outlined, labelKey: 'tab_templates'),
    _Segment(icon: Icons.email_outlined, labelKey: 'tab_gmail'),
  ];

  @override
  void initState() {
    super.initState();
    _currentPage = widget.initialTab.clamp(0, 4);
    _pageController = PageController(initialPage: _currentPage);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _onSegmentTap(int index) {
    HapticFeedback.lightImpact();
    _pageController.animateToPage(
      index,
      duration: const Duration(milliseconds: 380),
      curve: Curves.easeInOutCubic,
    );
  }

  @override
  Widget build(BuildContext context) {
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
                  onPageChanged: (i) => setState(() => _currentPage = i),
                  children: const [
                    _QRGeneratorPage(),
                    _LinkCleanerPage(),
                    _MessageEncryptorPage(),
                    _TemplatesPage(),
                    _GmailComposerPage(),
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
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: _PremiumSegmentedControl(
        segments: _segments,
        selectedIndex: _currentPage,
        onChanged: _onSegmentTap,
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

class _PremiumSegmentedControl extends StatelessWidget {
  final List<_Segment> segments;
  final int selectedIndex;
  final ValueChanged<int> onChanged;

  const _PremiumSegmentedControl({
    required this.segments,
    required this.selectedIndex,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final pillWidth = constraints.maxWidth / segments.length;

        return Container(
          height: 58,
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(29),
          ),
          child: Stack(
            children: [
              // Sliding gradient pill
              AnimatedPositioned(
                duration: const Duration(milliseconds: 280),
                curve: Curves.easeInOutCubic,
                left: selectedIndex * pillWidth,
                top: 4,
                bottom: 4,
                width: pillWidth,
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Theme.of(context).colorScheme.primary,
                        Theme.of(context).colorScheme.secondary,
                      ],
                    ),
                    borderRadius: BorderRadius.circular(25),
                    boxShadow: [
                      BoxShadow(
                        color: Theme.of(context)
                            .colorScheme
                            .primary
                            .withValues(alpha: 0.45),
                        blurRadius: 12,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                ),
              ),
              // Labels row (on top of sliding pill)
              Row(
                children: segments.asMap().entries.map((e) {
                  final isSelected = e.key == selectedIndex;
                  return Expanded(
                    child: GestureDetector(
                      onTap: () => onChanged(e.key),
                      behavior: HitTestBehavior.opaque,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            e.value.icon,
                            size: 19,
                            color: isSelected
                                ? Colors.white
                                : Theme.of(context)
                                    .colorScheme
                                    .onSurface
                                    .withValues(alpha: 0.55),
                          ),
                          const SizedBox(height: 3),
                          Text(
                            AppStrings.tr(e.value.labelKey),
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: isSelected
                                  ? FontWeight.w700
                                  : FontWeight.w500,
                              color: isSelected
                                  ? Colors.white
                                  : Theme.of(context)
                                      .colorScheme
                                      .onSurface
                                      .withValues(alpha: 0.55),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }).toList(),
              ),
            ],
          ),
        );
      },
    );
  }
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
  String _qrData = 'DirectFast';
  Color _fgColor = Colors.black;

  static const List<Color> _colorPresets = [
    Colors.black,
    Color(0xFF6750A4),
    Color(0xFF1565C0),
    Color(0xFF00695C),
    Color(0xFFC62828),
    Color(0xFFE65100),
  ];

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  void _generateQR() {
    final text = _textController.text.trim();
    if (text.isNotEmpty) {
      HapticFeedback.lightImpact();
      setState(() => _qrData = text);
    }
  }

  Future<void> _shareQR() async {
    await HapticFeedback.lightImpact();
    try {
      final boundary =
          _qrKey.currentContext!.findRenderObject() as RenderRepaintBoundary;
      final image = await boundary.toImage(pixelRatio: 3.0);
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
      final image = await boundary.toImage(pixelRatio: 3.0);
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
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 4, 20, 24),
      physics: const BouncingScrollPhysics(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // ── QR Display card ────────────────────────────────────────────────
          GlassmorphicContainer.flat(
            padding: const EdgeInsets.all(24),
            child: Column(
              children: [
                // QR code — white background is mandatory for readability
                RepaintBoundary(
                  key: _qrKey,
                  child: Container(
                    decoration: const BoxDecoration(color: Colors.white),
                    padding: const EdgeInsets.all(16),
                    child: QrImageView(
                      data: _qrData,
                      size: 196,
                      backgroundColor: Colors.white,
                      errorCorrectionLevel: QrErrorCorrectLevel.H,
                      eyeStyle: QrEyeStyle(
                        eyeShape: QrEyeShape.square,
                        color: _fgColor,
                      ),
                      dataModuleStyle: QrDataModuleStyle(
                        dataModuleShape: QrDataModuleShape.square,
                        color: _fgColor,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                // ── Color picker ───────────────────────────────────────────
                _QrColorPicker(
                  presets: _colorPresets,
                  selected: _fgColor,
                  onSelected: (c) {
                    HapticFeedback.selectionClick();
                    setState(() => _fgColor = c);
                  },
                ),
              ],
            ),
          )
              .animate()
              .fadeIn(duration: 500.ms)
              .scale(begin: const Offset(0.94, 0.94)),

          const SizedBox(height: 16),

          // ── Input card ─────────────────────────────────────────────────────
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
                  decoration: InputDecoration(
                    hintText: AppStrings.tr('enter_text'),
                    prefixIcon: const Icon(Icons.qr_code_2_rounded),
                  ),
                  textAlignVertical: TextAlignVertical.center,
                  onSubmitted: (_) => _generateQR(),
                ),
                const SizedBox(height: 16),
                _GradientButton(
                  onPressed: _generateQR,
                  icon: Icons.qr_code_scanner_rounded,
                  label: AppStrings.tr('generate'),
                ),
              ],
            ),
          ).animate().fadeIn(duration: 500.ms, delay: 100.ms),

          const SizedBox(height: 14),

          // ── Action row ─────────────────────────────────────────────────────
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
  final List<Color> presets;
  final Color selected;
  final ValueChanged<Color> onSelected;

  const _QrColorPicker({
    required this.presets,
    required this.selected,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          AppStrings.tr('qr_color'),
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
                    prefixIcon: const Icon(Icons.link_rounded),
                    suffixIcon: IconButton(
                      icon: const Icon(Icons.content_paste_rounded),
                      onPressed: _pasteFromClipboard,
                      tooltip: AppStrings.tr('quick_paste'),
                    ),
                  ),
                  textAlignVertical: TextAlignVertical.center,
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

// ── Message Encryptor Page ─────────────────────────────────────────────────────

class _MessageEncryptorPage extends StatefulWidget {
  const _MessageEncryptorPage();

  @override
  State<_MessageEncryptorPage> createState() => _MessageEncryptorPageState();
}

class _MessageEncryptorPageState extends State<_MessageEncryptorPage> {
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _messageController = TextEditingController();
  String? _result;
  bool _isEncryptMode = true;
  bool _obscurePassword = true;

  @override
  void dispose() {
    _passwordController.dispose();
    _messageController.dispose();
    super.dispose();
  }

  void _process() {
    HapticFeedback.mediumImpact();
    final password = _passwordController.text;
    final message = _messageController.text.trim();

    if (password.isEmpty || message.isEmpty) {
      _showSnackBar(context, AppStrings.tr('fill_all_fields'), isError: true);
      return;
    }

    try {
      if (_isEncryptMode) {
        _encrypt(message, password);
      } else {
        _decrypt(message, password);
      }
    } catch (_) {
      _showSnackBar(
        context,
        _isEncryptMode
            ? AppStrings.tr('encryption_failed')
            : AppStrings.tr('decryption_failed'),
        isError: true,
      );
    }
  }

  void _encrypt(String message, String password) {
    final key = encrypt_lib.Key.fromUtf8(
      sha256.convert(utf8.encode(password)).toString().substring(0, 32),
    );
    final iv = encrypt_lib.IV.fromLength(16);
    final encrypter = encrypt_lib.Encrypter(encrypt_lib.AES(key));

    final encrypted = encrypter.encrypt(message, iv: iv);
    final combined = '${iv.base64}:${encrypted.base64}';

    setState(() => _result = combined);
    Clipboard.setData(ClipboardData(text: combined));
    _showSnackBar(context, AppStrings.tr('copied_encrypted'));
  }

  void _decrypt(String message, String password) {
    final parts = message.split(':');
    if (parts.length != 2) {
      throw const FormatException('bad format');
    }

    final key = encrypt_lib.Key.fromUtf8(
      sha256.convert(utf8.encode(password)).toString().substring(0, 32),
    );
    final iv = encrypt_lib.IV.fromBase64(parts[0]);
    final encrypter = encrypt_lib.Encrypter(encrypt_lib.AES(key));

    final decrypted = encrypter.decrypt64(parts[1], iv: iv);
    setState(() => _result = decrypted);
    Clipboard.setData(ClipboardData(text: decrypted));
    _showSnackBar(context, AppStrings.tr('copied_decrypted'));
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 4, 20, 24),
      physics: const BouncingScrollPhysics(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // ── Mode toggle ────────────────────────────────────────────────────
          GlassmorphicContainer.flat(
            padding: const EdgeInsets.all(6),
            child: Row(
              children: [
                Expanded(
                  child: _ModeButton(
                    label: AppStrings.tr('encrypt'),
                    icon: Icons.lock_rounded,
                    isSelected: _isEncryptMode,
                    onTap: () {
                      HapticFeedback.lightImpact();
                      setState(() {
                        _isEncryptMode = true;
                        _result = null;
                      });
                    },
                  ),
                ),
                Expanded(
                  child: _ModeButton(
                    label: AppStrings.tr('decrypt'),
                    icon: Icons.lock_open_rounded,
                    isSelected: !_isEncryptMode,
                    onTap: () {
                      HapticFeedback.lightImpact();
                      setState(() {
                        _isEncryptMode = false;
                        _result = null;
                      });
                    },
                  ),
                ),
              ],
            ),
          ).animate().fadeIn(duration: 500.ms),

          const SizedBox(height: 16),

          // ── Input fields ───────────────────────────────────────────────────
          GlassmorphicContainer.flat(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                TextField(
                  controller: _passwordController,
                  decoration: InputDecoration(
                    hintText: AppStrings.tr('enter_password'),
                    prefixIcon: const Icon(Icons.key_rounded),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscurePassword
                            ? Icons.visibility_off_rounded
                            : Icons.visibility_rounded,
                      ),
                      onPressed: () =>
                          setState(() => _obscurePassword = !_obscurePassword),
                    ),
                  ),
                  textAlignVertical: TextAlignVertical.center,
                  obscureText: _obscurePassword,
                ),
                const SizedBox(height: 14),
                TextField(
                  controller: _messageController,
                  decoration: InputDecoration(
                    hintText: _isEncryptMode
                        ? AppStrings.tr('enter_message_to_encrypt')
                        : AppStrings.tr('enter_encrypted_message'),
                    prefixIcon: const Icon(Icons.message_rounded),
                  ),
                  textAlignVertical: TextAlignVertical.top,
                  maxLines: 4,
                ),
                const SizedBox(height: 16),
                _GradientButton(
                  onPressed: _process,
                  icon: _isEncryptMode
                      ? Icons.lock_rounded
                      : Icons.lock_open_rounded,
                  label: _isEncryptMode
                      ? AppStrings.tr('encrypt')
                      : AppStrings.tr('decrypt'),
                  gradient: const LinearGradient(
                    colors: [Color(0xFF11998E), Color(0xFF38EF7D)],
                  ),
                ),
              ],
            ),
          ).animate().fadeIn(duration: 500.ms, delay: 80.ms),

          if (_result != null) ...[
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
                        _isEncryptMode
                            ? AppStrings.tr('encrypted_message')
                            : AppStrings.tr('decrypted_message'),
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
                      _result!,
                      style: Theme.of(context)
                          .textTheme
                          .bodySmall
                          ?.copyWith(fontFamily: 'monospace'),
                    ),
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
            Text(
              label,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 15,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.3,
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
                  overflow: TextOverflow.fade,
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
                  overflow: TextOverflow.fade,
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
                prefixIcon: const Icon(Icons.message_outlined),
              ),
              textAlignVertical: TextAlignVertical.top,
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
              color:
                  Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.8),
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
                        gradient: const LinearGradient(
                          colors: [Color(0xFFEA4335), Color(0xFFFBBC05)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
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
                  maxLines: 6,
                  textCapitalization: TextCapitalization.sentences,
                  decoration: InputDecoration(
                    hintText: AppStrings.tr('gmail_body_hint'),
                    prefixIcon: const Icon(Icons.edit_note_rounded),
                    alignLabelWithHint: true,
                  ),
                  textAlignVertical: TextAlignVertical.top,
                ),
                const SizedBox(height: 16),
                _GradientButton(
                  onPressed: _sendEmail,
                  icon: Icons.send_rounded,
                  label: AppStrings.tr('gmail_send'),
                  gradient: const LinearGradient(
                    colors: [Color(0xFFEA4335), Color(0xFFFBBC05)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
              ],
            ),
          ).animate().fadeIn(duration: 500.ms),
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
