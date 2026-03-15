import '../../../../core/utils/app_logger.dart';
import '../../../../database/app_database.dart';
import '../../../../database/daos/goals_dao.dart';

abstract interface class IGoalsLocalDatasource {
  Stream<List<Goal>> watchAllGoals();
  Future<List<Goal>> getAllGoals();
  Future<int> insertGoal(GoalsCompanion companion);
  Future<bool> updateGoal(GoalsCompanion companion);
  Future<int> updateSavedAmount(int id, double amount);
  Future<int> deleteGoal(int id);
}

class GoalsLocalDatasource implements IGoalsLocalDatasource {
  final GoalsDao _dao;
  const GoalsLocalDatasource(this._dao);

  @override
  Stream<List<Goal>> watchAllGoals() {
    AppLogger.trace('GoalsLocalDatasource: watchAllGoals()');
    return _dao.watchAllGoals();
  }

  @override
  Future<List<Goal>> getAllGoals() {
    AppLogger.trace('GoalsLocalDatasource: getAllGoals()');
    return _dao.getAllGoals();
  }

  @override
  Future<int> insertGoal(GoalsCompanion companion) {
    AppLogger.debug('GoalsLocalDatasource: insertGoal()');
    return _dao.insertGoal(companion);
  }

  @override
  Future<bool> updateGoal(GoalsCompanion companion) {
    AppLogger.debug('GoalsLocalDatasource: updateGoal()');
    return _dao.updateGoal(companion);
  }

  @override
  Future<int> updateSavedAmount(int id, double amount) {
    AppLogger.debug(
      'GoalsLocalDatasource: updateSavedAmount(id: $id, amount: $amount)',
    );
    return _dao.updateSavedAmount(id, amount);
  }

  @override
  Future<int> deleteGoal(int id) {
    AppLogger.debug('GoalsLocalDatasource: deleteGoal($id)');
    return _dao.deleteGoal(id);
  }
}
