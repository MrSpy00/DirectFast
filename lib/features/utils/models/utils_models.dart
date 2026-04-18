part of '../views/utils_screen.dart';

class _Segment {
  final IconData icon;
  final String labelKey;

  const _Segment({required this.icon, required this.labelKey});
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
