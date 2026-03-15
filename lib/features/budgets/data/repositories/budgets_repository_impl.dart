import '../../../../core/error/app_result.dart';
import '../../../../core/utils/app_logger.dart';
import '../../domain/entities/budget_entity.dart';
import '../../domain/repositories/i_budgets_repository.dart';
import '../datasources/budgets_local_datasource.dart';
import '../models/budget_model.dart';

class BudgetsRepositoryImpl implements IBudgetsRepository {
  final IBudgetsLocalDatasource _localDatasource;
  const BudgetsRepositoryImpl(this._localDatasource);

  @override
  Stream<List<BudgetEntity>> watchActiveBudgets() {
    AppLogger.info('BudgetsRepository: watchActiveBudgets()');
    return _localDatasource.watchActiveBudgets().map(
      (rows) => rows.map(BudgetModel.fromDrift).toList(),
    );
  }

  @override
  Future<AppResult<List<BudgetEntity>>> getActiveBudgets() async {
    try {
      final rows = await _localDatasource.getActiveBudgets();
      final entities = rows.map(BudgetModel.fromDrift).toList();
      AppLogger.info('BudgetsRepository: fetched ${entities.length} budgets');
      return Success(entities);
    } catch (e, st) {
      AppLogger.error('BudgetsRepository: getActiveBudgets failed', e, st);
      return Failure('Failed to load budgets: $e');
    }
  }

  @override
  Future<AppResult<int>> createBudget(BudgetEntity budget) async {
    try {
      final id = await _localDatasource.insertBudget(
        BudgetModel.toInsertCompanion(budget),
      );
      AppLogger.info('BudgetsRepository: created budget id=$id');
      return Success(id);
    } catch (e, st) {
      AppLogger.error('BudgetsRepository: createBudget failed', e, st);
      return Failure('Failed to create budget: $e');
    }
  }

  @override
  Future<AppResult<bool>> updateBudget(BudgetEntity budget) async {
    try {
      final updated = await _localDatasource.updateBudget(
        BudgetModel.toUpdateCompanion(budget),
      );
      AppLogger.info('BudgetsRepository: updated budget id=${budget.id}');
      return Success(updated);
    } catch (e, st) {
      AppLogger.error('BudgetsRepository: updateBudget failed', e, st);
      return Failure('Failed to update budget: $e');
    }
  }

  @override
  Future<AppResult<int>> deleteBudget(int id) async {
    try {
      final count = await _localDatasource.deleteBudget(id);
      AppLogger.info('BudgetsRepository: deleted budget id=$id');
      return Success(count);
    } catch (e, st) {
      AppLogger.error('BudgetsRepository: deleteBudget($id) failed', e, st);
      return Failure('Failed to delete budget: $e');
    }
  }
}
