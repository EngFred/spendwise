import '../entities/transaction_entity.dart';
import '../repositories/i_transactions_repository.dart';

class WatchAllTransactionsUseCase {
  final ITransactionsRepository _repository;
  const WatchAllTransactionsUseCase(this._repository);

  Stream<List<TransactionEntity>> call() => _repository.watchAllTransactions();
}
