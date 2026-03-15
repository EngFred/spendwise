import '../entities/transaction_entity.dart';
import '../repositories/i_transactions_repository.dart';

class WatchTransactionsByDateRangeUseCase {
  final ITransactionsRepository _repository;
  const WatchTransactionsByDateRangeUseCase(this._repository);

  Stream<List<TransactionEntity>> call(DateTime start, DateTime end) =>
      _repository.watchTransactionsByDateRange(start, end);
}
