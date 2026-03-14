import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/providers/app_providers.dart';
import '../../../core/services/notification_service.dart';
import '../../../database/app_database.dart';
import '../../accounts/providers/accounts_provider.dart';
import '../../settings/providers/settings_provider.dart';

final transactionsStreamProvider = StreamProvider<List<Transaction>>((ref) {
  return ref.watch(transactionsRepositoryProvider).watchAllTransactions();
});

class SelectedMonthNotifier extends Notifier<DateTime> {
  @override
  DateTime build() {
    final now = DateTime.now();
    return DateTime(now.year, now.month);
  }

  void setMonth(DateTime month) => state = month;
}

final selectedMonthProvider = NotifierProvider<SelectedMonthNotifier, DateTime>(
  SelectedMonthNotifier.new,
);

final transactionsByMonthProvider = FutureProvider<List<Transaction>>((ref) {
  final selected = ref.watch(selectedMonthProvider);
  return ref
      .watch(transactionsRepositoryProvider)
      .getTransactionsByMonth(selected.year, selected.month);
});

class TransactionsNotifier extends AsyncNotifier<List<Transaction>> {
  @override
  Future<List<Transaction>> build() async {
    return ref
        .watch(transactionsRepositoryProvider)
        .watchAllTransactions()
        .first;
  }

  Future<void> createTransaction({
    required double amount,
    required String type,
    required int accountId,
    required int categoryId,
    required DateTime date,
    String? note,
    bool isRecurring = false,
    String? recurringInterval,
  }) async {
    await ref
        .read(transactionsRepositoryProvider)
        .createTransaction(
          amount: amount,
          type: type,
          accountId: accountId,
          categoryId: categoryId,
          date: date,
          note: note,
          isRecurring: isRecurring,
          recurringInterval: recurringInterval,
        );
    ref.invalidateSelf();
    ref.invalidate(accountsNotifierProvider);

    if (type == 'expense') {
      await _checkBudgetAlert(categoryId);
    }
  }

  Future<void> _checkBudgetAlert(int categoryId) async {
    try {
      final settings = ref.read(settingsProvider).value;
      if (settings == null || !settings.budgetAlerts) return;

      final budgets = await ref
          .read(budgetsRepositoryProvider)
          .getActiveBudgets();

      final budget = budgets
          .where((b) => b.categoryId == categoryId)
          .firstOrNull;

      if (budget == null) return;

      final now = DateTime.now();
      final transactions = await ref
          .read(transactionsRepositoryProvider)
          .getTransactionsByMonth(now.year, now.month);

      final spent = transactions
          .where((t) => t.type == 'expense' && t.categoryId == categoryId)
          .fold(0.0, (sum, t) => sum + t.amount);

      final percentage = spent / budget.amount;

      if (percentage >= 0.8) {
        final categories = await ref
            .read(categoriesRepositoryProvider)
            .getAllCategories();
        final category = categories
            .where((c) => c.id == categoryId)
            .firstOrNull;

        await NotificationService.instance.showBudgetAlert(
          categoryName: category?.name ?? 'Category',
          percentage: percentage,
        );
      }
    } catch (_) {}
  }

  Future<void> deleteTransaction({
    required int id,
    required int accountId,
    required double amount,
    required String type,
  }) async {
    await ref
        .read(transactionsRepositoryProvider)
        .deleteTransaction(
          id,
          accountId: accountId,
          amount: amount,
          type: type,
        );
    ref.invalidateSelf();
    ref.invalidate(accountsNotifierProvider);
  }
}

final transactionsNotifierProvider =
    AsyncNotifierProvider<TransactionsNotifier, List<Transaction>>(
      TransactionsNotifier.new,
    );
