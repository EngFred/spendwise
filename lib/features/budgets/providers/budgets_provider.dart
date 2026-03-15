import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:spendwise/features/budgets/domain/usecases/create_budget_usecase.dart'
    show CreateBudgetParams;
import '../../../core/utils/app_logger.dart';
import '../budgets_providers.dart';
import '../domain/entities/budget_entity.dart';

// ── Stream ────────────────────────────────────────────────────────────────────

final budgetsStreamProvider = StreamProvider<List<BudgetEntity>>((ref) {
  return ref.watch(watchActiveBudgetsUseCaseProvider).call();
});

// ── Notifier ──────────────────────────────────────────────────────────────────

class BudgetsNotifier extends AsyncNotifier<List<BudgetEntity>> {
  @override
  Future<List<BudgetEntity>> build() async {
    final result = await ref.read(getActiveBudgetsUseCaseProvider).call();
    return result.when(
      success: (data) => data,
      failure: (msg) {
        AppLogger.error('BudgetsNotifier.build failed: $msg');
        throw Exception(msg);
      },
    );
  }

  Future<void> createBudget(CreateBudgetParams params) async {
    final result = await ref.read(createBudgetUseCaseProvider).call(params);
    result.when(
      success: (_) {
        AppLogger.info('BudgetsNotifier: budget created');
        ref.invalidateSelf();
      },
      failure: (msg) {
        AppLogger.error('BudgetsNotifier: createBudget failed — $msg');
        throw Exception(msg);
      },
    );
  }

  Future<void> deleteBudget(int id) async {
    final result = await ref.read(deleteBudgetUseCaseProvider).call(id);
    result.when(
      success: (_) {
        AppLogger.info('BudgetsNotifier: deleted budget id=$id');
        ref.invalidateSelf();
      },
      failure: (msg) {
        AppLogger.error('BudgetsNotifier: deleteBudget failed — $msg');
        throw Exception(msg);
      },
    );
  }
}

final budgetsNotifierProvider =
    AsyncNotifierProvider<BudgetsNotifier, List<BudgetEntity>>(
      BudgetsNotifier.new,
    );
