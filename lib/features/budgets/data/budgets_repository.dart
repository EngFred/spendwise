import '../../../database/app_database.dart';

class BudgetsRepository {
  final AppDatabase _db;

  BudgetsRepository(this._db);

  Stream<List<Budget>> watchActiveBudgets() =>
      _db.budgetsDao.watchActiveBudgets();

  Future<List<Budget>> getActiveBudgets() => _db.budgetsDao.getActiveBudgets();

  Future<int> createBudget({
    required int categoryId,
    required double amount,
    required String period,
    required DateTime startDate,
    required DateTime endDate,
  }) {
    return _db.budgetsDao.insertBudget(
      BudgetsCompanion.insert(
        categoryId: categoryId,
        amount: amount,
        period: period,
        startDate: startDate,
        endDate: endDate,
      ),
    );
  }

  Future<bool> updateBudget(Budget budget) {
    return _db.budgetsDao.updateBudget(budget.toCompanion(true));
  }

  Future<int> deleteBudget(int id) => _db.budgetsDao.deleteBudget(id);
}
