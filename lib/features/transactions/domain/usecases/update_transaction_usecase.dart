import '../../../../core/error/app_result.dart';
import '../entities/transaction_entity.dart';
import '../repositories/i_transactions_repository.dart';

class UpdateTransactionUseCase {
  final ITransactionsRepository _repository;
  const UpdateTransactionUseCase(this._repository);

  Future<AppResult<bool>> call(TransactionEntity transaction) =>
      _repository.updateTransaction(transaction);
}
