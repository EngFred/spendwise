import '../entities/budget_entity.dart';
import '../repositories/i_budgets_repository.dart';

class WatchActiveBudgetsUseCase {
  final IBudgetsRepository _repository;
  const WatchActiveBudgetsUseCase(this._repository);

  Stream<List<BudgetEntity>> call() => _repository.watchActiveBudgets();
}
