import '../../../../core/error/app_result.dart';
import '../repositories/i_goals_repository.dart';

class DeleteGoalUseCase {
  final IGoalsRepository _repository;
  const DeleteGoalUseCase(this._repository);

  Future<AppResult<int>> call(int id) => _repository.deleteGoal(id);
}
