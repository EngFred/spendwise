import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/providers/app_providers.dart';
import '../accounts/accounts_providers.dart';
import 'data/datasources/transactions_local_datasource.dart';
import 'data/repositories/transactions_repository_impl.dart';
import 'domain/repositories/i_transactions_repository.dart';
import 'domain/usecases/create_transaction_usecase.dart';
import 'domain/usecases/delete_transaction_usecase.dart';
import 'domain/usecases/get_transactions_by_month_usecase.dart';
import 'domain/usecases/update_transaction_usecase.dart';
import 'domain/usecases/watch_all_transactions_usecase.dart';
import 'domain/usecases/watch_transactions_by_account_usecase.dart';
import 'domain/usecases/watch_transactions_by_date_range_usecase.dart';

// ── Datasource ────────────────────────────────────────────────────────────────

final transactionsLocalDatasourceProvider =
    Provider<ITransactionsLocalDatasource>((ref) {
      return TransactionsLocalDatasource(
        ref.watch(appDatabaseProvider).transactionsDao,
      );
    });

// ── Repository ────────────────────────────────────────────────────────────────

final transactionsRepositoryProvider = Provider<ITransactionsRepository>((ref) {
  return TransactionsRepositoryImpl(
    ref.watch(transactionsLocalDatasourceProvider),
    // Inject accounts datasource so balance updates stay in the data layer
    ref.watch(accountsLocalDatasourceProvider),
  );
});

// ── Use Cases ─────────────────────────────────────────────────────────────────

final watchAllTransactionsUseCaseProvider = Provider(
  (ref) =>
      WatchAllTransactionsUseCase(ref.watch(transactionsRepositoryProvider)),
);

final watchTransactionsByAccountUseCaseProvider = Provider(
  (ref) => WatchTransactionsByAccountUseCase(
    ref.watch(transactionsRepositoryProvider),
  ),
);

final watchTransactionsByDateRangeUseCaseProvider = Provider(
  (ref) => WatchTransactionsByDateRangeUseCase(
    ref.watch(transactionsRepositoryProvider),
  ),
);

final getTransactionsByMonthUseCaseProvider = Provider(
  (ref) =>
      GetTransactionsByMonthUseCase(ref.watch(transactionsRepositoryProvider)),
);

final createTransactionUseCaseProvider = Provider(
  (ref) => CreateTransactionUseCase(ref.watch(transactionsRepositoryProvider)),
);

final updateTransactionUseCaseProvider = Provider(
  (ref) => UpdateTransactionUseCase(ref.watch(transactionsRepositoryProvider)),
);

final deleteTransactionUseCaseProvider = Provider(
  (ref) => DeleteTransactionUseCase(ref.watch(transactionsRepositoryProvider)),
);
