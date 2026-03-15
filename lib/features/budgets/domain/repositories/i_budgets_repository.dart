import '../../../../core/error/app_result.dart';
import '../entities/budget_entity.dart';

abstract interface class IBudgetsRepository {
  Stream<List<BudgetEntity>> watchActiveBudgets();

  Future<AppResult<List<BudgetEntity>>> getActiveBudgets();

  Future<AppResult<int>> createBudget(BudgetEntity budget);

  Future<AppResult<bool>> updateBudget(BudgetEntity budget);

  Future<AppResult<int>> deleteBudget(int id);
}
