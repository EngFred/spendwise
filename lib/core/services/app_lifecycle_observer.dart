import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../router/app_router.dart';
import '../../features/settings/providers/settings_provider.dart';
import '../services/recurring_transaction_processor.dart';
import '../services/widget_service.dart';
import '../../core/providers/app_providers.dart';
import '../utils/app_logger.dart';

class AppLifecycleObserver extends WidgetsBindingObserver {
  final WidgetRef ref;

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

    // ── Biometric lock ────────────────────────────────────────────────────
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

    // ── On resume: recurring transactions + widget update ─────────────────
    if (state == AppLifecycleState.resumed && !_isProcessing) {
      _onAppResumed();
    }
  }

  Future<void> _onAppResumed() async {
    if (_isProcessing) return;
    _isProcessing = true;

    try {
      final db = ref.read(appDatabaseProvider);

      // Process any due recurring transactions first.
      final count = await processRecurringTransactions(db);
      if (count > 0) {
        AppLogger.info(
          'AppLifecycleObserver: processed $count recurring transaction(s)',
        );
      }

      // Push fresh balance data to the home screen widget.
      // Always runs so the widget reflects any changes made during this session.
      await WidgetService.update(db);
    } catch (e, st) {
      AppLogger.error(
        'AppLifecycleObserver: onResume processing failed',
        e,
        st,
      );
    } finally {
      _isProcessing = false;
    }
  }
}
