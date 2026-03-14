import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../router/app_router.dart';
import '../../features/settings/providers/settings_provider.dart';

class AppLifecycleObserver extends WidgetsBindingObserver {
  final WidgetRef ref;

  AppLifecycleObserver(this.ref);

  /// Returns the current router location, e.g. '/dashboard', '/lock'.
  String _currentLocation() {
    try {
      final router = ref.read(appRouterProvider);
      return router.routeInformationProvider.value.uri.path;
    } catch (_) {
      return '';
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    final settings = ref.read(settingsProvider).value;
    if (!(settings?.biometricLock ?? false)) return;

    final location = _currentLocation();

    if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.detached) {
      // FIX 3a: Do NOT lock when the biometric prompt is active.
      // The system prompt itself causes a 'paused' event while still on the
      // lock screen. If we call lock() here we wipe the unlock() that
      // authenticate() is about to set, causing the bounce loop.
      // Safe rule: only lock when we are currently on a real app screen,
      // not when we are already on the lock screen (mid-auth).
      if (location != '/lock' && location != '/splash') {
        ref.read(sessionUnlockedProvider.notifier).lock();
      }
    }

    if (state == AppLifecycleState.resumed) {
      // FIX 3b: Only navigate to lock if:
      //   • We are NOT already on the lock screen (avoids pointless re-push).
      //   • The session is not already unlocked (auth just succeeded).
      if (location != '/lock' && location != '/splash') {
        final isUnlocked = ref.read(sessionUnlockedProvider);
        if (!isUnlocked) {
          ref.read(appRouterProvider).go('/lock');
        }
      }
    }
  }
}
