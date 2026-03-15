import '../../../../core/error/app_result.dart';
import '../entities/goal_entity.dart';

abstract interface class IGoalsRepository {
  Stream<List<GoalEntity>> watchAllGoals();

  Future<AppResult<List<GoalEntity>>> getAllGoals();

  Future<AppResult<int>> createGoal(GoalEntity goal);

  Future<AppResult<bool>> updateGoal(GoalEntity goal);

  Future<AppResult<void>> addToSavings(int id, double amount);

  Future<AppResult<int>> deleteGoal(int id);
}
