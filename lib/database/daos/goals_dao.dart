import 'package:drift/drift.dart';
import '../app_database.dart';
import '../tables/goals_table.dart';

part 'goals_dao.g.dart';

@DriftAccessor(tables: [Goals])
class GoalsDao extends DatabaseAccessor<AppDatabase> with _$GoalsDaoMixin {
  GoalsDao(super.db);

  Stream<List<Goal>> watchAllGoals() => select(goals).watch();

  Future<List<Goal>> getAllGoals() => select(goals).get();

  Future<int> insertGoal(GoalsCompanion goal) => into(goals).insert(goal);

  Future<bool> updateGoal(GoalsCompanion goal) => update(goals).replace(goal);

  Future<int> updateSavedAmount(int id, double amount) =>
      (update(goals)..where((g) => g.id.equals(id))).write(
        GoalsCompanion(savedAmount: Value(amount)),
      );

  Future<int> deleteGoal(int id) =>
      (delete(goals)..where((g) => g.id.equals(id))).go();
}
