import '../entities/goal_entity.dart';
import '../repositories/i_goals_repository.dart';

class WatchAllGoalsUseCase {
  final IGoalsRepository _repository;
  const WatchAllGoalsUseCase(this._repository);

  Stream<List<GoalEntity>> call() => _repository.watchAllGoals();
}
