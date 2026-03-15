import '../../../../core/error/app_result.dart';
import '../entities/goal_entity.dart';
import '../repositories/i_goals_repository.dart';

class UpdateGoalUseCase {
  final IGoalsRepository _repository;
  const UpdateGoalUseCase(this._repository);

  Future<AppResult<bool>> call(GoalEntity goal) => _repository.updateGoal(goal);
}
