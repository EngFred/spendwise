import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/utils/app_logger.dart';
import '../onboarding_providers.dart';

class OnboardingNotifier extends AsyncNotifier<bool> {
  @override
  Future<bool> build() async {
    final result = await ref.read(getOnboardingStatusUseCaseProvider).call();
    return result.when(
      success: (data) => data,
      failure: (msg) {
        AppLogger.error('OnboardingNotifier.build failed: $msg');
        return false; // Safe default — show onboarding rather than crash
      },
    );
  }

  Future<void> completeOnboarding() async {
    final result = await ref.read(completeOnboardingUseCaseProvider).call();
    result.when(
      success: (_) {
        AppLogger.info('OnboardingNotifier: onboarding completed');
        state = const AsyncData(true);
      },
      failure: (msg) {
        AppLogger.error('OnboardingNotifier: completeOnboarding failed — $msg');
        // Still mark as complete in memory so the user can proceed
        state = const AsyncData(true);
      },
    );
  }
}

final onboardingProvider = AsyncNotifierProvider<OnboardingNotifier, bool>(
  OnboardingNotifier.new,
);
