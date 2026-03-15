import '../../../../core/error/app_result.dart';
import '../entities/transaction_entity.dart';
import '../repositories/i_transactions_repository.dart';

class CreateTransactionParams {
  final double amount;
  final String type;
  final int accountId;
  final int categoryId;
  final DateTime date;
  final String? note;
  final bool isRecurring;
  final String? recurringInterval;

  const CreateTransactionParams({
    required this.amount,
    required this.type,
    required this.accountId,
    required this.categoryId,
    required this.date,
    this.note,
    this.isRecurring = false,
    this.recurringInterval,
  });
}

class CreateTransactionUseCase {
  final ITransactionsRepository _repository;
  const CreateTransactionUseCase(this._repository);

  Future<AppResult<int>> call(CreateTransactionParams params) {
    final entity = TransactionEntity(
      amount: params.amount,
      type: params.type,
      accountId: params.accountId,
      categoryId: params.categoryId,
      date: params.date,
      note: params.note,
      isRecurring: params.isRecurring,
      recurringInterval: params.recurringInterval,
      createdAt: DateTime.now(),
    );
    return _repository.createTransaction(entity);
  }
}
