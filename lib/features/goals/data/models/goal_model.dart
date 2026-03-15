import 'package:drift/drift.dart';
import '../../../../database/app_database.dart';
import '../../domain/entities/goal_entity.dart';

class GoalModel {
  GoalModel._();

  static GoalEntity fromDrift(Goal goal) => GoalEntity(
    id: goal.id,
    name: goal.name,
    icon: goal.icon,
    color: goal.color,
    targetAmount: goal.targetAmount,
    savedAmount: goal.savedAmount,
    deadline: goal.deadline,
    isCompleted: goal.isCompleted,
    createdAt: goal.createdAt,
  );

  static GoalsCompanion toInsertCompanion(GoalEntity entity) =>
      GoalsCompanion.insert(
        name: entity.name,
        icon: entity.icon,
        color: entity.color,
        targetAmount: entity.targetAmount,
        savedAmount: Value(entity.savedAmount),
        deadline: Value(entity.deadline),
        isCompleted: Value(entity.isCompleted),
      );

  static GoalsCompanion toUpdateCompanion(GoalEntity entity) => GoalsCompanion(
    id: Value(entity.id!),
    name: Value(entity.name),
    icon: Value(entity.icon),
    color: Value(entity.color),
    targetAmount: Value(entity.targetAmount),
    savedAmount: Value(entity.savedAmount),
    deadline: Value(entity.deadline),
    isCompleted: Value(entity.isCompleted),
    createdAt: Value(entity.createdAt),
  );
}
