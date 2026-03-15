import '../../../../core/error/app_result.dart';
import '../entities/budget_entity.dart';
import '../repositories/i_budgets_repository.dart';

class UpdateBudgetUseCase {
  final IBudgetsRepository _repository;
  const UpdateBudgetUseCase(this._repository);

  Future<AppResult<bool>> call(BudgetEntity budget) =>
      _repository.updateBudget(budget);
}
