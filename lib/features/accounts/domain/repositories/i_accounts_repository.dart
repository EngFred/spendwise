import '../../../../core/error/app_result.dart';
import '../entities/account_entity.dart';

/// Contract the data layer must fulfil.
/// The domain and presentation layers depend ONLY on this interface.
abstract interface class IAccountsRepository {
  /// Live stream — emits whenever accounts change in the DB.
  Stream<List<AccountEntity>> watchAllAccounts();

  Future<AppResult<List<AccountEntity>>> getAllAccounts();

  Future<AppResult<AccountEntity?>> getAccountById(int id);

  Future<AppResult<int>> createAccount(AccountEntity account);

  Future<AppResult<bool>> updateAccount(AccountEntity account);

  Future<AppResult<int>> deleteAccount(int id);

  Future<AppResult<void>> updateBalance(int id, double newBalance);
}
