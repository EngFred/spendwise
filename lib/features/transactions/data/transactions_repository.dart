import 'package:drift/drift.dart';
import '../../../database/app_database.dart';

class TransactionsRepository {
  final AppDatabase _db;

  TransactionsRepository(this._db);

  Stream<List<Transaction>> watchAllTransactions() =>
      _db.transactionsDao.watchAllTransactions();

  Stream<List<Transaction>> watchTransactionsByAccount(int accountId) =>
      _db.transactionsDao.watchTransactionsByAccount(accountId);

  Stream<List<Transaction>> watchTransactionsByDateRange(
    DateTime start,
    DateTime end,
  ) => _db.transactionsDao.watchTransactionsByDateRange(start, end);

  Future<List<Transaction>> getTransactionsByMonth(int year, int month) =>
      _db.transactionsDao.getTransactionsByMonth(year, month);

  Future<int> createTransaction({
    required double amount,
    required String type,
    required int accountId,
    required int categoryId,
    required DateTime date,
    String? note,
    bool isRecurring = false,
    String? recurringInterval,
  }) async {
    final transaction = TransactionsCompanion.insert(
      amount: amount,
      type: type,
      accountId: accountId,
      categoryId: categoryId,
      date: date,
      note: Value(note),
      isRecurring: Value(isRecurring),
      recurringInterval: Value(recurringInterval),
    );

    final id = await _db.transactionsDao.insertTransaction(transaction);

    // update account balance
    final account = await _db.accountsDao.getAccountById(accountId);
    if (account != null) {
      final newBalance = type == 'income'
          ? account.balance + amount
          : account.balance - amount;
      await _db.accountsDao.updateBalance(accountId, newBalance);
    }

    return id;
  }

  Future<bool> updateTransaction(Transaction transaction) {
    return _db.transactionsDao.updateTransaction(transaction.toCompanion(true));
  }

  Future<int> deleteTransaction(
    int id, {
    required int accountId,
    required double amount,
    required String type,
  }) async {
    // reverse the balance effect
    final account = await _db.accountsDao.getAccountById(accountId);
    if (account != null) {
      final restoredBalance = type == 'income'
          ? account.balance - amount
          : account.balance + amount;
      await _db.accountsDao.updateBalance(accountId, restoredBalance);
    }
    return _db.transactionsDao.deleteTransaction(id);
  }
}
