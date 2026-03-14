import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/providers/app_providers.dart';
import '../../../database/app_database.dart';

final budgetsStreamProvider = StreamProvider<List<Budget>>((ref) {
  return ref.watch(budgetsRepositoryProvider).watchActiveBudgets();
});

class BudgetsNotifier extends AsyncNotifier<List<Budget>> {
  @override
  Future<List<Budget>> build() async {
    return ref.watch(budgetsRepositoryProvider).getActiveBudgets();
  }

  Future<void> createBudget({
    required int categoryId,
    required double amount,
    required String period,
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    await ref
        .read(budgetsRepositoryProvider)
        .createBudget(
          categoryId: categoryId,
          amount: amount,
          period: period,
          startDate: startDate,
          endDate: endDate,
        );
    ref.invalidateSelf();
  }

  Future<void> deleteBudget(int id) async {
    await ref.read(budgetsRepositoryProvider).deleteBudget(id);
    ref.invalidateSelf();
  }
}

final budgetsNotifierProvider =
    AsyncNotifierProvider<BudgetsNotifier, List<Budget>>(BudgetsNotifier.new);
