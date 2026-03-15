import '../../../../core/error/app_result.dart';
import '../entities/goal_entity.dart';
import '../repositories/i_goals_repository.dart';

class CreateGoalParams {
  final String name;
  final String icon;
  final String color;
  final double targetAmount;
  final double savedAmount;
  final DateTime? deadline;

  const CreateGoalParams({
    required this.name,
    required this.icon,
    required this.color,
    required this.targetAmount,
    this.savedAmount = 0.0,
    this.deadline,
  });
}

class CreateGoalUseCase {
  final IGoalsRepository _repository;
  const CreateGoalUseCase(this._repository);

  Future<AppResult<int>> call(CreateGoalParams params) {
    final entity = GoalEntity(
      name: params.name,
      icon: params.icon,
      color: params.color,
      targetAmount: params.targetAmount,
      savedAmount: params.savedAmount,
      deadline: params.deadline,
      isCompleted: false,
      createdAt: DateTime.now(),
    );
    return _repository.createGoal(entity);
  }
}
