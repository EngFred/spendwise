import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/providers/app_providers.dart';
import '../../../core/services/notification_service.dart';
import '../../../database/app_database.dart';

final goalsStreamProvider = StreamProvider<List<Goal>>((ref) {
  return ref.watch(goalsRepositoryProvider).watchAllGoals();
});

class GoalsNotifier extends AsyncNotifier<List<Goal>> {
  @override
  Future<List<Goal>> build() async {
    return ref.watch(goalsRepositoryProvider).getAllGoals();
  }

  Future<void> createGoal({
    required String name,
    required String icon,
    required String color,
    required double targetAmount,
    double savedAmount = 0.0,
    DateTime? deadline,
  }) async {
    await ref
        .read(goalsRepositoryProvider)
        .createGoal(
          name: name,
          icon: icon,
          color: color,
          targetAmount: targetAmount,
          savedAmount: savedAmount,
          deadline: deadline,
        );
    ref.invalidateSelf();
  }

  Future<void> addToSavings(int id, double amount) async {
    await ref.read(goalsRepositoryProvider).addToSavings(id, amount);

    // Check if goal is now complete
    final goals = await ref.read(goalsRepositoryProvider).getAllGoals();
    final goal = goals.where((g) => g.id == id).firstOrNull;

    if (goal != null && goal.savedAmount >= goal.targetAmount) {
      await ref
          .read(goalsRepositoryProvider)
          .updateGoal(goal.copyWith(isCompleted: true));
      await NotificationService.instance.showGoalReachedNotification(
        goalName: goal.name,
      );
    }

    ref.invalidateSelf();
  }

  Future<void> deleteGoal(int id) async {
    await ref.read(goalsRepositoryProvider).deleteGoal(id);
    ref.invalidateSelf();
  }
}

final goalsNotifierProvider = AsyncNotifierProvider<GoalsNotifier, List<Goal>>(
  GoalsNotifier.new,
);
