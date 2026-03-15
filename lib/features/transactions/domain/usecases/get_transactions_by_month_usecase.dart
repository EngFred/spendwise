import '../../../../core/error/app_result.dart';
import '../entities/transaction_entity.dart';
import '../repositories/i_transactions_repository.dart';

class GetTransactionsByMonthUseCase {
  final ITransactionsRepository _repository;
  const GetTransactionsByMonthUseCase(this._repository);

  Future<AppResult<List<TransactionEntity>>> call(int year, int month) =>
      _repository.getTransactionsByMonth(year, month);
}
