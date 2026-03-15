import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/utils/app_logger.dart';
import '../../../../core/services/notification_service.dart';
import '../../accounts/providers/accounts_provider.dart';
import '../../budgets/budgets_providers.dart';
import '../../categories/categories_providers.dart';
import '../../settings/providers/settings_provider.dart';
import '../domain/entities/transaction_entity.dart';
import '../domain/usecases/create_transaction_usecase.dart';
import '../transactions_providers.dart';

// ── Month selector ────────────────────────────────────────────────────────────

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

// ── Stream providers ──────────────────────────────────────────────────────────

final transactionsStreamProvider = StreamProvider<List<TransactionEntity>>((
  ref,
) {
  return ref.watch(watchAllTransactionsUseCaseProvider).call();
});

final transactionsByMonthProvider = StreamProvider<List<TransactionEntity>>((
  ref,
) {
  final selected = ref.watch(selectedMonthProvider);

  return ref.watch(watchAllTransactionsUseCaseProvider).call().map((
    transactions,
  ) {
    // Filter to only the selected month client-side
    return transactions.where((t) {
      return t.date.year == selected.year && t.date.month == selected.month;
    }).toList();
  });
});

// ── Notifier ──────────────────────────────────────────────────────────────────

class TransactionsNotifier extends AsyncNotifier<List<TransactionEntity>> {
  @override
  Future<List<TransactionEntity>> build() async {
    return ref.watch(watchAllTransactionsUseCaseProvider).call().first;
  }

  Future<void> createTransaction(CreateTransactionParams params) async {
    final result = await ref
        .read(createTransactionUseCaseProvider)
        .call(params);
    result.when(
      success: (_) {
        AppLogger.info('TransactionsNotifier: transaction created');
        ref.invalidateSelf();
        // ✅ Still invalidate accounts so balance card updates immediately
        ref.invalidate(accountsNotifierProvider);

        if (params.type == 'expense') {
          _checkBudgetAlert(params.categoryId);
        }
      },
      failure: (msg) {
        AppLogger.error(
          'TransactionsNotifier: createTransaction failed — $msg',
        );
        throw Exception(msg);
      },
    );
  }

  Future<void> deleteTransaction(TransactionEntity transaction) async {
    final result = await ref
        .read(deleteTransactionUseCaseProvider)
        .call(transaction);
    result.when(
      success: (_) {
        AppLogger.info(
          'TransactionsNotifier: deleted transaction id=${transaction.id}',
        );
        ref.invalidateSelf();
        ref.invalidate(accountsNotifierProvider);
      },
      failure: (msg) {
        AppLogger.error(
          'TransactionsNotifier: deleteTransaction failed — $msg',
        );
        throw Exception(msg);
      },
    );
  }

  // ── Private helpers ───────────────────────────────────────────────────────

  Future<void> _checkBudgetAlert(int categoryId) async {
    try {
      final settings = ref.read(settingsProvider).value;
      if (settings == null || !settings.budgetAlerts) return;

      final budgetsResult = await ref
          .read(getActiveBudgetsUseCaseProvider)
          .call();
      final budgets = budgetsResult.dataOrNull ?? [];
      final budget = budgets
          .where((b) => b.categoryId == categoryId)
          .firstOrNull;
      if (budget == null) return;

      final now = DateTime.now();
      final txResult = await ref
          .read(getTransactionsByMonthUseCaseProvider)
          .call(now.year, now.month);

      final transactions = txResult.dataOrNull ?? [];
      final spent = transactions
          .where((t) => t.type == 'expense' && t.categoryId == categoryId)
          .fold(0.0, (sum, t) => sum + t.amount);

      final percentage = spent / budget.amount;
      if (percentage < 0.8) return;

      final catResult = await ref.read(getAllCategoriesUseCaseProvider).call();
      final category = catResult.dataOrNull
          ?.where((c) => c.id == categoryId)
          .firstOrNull;

      await NotificationService.instance.showBudgetAlert(
        categoryName: category?.name ?? 'Category',
        percentage: percentage,
      );
    } catch (e, st) {
      AppLogger.warning(
        'TransactionsNotifier: _checkBudgetAlert failed',
        e,
        st,
      );
    }
  }
}

final transactionsNotifierProvider =
    AsyncNotifierProvider<TransactionsNotifier, List<TransactionEntity>>(
      TransactionsNotifier.new,
    );
