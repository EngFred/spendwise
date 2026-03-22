import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/utils/app_logger.dart';
import '../../../../core/services/notification_service.dart';
import '../../accounts/domain/entities/account_entity.dart';
import '../../accounts/providers/accounts_provider.dart';
import '../../budgets/budgets_providers.dart';
import '../../categories/categories_providers.dart';
import '../../categories/domain/usecases/create_category_usecase.dart';
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

  // ── Transfer between accounts ─────────────────────────────────────────────
  //
  // A transfer creates TWO transaction records:
  //   1. An expense on the source account  ("Transfer to <destination>")
  //   2. An income  on the destination account ("Transfer from <source>")
  //
  // This means:
  //   • Both balance changes are visible in transaction history.
  //   • Deleting either leg reverses its balance effect automatically (the
  //     existing _applyBalanceDelta logic in the repository handles it).
  //   • Transfers don't pollute budget tracking because they use a dedicated
  //     "Transfer" category that users never assign budgets to.
  //
  // The "Transfer" category is found or created on the fly so no manual
  // seeding is required.
  Future<void> createTransfer({
    required AccountEntity fromAccount,
    required AccountEntity toAccount,
    required double amount,
    required DateTime date,
    String? note,
  }) async {
    // Step 1: resolve the Transfer category ID.
    final transferCategoryId = await _resolveTransferCategoryId();

    final baseNote = note?.isNotEmpty == true ? ' — $note' : '';

    // Step 2: expense leg — money leaving the source account.
    final expenseResult = await ref
        .read(createTransactionUseCaseProvider)
        .call(
          CreateTransactionParams(
            amount: amount,
            type: 'expense',
            accountId: fromAccount.id!,
            categoryId: transferCategoryId,
            date: date,
            note: 'Transfer to ${toAccount.name}$baseNote',
          ),
        );

    expenseResult.when(
      success: (_) =>
          AppLogger.info('TransactionsNotifier: transfer expense leg created'),
      failure: (msg) {
        AppLogger.error(
          'TransactionsNotifier: transfer expense leg failed — $msg',
        );
        throw Exception('Transfer failed: $msg');
      },
    );

    // Step 3: income leg — money arriving at the destination account.
    final incomeResult = await ref
        .read(createTransactionUseCaseProvider)
        .call(
          CreateTransactionParams(
            amount: amount,
            type: 'income',
            accountId: toAccount.id!,
            categoryId: transferCategoryId,
            date: date,
            note: 'Transfer from ${fromAccount.name}$baseNote',
          ),
        );

    incomeResult.when(
      success: (_) =>
          AppLogger.info('TransactionsNotifier: transfer income leg created'),
      failure: (msg) {
        AppLogger.error(
          'TransactionsNotifier: transfer income leg failed — $msg',
        );
        throw Exception('Transfer failed on destination: $msg');
      },
    );

    // Step 4: refresh all dependent providers.
    ref.invalidateSelf();
    ref.invalidate(accountsNotifierProvider);

    AppLogger.info(
      'TransactionsNotifier: transfer complete '
      '${fromAccount.name} → ${toAccount.name} — $amount',
    );
  }

  // ── Update transaction ───────────────────────────────────────────────────
  //
  // Implemented as delete-original + create-new. This is intentional:
  //
  //   • The existing updateTransaction in the repository only updates the
  //     DB row — it does NOT adjust account balances.
  //   • Doing delete+create reuses the proven _applyBalanceDelta logic on
  //     both sides: the delete reverses the original balance effect, the
  //     create applies the new one. Works correctly even when the account,
  //     type, or amount changes.
  //   • The transaction gets a new ID, which is invisible to users.
  Future<void> updateTransaction({
    required TransactionEntity original,
    required CreateTransactionParams updated,
  }) async {
    // Step 1: reverse the original transaction's balance effect.
    await deleteTransaction(original);
    // Step 2: apply the updated transaction.
    await createTransaction(updated);
    AppLogger.info(
      'TransactionsNotifier: updated transaction id=\${original.id}',
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

  // Finds the "Transfer" category or creates it if it doesn't exist yet.
  // Uses type 'expense' as the base type — transfers show under expense
  // categories in the selector, but since users never filter by this
  // category in budgets it doesn't affect budget calculations.
  Future<int> _resolveTransferCategoryId() async {
    final result = await ref.read(getAllCategoriesUseCaseProvider).call();
    final categories = result.dataOrNull ?? [];

    final existing = categories
        .where((c) => c.name.toLowerCase() == 'transfer')
        .firstOrNull;
    if (existing != null) return existing.id!;

    // Not found — create it once.
    final createResult = await ref
        .read(createCategoryUseCaseProvider)
        .call(
          CreateCategoryParams(
            name: 'Transfer',
            icon: '↔️',
            color: '#888888',
            type: 'expense',
          ),
        );

    return createResult.when(
      success: (id) {
        AppLogger.info(
          'TransactionsNotifier: created Transfer category id=$id',
        );
        return id;
      },
      failure: (msg) {
        AppLogger.error(
          'TransactionsNotifier: could not create Transfer category — $msg',
        );
        throw Exception('Could not resolve Transfer category: $msg');
      },
    );
  }

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
