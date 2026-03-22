import 'package:flutter/material.dart';
import 'package:workmanager/workmanager.dart';
import '../services/notification_service.dart';
import '../services/recurring_transaction_processor.dart';
import '../../database/app_database.dart';

// ── Background isolate entry point ────────────────────────────────────────────
//
// This function MUST be a top-level function (not inside a class) and MUST
// carry the @pragma annotation so the Dart compiler does not tree-shake it.
//
// WorkManager spins up a fresh Dart isolate to call this. That means:
//   • No Riverpod container is available — open the DB directly.
//   • No Flutter widget binding — call ensureInitialized first.
//   • NotificationService.init() must be called before showing notifications.
@pragma('vm:entry-point')
void callbackDispatcher() {
  Workmanager().executeTask((taskName, inputData) async {
    try {
      WidgetsFlutterBinding.ensureInitialized();

      // Initialise notifications so the background isolate can fire them.
      await NotificationService.instance.init();

      // Open the same spendwise.db file the main isolate uses.
      final file = await getDatabaseFile();
      final db = AppDatabase.fromFile(file);

      try {
        final count = await processRecurringTransactions(db);
        if (count > 0) {
          await NotificationService.instance.showRecurringProcessedNotification(
            count: count,
          );
        }
      } finally {
        await db.close();
      }

      return true; // true = WorkManager considers the task successful.
    } catch (e) {
      // Return false so WorkManager retries the task.
      return false;
    }
  });
}
