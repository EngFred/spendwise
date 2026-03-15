import '../../../../core/error/app_result.dart';
import '../entities/transaction_entity.dart';
import '../repositories/i_transactions_repository.dart';

class DeleteTransactionUseCase {
  final ITransactionsRepository _repository;
  const DeleteTransactionUseCase(this._repository);

  /// Passing the full entity so the repository can reverse the balance effect.
  Future<AppResult<int>> call(TransactionEntity transaction) =>
      _repository.deleteTransaction(transaction);
}
