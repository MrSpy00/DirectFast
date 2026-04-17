import '../constants/platform_type.dart';

class DeepLinkRequest {
  const DeepLinkRequest({
    required this.platform,
    required this.contact,
    required this.sourceUri,
  });

  final PlatformType platform;
  final String contact;
  final Uri sourceUri;
}
