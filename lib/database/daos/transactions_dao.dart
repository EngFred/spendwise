import 'package:drift/drift.dart';
import '../app_database.dart';
import '../tables/transactions_table.dart';

part 'transactions_dao.g.dart';

@DriftAccessor(tables: [Transactions])
class TransactionsDao extends DatabaseAccessor<AppDatabase>
    with _$TransactionsDaoMixin {
  TransactionsDao(super.db);

  Stream<List<Transaction>> watchAllTransactions() => (select(
    transactions,
  )..orderBy([(t) => OrderingTerm.desc(t.date)])).watch();

  Stream<List<Transaction>> watchTransactionsByAccount(int accountId) =>
      (select(transactions)
            ..where((t) => t.accountId.equals(accountId))
            ..orderBy([(t) => OrderingTerm.desc(t.date)]))
          .watch();

  Stream<List<Transaction>> watchTransactionsByDateRange(
    DateTime start,
    DateTime end,
  ) =>
      (select(transactions)
            ..where((t) => t.date.isBetweenValues(start, end))
            ..orderBy([(t) => OrderingTerm.desc(t.date)]))
          .watch();

  Future<List<Transaction>> getTransactionsByMonth(int year, int month) {
    final start = DateTime(year, month, 1);
    final end = DateTime(year, month + 1, 0, 23, 59, 59);
    return (select(
      transactions,
    )..where((t) => t.date.isBetweenValues(start, end))).get();
  }

  Future<List<Transaction>> getAllTransactions() =>
      (select(transactions)..orderBy([(t) => OrderingTerm.desc(t.date)])).get();

  // Returns only the recurring templates — transactions with isRecurring = true.
  // Used by the recurring processor to find what needs to run.
  Future<List<Transaction>> getRecurringTemplates() =>
      (select(transactions)..where((t) => t.isRecurring.equals(true))).get();

  Future<int> insertTransaction(TransactionsCompanion transaction) =>
      into(transactions).insert(transaction);

  Future<bool> updateTransaction(TransactionsCompanion transaction) =>
      update(transactions).replace(transaction);

  Future<int> deleteTransaction(int id) =>
      (delete(transactions)..where((t) => t.id.equals(id))).go();

  // Updates the lastProcessedDate on a recurring template after it fires.
  // Called exclusively by RecurringTransactionProcessor.
  Future<void> updateLastProcessedDate(int id, DateTime date) =>
      (update(transactions)..where((t) => t.id.equals(id))).write(
        TransactionsCompanion(lastProcessedDate: Value(date)),
      );
}
