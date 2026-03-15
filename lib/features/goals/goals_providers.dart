import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/providers/app_providers.dart';
import 'data/datasources/goals_local_datasource.dart';
import 'data/repositories/goals_repository_impl.dart';
import 'domain/repositories/i_goals_repository.dart';
import 'domain/usecases/add_to_savings_usecase.dart';
import 'domain/usecases/create_goal_usecase.dart';
import 'domain/usecases/delete_goal_usecase.dart';
import 'domain/usecases/get_all_goals_usecase.dart';
import 'domain/usecases/update_goal_usecase.dart';
import 'domain/usecases/watch_all_goals_usecase.dart';

// ── Datasource ────────────────────────────────────────────────────────────────

final goalsLocalDatasourceProvider = Provider<IGoalsLocalDatasource>((ref) {
  return GoalsLocalDatasource(ref.watch(appDatabaseProvider).goalsDao);
});

// ── Repository ────────────────────────────────────────────────────────────────

final goalsRepositoryProvider = Provider<IGoalsRepository>((ref) {
  return GoalsRepositoryImpl(ref.watch(goalsLocalDatasourceProvider));
});

// ── Use Cases ─────────────────────────────────────────────────────────────────

final watchAllGoalsUseCaseProvider = Provider(
  (ref) => WatchAllGoalsUseCase(ref.watch(goalsRepositoryProvider)),
);

final getAllGoalsUseCaseProvider = Provider(
  (ref) => GetAllGoalsUseCase(ref.watch(goalsRepositoryProvider)),
);

final createGoalUseCaseProvider = Provider(
  (ref) => CreateGoalUseCase(ref.watch(goalsRepositoryProvider)),
);

final updateGoalUseCaseProvider = Provider(
  (ref) => UpdateGoalUseCase(ref.watch(goalsRepositoryProvider)),
);

final addToSavingsUseCaseProvider = Provider(
  (ref) => AddToSavingsUseCase(ref.watch(goalsRepositoryProvider)),
);

final deleteGoalUseCaseProvider = Provider(
  (ref) => DeleteGoalUseCase(ref.watch(goalsRepositoryProvider)),
);
