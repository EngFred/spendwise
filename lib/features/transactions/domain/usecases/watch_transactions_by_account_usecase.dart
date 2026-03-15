import '../entities/transaction_entity.dart';
import '../repositories/i_transactions_repository.dart';

class WatchTransactionsByAccountUseCase {
  final ITransactionsRepository _repository;
  const WatchTransactionsByAccountUseCase(this._repository);

  Stream<List<TransactionEntity>> call(int accountId) =>
      _repository.watchTransactionsByAccount(accountId);
}
