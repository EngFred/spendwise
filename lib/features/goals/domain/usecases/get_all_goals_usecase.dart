import '../../../../core/error/app_result.dart';
import '../entities/goal_entity.dart';
import '../repositories/i_goals_repository.dart';

class GetAllGoalsUseCase {
  final IGoalsRepository _repository;
  const GetAllGoalsUseCase(this._repository);

  Future<AppResult<List<GoalEntity>>> call() => _repository.getAllGoals();
}
