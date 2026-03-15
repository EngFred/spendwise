import '../../../../core/error/app_result.dart';
import '../entities/budget_entity.dart';
import '../repositories/i_budgets_repository.dart';

class GetActiveBudgetsUseCase {
  final IBudgetsRepository _repository;
  const GetActiveBudgetsUseCase(this._repository);

  Future<AppResult<List<BudgetEntity>>> call() =>
      _repository.getActiveBudgets();
}
