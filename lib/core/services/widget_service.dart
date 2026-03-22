import 'package:home_widget/home_widget.dart';
import 'package:intl/intl.dart';
import '../../database/app_database.dart';
import '../utils/app_logger.dart';

/// Pushes the latest balance data into shared storage so the Android
/// home screen widget can read it and redraw.
///
/// This is intentionally framework-free — it takes a raw [AppDatabase]
/// so it can be called from any isolate context (main, WorkManager, lifecycle).
///
/// Call this whenever account balances may have changed:
///   • On app resume (AppLifecycleObserver)
///   • After every transaction create / edit / delete
///   • After a transfer completes
class WidgetService {
  WidgetService._();

  // Must match the class name in BalanceWidget.kt
  static const _androidWidgetName = 'BalanceWidget';

  // SharedPreferences keys — must match what BalanceWidget.kt reads.
  static const _keyBalance = 'total_balance';
  static const _keyIncome = 'monthly_income';
  static const _keyExpense = 'monthly_expense';
  static const _keyUpdated = 'last_updated';

  static Future<void> update(AppDatabase db) async {
    try {
      // Total balance across all accounts.
      final accounts = await db.accountsDao.getAllAccounts();
      final totalBalance = accounts.fold(0.0, (sum, a) => sum + a.balance);

      // This month's income and expense.
      final now = DateTime.now();
      final transactions = await db.transactionsDao.getTransactionsByMonth(
        now.year,
        now.month,
      );

      double income = 0;
      double expense = 0;
      for (final t in transactions) {
        if (t.type == 'income') {
          income += t.amount;
        } else {
          expense += t.amount;
        }
      }

      // Write all values to shared storage.
      await HomeWidget.saveWidgetData<String>(
        _keyBalance,
        _formatAmount(totalBalance),
      );
      await HomeWidget.saveWidgetData<String>(
        _keyIncome,
        _formatAmount(income),
      );
      await HomeWidget.saveWidgetData<String>(
        _keyExpense,
        _formatAmount(expense),
      );
      await HomeWidget.saveWidgetData<String>(
        _keyUpdated,
        DateFormat('h:mm a').format(now),
      );

      // Tell Android to redraw all instances of BalanceWidget.
      await HomeWidget.updateWidget(androidName: _androidWidgetName);

      AppLogger.info(
        'WidgetService: updated — balance=${_formatAmount(totalBalance)}',
      );
    } catch (e, st) {
      // Widget failures are non-critical — the app still works fine.
      AppLogger.warning('WidgetService: update failed', e, st);
    }
  }

  static String _formatAmount(double amount) {
    return 'UGX ${NumberFormat('#,###').format(amount.abs())}';
  }
}
