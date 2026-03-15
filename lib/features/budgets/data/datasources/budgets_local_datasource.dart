import '../../../../core/utils/app_logger.dart';
import '../../../../database/app_database.dart';
import '../../../../database/daos/budgets_dao.dart';

abstract interface class IBudgetsLocalDatasource {
  Stream<List<Budget>> watchActiveBudgets();
  Future<List<Budget>> getActiveBudgets();
  Future<int> insertBudget(BudgetsCompanion companion);
  Future<bool> updateBudget(BudgetsCompanion companion);
  Future<int> deleteBudget(int id);
}

class BudgetsLocalDatasource implements IBudgetsLocalDatasource {
  final BudgetsDao _dao;
  const BudgetsLocalDatasource(this._dao);

  @override
  Stream<List<Budget>> watchActiveBudgets() {
    AppLogger.trace('BudgetsLocalDatasource: watchActiveBudgets()');
    return _dao.watchActiveBudgets();
  }

  @override
  Future<List<Budget>> getActiveBudgets() {
    AppLogger.trace('BudgetsLocalDatasource: getActiveBudgets()');
    return _dao.getActiveBudgets();
  }

  @override
  Future<int> insertBudget(BudgetsCompanion companion) {
    AppLogger.debug('BudgetsLocalDatasource: insertBudget()');
    return _dao.insertBudget(companion);
  }

  @override
  Future<bool> updateBudget(BudgetsCompanion companion) {
    AppLogger.debug('BudgetsLocalDatasource: updateBudget()');
    return _dao.updateBudget(companion);
  }

  @override
  Future<int> deleteBudget(int id) {
    AppLogger.debug('BudgetsLocalDatasource: deleteBudget($id)');
    return _dao.deleteBudget(id);
  }
}
