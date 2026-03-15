import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/providers/app_providers.dart';
import 'data/datasources/budgets_local_datasource.dart';
import 'data/repositories/budgets_repository_impl.dart';
import 'domain/repositories/i_budgets_repository.dart';
import 'domain/usecases/create_budget_usecase.dart';
import 'domain/usecases/delete_budget_usecase.dart';
import 'domain/usecases/get_active_budgets_usecase.dart';
import 'domain/usecases/update_budget_usecase.dart';
import 'domain/usecases/watch_active_budgets_usecase.dart';

// ── Datasource ────────────────────────────────────────────────────────────────

final budgetsLocalDatasourceProvider = Provider<IBudgetsLocalDatasource>((ref) {
  return BudgetsLocalDatasource(ref.watch(appDatabaseProvider).budgetsDao);
});

// ── Repository ────────────────────────────────────────────────────────────────

final budgetsRepositoryProvider = Provider<IBudgetsRepository>((ref) {
  return BudgetsRepositoryImpl(ref.watch(budgetsLocalDatasourceProvider));
});

// ── Use Cases ─────────────────────────────────────────────────────────────────

final watchActiveBudgetsUseCaseProvider = Provider(
  (ref) => WatchActiveBudgetsUseCase(ref.watch(budgetsRepositoryProvider)),
);

final getActiveBudgetsUseCaseProvider = Provider(
  (ref) => GetActiveBudgetsUseCase(ref.watch(budgetsRepositoryProvider)),
);

final createBudgetUseCaseProvider = Provider(
  (ref) => CreateBudgetUseCase(ref.watch(budgetsRepositoryProvider)),
);

final updateBudgetUseCaseProvider = Provider(
  (ref) => UpdateBudgetUseCase(ref.watch(budgetsRepositoryProvider)),
);

final deleteBudgetUseCaseProvider = Provider(
  (ref) => DeleteBudgetUseCase(ref.watch(budgetsRepositoryProvider)),
);
