import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../router/app_router.dart';
import '../../features/settings/providers/settings_provider.dart';
import '../services/recurring_transaction_processor.dart';
import '../../core/providers/app_providers.dart';
import '../utils/app_logger.dart';

class AppLifecycleObserver extends WidgetsBindingObserver {
  final WidgetRef ref;

  // Debounce flag: prevents processing firing multiple times if the OS
  // delivers several rapid resume events (e.g. biometric prompt dismissal).
  bool _isProcessing = false;

  AppLifecycleObserver(this.ref);

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
    final location = _currentLocation();

    // ── Biometric lock handling ───────────────────────────────────────────
    if (settings?.biometricLock ?? false) {
      if (state == AppLifecycleState.paused ||
          state == AppLifecycleState.detached) {
        if (location != '/lock' && location != '/splash') {
          ref.read(sessionUnlockedProvider.notifier).lock();
        }
      }

      if (state == AppLifecycleState.resumed) {
        if (location != '/lock' && location != '/splash') {
          final isUnlocked = ref.read(sessionUnlockedProvider);
          if (!isUnlocked) {
            ref.read(appRouterProvider).go('/lock');
          }
        }
      }
    }

    // ── Recurring transaction processing on resume ────────────────────────
    //
    // This is the primary trigger on iOS (where WorkManager is unreliable)
    // and a belt-and-suspenders trigger on Android alongside WorkManager.
    //
    // We use the main isolate's existing database instance (from Riverpod)
    // so no second DB connection is opened. Only runs once per resume event.
    if (state == AppLifecycleState.resumed && !_isProcessing) {
      _triggerRecurringProcessing();
    }
  }

  Future<void> _triggerRecurringProcessing() async {
    if (_isProcessing) return;
    _isProcessing = true;

    try {
      final db = ref.read(appDatabaseProvider);
      final count = await processRecurringTransactions(db);
      if (count > 0) {
        AppLogger.info(
          'AppLifecycleObserver: processed $count recurring transaction(s)',
        );
        // Invalidate providers so the UI reflects new transactions immediately.
        // ignore: invalid_use_of_internal_member
        ref.invalidate(appDatabaseProvider);
      }
    } catch (e, st) {
      AppLogger.error(
        'AppLifecycleObserver: recurring processing failed',
        e,
        st,
      );
    } finally {
      _isProcessing = false;
    }
  }
}
