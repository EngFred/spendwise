import '../../../../core/error/app_result.dart';
import '../entities/transaction_entity.dart';

abstract interface class ITransactionsRepository {
  Stream<List<TransactionEntity>> watchAllTransactions();

  Stream<List<TransactionEntity>> watchTransactionsByAccount(int accountId);

  Stream<List<TransactionEntity>> watchTransactionsByDateRange(
    DateTime start,
    DateTime end,
  );

  Future<AppResult<List<TransactionEntity>>> getTransactionsByMonth(
    int year,
    int month,
  );

  Future<AppResult<int>> createTransaction(TransactionEntity transaction);

  Future<AppResult<bool>> updateTransaction(TransactionEntity transaction);

  /// Reverses the account balance effect before deleting.
  Future<AppResult<int>> deleteTransaction(TransactionEntity transaction);
}
