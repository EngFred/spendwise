import '../../../../core/error/app_result.dart';
import '../repositories/i_budgets_repository.dart';

class DeleteBudgetUseCase {
  final IBudgetsRepository _repository;
  const DeleteBudgetUseCase(this._repository);

  Future<AppResult<int>> call(int id) => _repository.deleteBudget(id);
}
