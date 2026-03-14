import 'package:drift/drift.dart';
import '../../../database/app_database.dart';

class GoalsRepository {
  final AppDatabase _db;

  GoalsRepository(this._db);

  Stream<List<Goal>> watchAllGoals() => _db.goalsDao.watchAllGoals();

  Future<List<Goal>> getAllGoals() => _db.goalsDao.getAllGoals();

  Future<int> createGoal({
    required String name,
    required String icon,
    required String color,
    required double targetAmount,
    double savedAmount = 0.0,
    DateTime? deadline,
  }) {
    return _db.goalsDao.insertGoal(
      GoalsCompanion.insert(
        name: name,
        icon: icon,
        color: color,
        targetAmount: targetAmount,
        savedAmount: Value(savedAmount),
        deadline: Value(deadline),
      ),
    );
  }

  Future<bool> updateGoal(Goal goal) {
    return _db.goalsDao.updateGoal(goal.toCompanion(true));
  }

  Future<void> addToSavings(int id, double amount) async {
    final goal = (await _db.goalsDao.getAllGoals()).firstWhere(
      (g) => g.id == id,
    );
    final newAmount = goal.savedAmount + amount;
    await _db.goalsDao.updateSavedAmount(id, newAmount);
  }

  Future<int> deleteGoal(int id) => _db.goalsDao.deleteGoal(id);
}
