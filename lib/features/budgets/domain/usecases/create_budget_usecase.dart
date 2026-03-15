import '../../../../core/error/app_result.dart';
import '../entities/budget_entity.dart';
import '../repositories/i_budgets_repository.dart';

class CreateBudgetParams {
  final int categoryId;
  final double amount;
  final String period;
  final DateTime startDate;
  final DateTime endDate;

  const CreateBudgetParams({
    required this.categoryId,
    required this.amount,
    required this.period,
    required this.startDate,
    required this.endDate,
  });
}

class CreateBudgetUseCase {
  final IBudgetsRepository _repository;
  const CreateBudgetUseCase(this._repository);

  Future<AppResult<int>> call(CreateBudgetParams params) {
    final entity = BudgetEntity(
      categoryId: params.categoryId,
      amount: params.amount,
      period: params.period,
      startDate: params.startDate,
      endDate: params.endDate,
      isActive: true,
      createdAt: DateTime.now(),
    );
    return _repository.createBudget(entity);
  }
}
