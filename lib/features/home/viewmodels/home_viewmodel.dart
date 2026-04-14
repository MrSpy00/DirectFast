import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/platform_type.dart';
import '../../../core/services/url_launcher_service.dart';
import '../../../core/services/clipboard_service.dart';
import '../../history/viewmodels/history_viewmodel.dart';

// Provider for selected platform
final selectedPlatformProvider = StateProvider<PlatformType>((ref) {
  return PlatformType.whatsapp;
});

// Provider for selected category
final selectedCategoryProvider = StateProvider<PlatformCategory>((ref) {
  return PlatformCategory.chat;
});

// Provider for contact input
final contactInputProvider = StateProvider<String>((ref) {
  return '';
});

// Provider for clipboard suggestion
final clipboardSuggestionProvider = FutureProvider<String?>((ref) async {
  final selectedPlatform = ref.watch(selectedPlatformProvider);

  if (selectedPlatform.requiresPhoneNumber) {
    return ClipboardService.getPhoneNumber();
  } else if (selectedPlatform.requiresUsername) {
    return ClipboardService.getUsername();
  } else if (selectedPlatform.requiresEmail) {
    return ClipboardService.getEmail();
  }

  return null;
});

// Provider for launching chat
final chatLauncherProvider = Provider<ChatLauncher>((ref) {
  return ChatLauncher(ref);
});

class ChatLauncher {
  final Ref ref;

  ChatLauncher(this.ref);

  Future<LaunchResult> launchChat({
    required PlatformType platform,
    required String contact,
  }) async {
    // Validate contact
    final error = UrlLauncherService.getValidationError(
      platform: platform,
      contact: contact,
    );

    if (error != null) {
      return LaunchResult(success: false, error: error);
    }

    // Try to launch
    final result = await UrlLauncherService.launchChat(
      platform: platform,
      contact: contact,
    );

    if (result.success) {
      // Add to history
      await ref.read(historyProvider.notifier).addHistoryItem(
            platform: platform,
            contact: contact,
          );
    }

    return result;
  }
}
