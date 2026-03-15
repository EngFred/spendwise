import '../../../../core/utils/app_logger.dart';
import '../../../../database/app_database.dart';
import '../../../../database/daos/transactions_dao.dart';

abstract interface class ITransactionsLocalDatasource {
  Stream<List<Transaction>> watchAllTransactions();
  Stream<List<Transaction>> watchTransactionsByAccount(int accountId);
  Stream<List<Transaction>> watchTransactionsByDateRange(
    DateTime start,
    DateTime end,
  );
  Future<List<Transaction>> getTransactionsByMonth(int year, int month);
  Future<int> insertTransaction(TransactionsCompanion companion);
  Future<bool> updateTransaction(TransactionsCompanion companion);
  Future<int> deleteTransaction(int id);
}

class TransactionsLocalDatasource implements ITransactionsLocalDatasource {
  final TransactionsDao _dao;
  const TransactionsLocalDatasource(this._dao);

  @override
  Stream<List<Transaction>> watchAllTransactions() {
    AppLogger.trace('TransactionsLocalDatasource: watchAllTransactions()');
    return _dao.watchAllTransactions();
  }

  @override
  Stream<List<Transaction>> watchTransactionsByAccount(int accountId) {
    AppLogger.trace(
      'TransactionsLocalDatasource: watchTransactionsByAccount($accountId)',
    );
    return _dao.watchTransactionsByAccount(accountId);
  }

  @override
  Stream<List<Transaction>> watchTransactionsByDateRange(
    DateTime start,
    DateTime end,
  ) {
    AppLogger.trace(
      'TransactionsLocalDatasource: watchTransactionsByDateRange()',
    );
    return _dao.watchTransactionsByDateRange(start, end);
  }

  @override
  Future<List<Transaction>> getTransactionsByMonth(int year, int month) {
    AppLogger.trace(
      'TransactionsLocalDatasource: getTransactionsByMonth($year/$month)',
    );
    return _dao.getTransactionsByMonth(year, month);
  }

  @override
  Future<int> insertTransaction(TransactionsCompanion companion) {
    AppLogger.debug('TransactionsLocalDatasource: insertTransaction()');
    return _dao.insertTransaction(companion);
  }

  @override
  Future<bool> updateTransaction(TransactionsCompanion companion) {
    AppLogger.debug('TransactionsLocalDatasource: updateTransaction()');
    return _dao.updateTransaction(companion);
  }

  @override
  Future<int> deleteTransaction(int id) {
    AppLogger.debug('TransactionsLocalDatasource: deleteTransaction($id)');
    return _dao.deleteTransaction(id);
  }
}
