import 'package:drift/drift.dart';
import '../../../database/app_database.dart';

class AccountsRepository {
  final AppDatabase _db;

  AccountsRepository(this._db);

  Stream<List<Account>> watchAllAccounts() =>
      _db.accountsDao.watchAllAccounts();

  Future<List<Account>> getAllAccounts() => _db.accountsDao.getAllAccounts();

  Future<Account?> getAccountById(int id) => _db.accountsDao.getAccountById(id);

  Future<int> createAccount({
    required String name,
    required String type,
    required double balance,
    required String color,
    required String icon,
    String currency = 'UGX',
    bool isDefault = false,
  }) {
    return _db.accountsDao.insertAccount(
      AccountsCompanion.insert(
        name: name,
        type: type,
        balance: Value(balance),
        color: color,
        icon: icon,
        currency: Value(currency),
        isDefault: Value(isDefault),
      ),
    );
  }

  Future<bool> updateAccount(Account account) {
    return _db.accountsDao.updateAccount(account.toCompanion(true));
  }

  Future<int> deleteAccount(int id) => _db.accountsDao.deleteAccount(id);

  Future<void> updateBalance(int id, double newBalance) =>
      _db.accountsDao.updateBalance(id, newBalance);
}
