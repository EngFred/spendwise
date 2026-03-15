import '../../../../core/error/app_result.dart';
import '../../../../core/utils/app_logger.dart';
import '../../../accounts/data/datasources/accounts_local_datasource.dart';
import '../../domain/entities/transaction_entity.dart';
import '../../domain/repositories/i_transactions_repository.dart';
import '../datasources/transactions_local_datasource.dart';
import '../models/transaction_model.dart';

class TransactionsRepositoryImpl implements ITransactionsRepository {
  final ITransactionsLocalDatasource _localDatasource;

  /// Injected so this repository can update account balances atomically
  /// at the data layer — no balance logic leaks into the domain or UI.
  final IAccountsLocalDatasource _accountsDatasource;

  const TransactionsRepositoryImpl(
    this._localDatasource,
    this._accountsDatasource,
  );

  // ── Streams ───────────────────────────────────────────────────────────────

  @override
  Stream<List<TransactionEntity>> watchAllTransactions() {
    AppLogger.info('TransactionsRepository: watchAllTransactions()');
    return _localDatasource.watchAllTransactions().map(
      (rows) => rows.map(TransactionModel.fromDrift).toList(),
    );
  }

  @override
  Stream<List<TransactionEntity>> watchTransactionsByAccount(int accountId) {
    AppLogger.info(
      'TransactionsRepository: watchTransactionsByAccount($accountId)',
    );
    return _localDatasource
        .watchTransactionsByAccount(accountId)
        .map((rows) => rows.map(TransactionModel.fromDrift).toList());
  }

  @override
  Stream<List<TransactionEntity>> watchTransactionsByDateRange(
    DateTime start,
    DateTime end,
  ) {
    AppLogger.info('TransactionsRepository: watchTransactionsByDateRange()');
    return _localDatasource
        .watchTransactionsByDateRange(start, end)
        .map((rows) => rows.map(TransactionModel.fromDrift).toList());
  }

  // ── Queries ───────────────────────────────────────────────────────────────

  @override
  Future<AppResult<List<TransactionEntity>>> getTransactionsByMonth(
    int year,
    int month,
  ) async {
    try {
      final rows = await _localDatasource.getTransactionsByMonth(year, month);
      final entities = rows.map(TransactionModel.fromDrift).toList();
      AppLogger.info(
        'TransactionsRepository: fetched ${entities.length} transactions for $year/$month',
      );
      return Success(entities);
    } catch (e, st) {
      AppLogger.error(
        'TransactionsRepository: getTransactionsByMonth failed',
        e,
        st,
      );
      return Failure('Failed to load transactions: $e');
    }
  }

  // ── Mutations ─────────────────────────────────────────────────────────────

  @override
  Future<AppResult<int>> createTransaction(
    TransactionEntity transaction,
  ) async {
    try {
      final id = await _localDatasource.insertTransaction(
        TransactionModel.toInsertCompanion(transaction),
      );

      // Update account balance atomically at the data layer
      await _applyBalanceDelta(
        accountId: transaction.accountId,
        amount: transaction.amount,
        isIncome: transaction.type == 'income',
      );

      AppLogger.info('TransactionsRepository: created transaction id=$id');
      return Success(id);
    } catch (e, st) {
      AppLogger.error(
        'TransactionsRepository: createTransaction failed',
        e,
        st,
      );
      return Failure('Failed to create transaction: $e');
    }
  }

  @override
  Future<AppResult<bool>> updateTransaction(
    TransactionEntity transaction,
  ) async {
    try {
      final updated = await _localDatasource.updateTransaction(
        TransactionModel.toUpdateCompanion(transaction),
      );
      AppLogger.info(
        'TransactionsRepository: updated transaction id=${transaction.id}',
      );
      return Success(updated);
    } catch (e, st) {
      AppLogger.error(
        'TransactionsRepository: updateTransaction failed',
        e,
        st,
      );
      return Failure('Failed to update transaction: $e');
    }
  }

  @override
  Future<AppResult<int>> deleteTransaction(
    TransactionEntity transaction,
  ) async {
    try {
      // Reverse the balance effect before deleting
      await _applyBalanceDelta(
        accountId: transaction.accountId,
        amount: transaction.amount,
        isIncome: transaction.type != 'income', // invert the original effect
      );

      final count = await _localDatasource.deleteTransaction(transaction.id!);
      AppLogger.info(
        'TransactionsRepository: deleted transaction id=${transaction.id}',
      );
      return Success(count);
    } catch (e, st) {
      AppLogger.error(
        'TransactionsRepository: deleteTransaction failed',
        e,
        st,
      );
      return Failure('Failed to delete transaction: $e');
    }
  }

  // ── Private helpers ───────────────────────────────────────────────────────

  Future<void> _applyBalanceDelta({
    required int accountId,
    required double amount,
    required bool isIncome,
  }) async {
    final account = await _accountsDatasource.getAccountById(accountId);
    if (account == null) return;

    final newBalance = isIncome
        ? account.balance + amount
        : account.balance - amount;

    await _accountsDatasource.updateBalance(accountId, newBalance);
    AppLogger.debug(
      'TransactionsRepository: balance updated for account $accountId → $newBalance',
    );
  }
}
