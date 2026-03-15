import 'package:spendwise/core/utils/app_logger.dart';
import '../../../../database/app_database.dart';
import '../../../../database/daos/accounts_dao.dart';

/// Thin wrapper around [AccountsDao].
/// Keeps the repository free from any Drift-specific types.
abstract interface class IAccountsLocalDatasource {
  Stream<List<Account>> watchAllAccounts();
  Future<List<Account>> getAllAccounts();
  Future<Account?> getAccountById(int id);
  Future<int> insertAccount(AccountsCompanion companion);
  Future<bool> updateAccount(AccountsCompanion companion);
  Future<int> deleteAccount(int id);
  Future<void> updateBalance(int id, double newBalance);
}

class AccountsLocalDatasource implements IAccountsLocalDatasource {
  final AccountsDao _dao;

  const AccountsLocalDatasource(this._dao);

  @override
  Stream<List<Account>> watchAllAccounts() {
    AppLogger.trace('AccountsLocalDatasource: watchAllAccounts()');
    return _dao.watchAllAccounts();
  }

  @override
  Future<List<Account>> getAllAccounts() {
    AppLogger.trace('AccountsLocalDatasource: getAllAccounts()');
    return _dao.getAllAccounts();
  }

  @override
  Future<Account?> getAccountById(int id) {
    AppLogger.trace('AccountsLocalDatasource: getAccountById($id)');
    return _dao.getAccountById(id);
  }

  @override
  Future<int> insertAccount(AccountsCompanion companion) {
    AppLogger.debug('AccountsLocalDatasource: insertAccount()');
    return _dao.insertAccount(companion);
  }

  @override
  Future<bool> updateAccount(AccountsCompanion companion) {
    AppLogger.debug('AccountsLocalDatasource: updateAccount()');
    return _dao.updateAccount(companion);
  }

  @override
  Future<int> deleteAccount(int id) {
    AppLogger.debug('AccountsLocalDatasource: deleteAccount($id)');
    return _dao.deleteAccount(id);
  }

  @override
  Future<void> updateBalance(int id, double newBalance) {
    AppLogger.debug(
      'AccountsLocalDatasource: updateBalance(id: $id, balance: $newBalance)',
    );
    return _dao.updateBalance(id, newBalance);
  }
}
