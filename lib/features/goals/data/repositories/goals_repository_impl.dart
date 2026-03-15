import '../../../../core/error/app_result.dart';
import '../../../../core/utils/app_logger.dart';
import '../../domain/entities/goal_entity.dart';
import '../../domain/repositories/i_goals_repository.dart';
import '../datasources/goals_local_datasource.dart';
import '../models/goal_model.dart';

class GoalsRepositoryImpl implements IGoalsRepository {
  final IGoalsLocalDatasource _localDatasource;
  const GoalsRepositoryImpl(this._localDatasource);

  @override
  Stream<List<GoalEntity>> watchAllGoals() {
    AppLogger.info('GoalsRepository: watchAllGoals()');
    return _localDatasource.watchAllGoals().map(
      (rows) => rows.map(GoalModel.fromDrift).toList(),
    );
  }

  @override
  Future<AppResult<List<GoalEntity>>> getAllGoals() async {
    try {
      final rows = await _localDatasource.getAllGoals();
      final entities = rows.map(GoalModel.fromDrift).toList();
      AppLogger.info('GoalsRepository: fetched ${entities.length} goals');
      return Success(entities);
    } catch (e, st) {
      AppLogger.error('GoalsRepository: getAllGoals failed', e, st);
      return Failure('Failed to load goals: $e');
    }
  }

  @override
  Future<AppResult<int>> createGoal(GoalEntity goal) async {
    try {
      final id = await _localDatasource.insertGoal(
        GoalModel.toInsertCompanion(goal),
      );
      AppLogger.info('GoalsRepository: created goal id=$id');
      return Success(id);
    } catch (e, st) {
      AppLogger.error('GoalsRepository: createGoal failed', e, st);
      return Failure('Failed to create goal: $e');
    }
  }

  @override
  Future<AppResult<bool>> updateGoal(GoalEntity goal) async {
    try {
      final updated = await _localDatasource.updateGoal(
        GoalModel.toUpdateCompanion(goal),
      );
      AppLogger.info('GoalsRepository: updated goal id=${goal.id}');
      return Success(updated);
    } catch (e, st) {
      AppLogger.error('GoalsRepository: updateGoal failed', e, st);
      return Failure('Failed to update goal: $e');
    }
  }

  @override
  Future<AppResult<void>> addToSavings(int id, double amount) async {
    try {
      // Fetch current goal, compute new saved amount, persist
      final rows = await _localDatasource.getAllGoals();
      final row = rows.firstWhere((g) => g.id == id);
      final newAmount = row.savedAmount + amount;
      await _localDatasource.updateSavedAmount(id, newAmount);
      AppLogger.info(
        'GoalsRepository: addToSavings id=$id → newAmount=$newAmount',
      );
      return const Success(null);
    } catch (e, st) {
      AppLogger.error('GoalsRepository: addToSavings failed', e, st);
      return Failure('Failed to add savings: $e');
    }
  }

  @override
  Future<AppResult<int>> deleteGoal(int id) async {
    try {
      final count = await _localDatasource.deleteGoal(id);
      AppLogger.info('GoalsRepository: deleted goal id=$id');
      return Success(count);
    } catch (e, st) {
      AppLogger.error('GoalsRepository: deleteGoal($id) failed', e, st);
      return Failure('Failed to delete goal: $e');
    }
  }
}
