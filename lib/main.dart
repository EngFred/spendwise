import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:workmanager/workmanager.dart';
import 'app.dart';
import 'core/services/notification_service.dart';
import 'core/services/workmanager_dispatcher.dart';

// ── WorkManager task name ─────────────────────────────────────────────────────
const _kRecurringTaskName = 'spendwise.recurring_check';
const _kRecurringTaskTag = 'spendwiseRecurringCheck';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Notification service must be ready before anything else tries to fire one.
  await NotificationService.instance.init();

  // Initialise WorkManager and register the periodic recurring-check task.
  //
  // isInDebugMode: set to true during development to see WorkManager logs in
  // Logcat. Flip to false before publishing.
  await Workmanager().initialize(callbackDispatcher, isInDebugMode: false);

  // Register the periodic task once.
  //
  // ExistingWorkPolicy.keep: if the task is already scheduled (e.g. app
  // restarted), do not reschedule — keep the existing schedule so we don't
  // drift the timing.
  //
  // Minimum frequency on Android is 15 minutes. We use 1 hour — frequent
  // enough to catch daily/weekly/monthly transactions on the correct day
  // without draining battery.
  //
  // iOS note: WorkManager's iOS background fetch is best-effort. The OS
  // decides when to actually run it. The app-resume path in
  // AppLifecycleObserver is the reliable trigger on iOS.
  await Workmanager().registerPeriodicTask(
    _kRecurringTaskName,
    _kRecurringTaskTag,
    frequency: const Duration(hours: 1),
    existingWorkPolicy: ExistingPeriodicWorkPolicy.keep,
    constraints: Constraints(networkType: NetworkType.notRequired),
  );

  runApp(const ProviderScope(child: App()));
}
