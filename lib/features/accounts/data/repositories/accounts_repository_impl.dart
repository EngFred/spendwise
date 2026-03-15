import '../../../../core/error/app_result.dart';
import '../../../../core/utils/app_logger.dart';
import '../../domain/entities/account_entity.dart';
import '../../domain/repositories/i_accounts_repository.dart';
import '../datasources/accounts_local_datasource.dart';
import '../models/account_model.dart';

class AccountsRepositoryImpl implements IAccountsRepository {
  final IAccountsLocalDatasource _localDatasource;

  const AccountsRepositoryImpl(this._localDatasource);

  // ── Streams ──────────────────────────────────────────────────────────────

  @override
  Stream<List<AccountEntity>> watchAllAccounts() {
    AppLogger.info('AccountsRepository: watchAllAccounts()');
    return _localDatasource.watchAllAccounts().map(
      (rows) => rows.map(AccountModel.fromDrift).toList(),
    );
  }

  // ── Queries ───────────────────────────────────────────────────────────────

  @override
  Future<AppResult<List<AccountEntity>>> getAllAccounts() async {
    try {
      final rows = await _localDatasource.getAllAccounts();
      final entities = rows.map(AccountModel.fromDrift).toList();
      AppLogger.info('AccountsRepository: fetched ${entities.length} accounts');
      return Success(entities);
    } catch (e, st) {
      AppLogger.error('AccountsRepository: getAllAccounts failed', e, st);
      return Failure('Failed to load accounts: $e');
    }
  }

  @override
  Future<AppResult<AccountEntity?>> getAccountById(int id) async {
    try {
      final row = await _localDatasource.getAccountById(id);
      return Success(row != null ? AccountModel.fromDrift(row) : null);
    } catch (e, st) {
      AppLogger.error('AccountsRepository: getAccountById($id) failed', e, st);
      return Failure('Failed to load account: $e');
    }
  }

  // ── Mutations ─────────────────────────────────────────────────────────────

  @override
  Future<AppResult<int>> createAccount(AccountEntity account) async {
    try {
      final id = await _localDatasource.insertAccount(
        AccountModel.toInsertCompanion(account),
      );
      AppLogger.info('AccountsRepository: created account id=$id');
      return Success(id);
    } catch (e, st) {
      AppLogger.error('AccountsRepository: createAccount failed', e, st);
      return Failure('Failed to create account: $e');
    }
  }

  @override
  Future<AppResult<bool>> updateAccount(AccountEntity account) async {
    try {
      final updated = await _localDatasource.updateAccount(
        AccountModel.toUpdateCompanion(account),
      );
      AppLogger.info('AccountsRepository: updated account id=${account.id}');
      return Success(updated);
    } catch (e, st) {
      AppLogger.error('AccountsRepository: updateAccount failed', e, st);
      return Failure('Failed to update account: $e');
    }
  }

  @override
  Future<AppResult<int>> deleteAccount(int id) async {
    try {
      final count = await _localDatasource.deleteAccount(id);
      AppLogger.info('AccountsRepository: deleted account id=$id');
      return Success(count);
    } catch (e, st) {
      AppLogger.error('AccountsRepository: deleteAccount($id) failed', e, st);
      return Failure('Failed to delete account: $e');
    }
  }

  @override
  Future<AppResult<void>> updateBalance(int id, double newBalance) async {
    try {
      await _localDatasource.updateBalance(id, newBalance);
      AppLogger.info(
        'AccountsRepository: updated balance for id=$id → $newBalance',
      );
      return const Success(null);
    } catch (e, st) {
      AppLogger.error('AccountsRepository: updateBalance failed', e, st);
      return Failure('Failed to update balance: $e');
    }
  }
}
