import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/providers/app_providers.dart';
import 'data/datasources/accounts_local_datasource.dart';
import 'data/repositories/accounts_repository_impl.dart';
import 'domain/repositories/i_accounts_repository.dart';
import 'domain/usecases/create_account_usecase.dart';
import 'domain/usecases/delete_account_usecase.dart';
import 'domain/usecases/get_all_accounts_usecase.dart';
import 'domain/usecases/update_account_usecase.dart';
import 'domain/usecases/update_balance_usecase.dart';
import 'domain/usecases/watch_all_accounts_usecase.dart';

// ── Datasource ────────────────────────────────────────────────────────────────

final accountsLocalDatasourceProvider = Provider<IAccountsLocalDatasource>((
  ref,
) {
  return AccountsLocalDatasource(ref.watch(appDatabaseProvider).accountsDao);
});

// ── Repository ────────────────────────────────────────────────────────────────

final accountsRepositoryProvider = Provider<IAccountsRepository>((ref) {
  return AccountsRepositoryImpl(ref.watch(accountsLocalDatasourceProvider));
});

// ── Use Cases ─────────────────────────────────────────────────────────────────

final watchAllAccountsUseCaseProvider = Provider(
  (ref) => WatchAllAccountsUseCase(ref.watch(accountsRepositoryProvider)),
);

final getAllAccountsUseCaseProvider = Provider(
  (ref) => GetAllAccountsUseCase(ref.watch(accountsRepositoryProvider)),
);

final createAccountUseCaseProvider = Provider(
  (ref) => CreateAccountUseCase(ref.watch(accountsRepositoryProvider)),
);

final updateAccountUseCaseProvider = Provider(
  (ref) => UpdateAccountUseCase(ref.watch(accountsRepositoryProvider)),
);

final deleteAccountUseCaseProvider = Provider(
  (ref) => DeleteAccountUseCase(ref.watch(accountsRepositoryProvider)),
);

final updateBalanceUseCaseProvider = Provider(
  (ref) => UpdateBalanceUseCase(ref.watch(accountsRepositoryProvider)),
);
