import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/services/notification_service.dart';
import '../../../core/utils/app_logger.dart';
import '../domain/entities/goal_entity.dart';
import '../domain/usecases/add_to_savings_usecase.dart';
import '../domain/usecases/create_goal_usecase.dart';
import '../goals_providers.dart';

// ── Stream ────────────────────────────────────────────────────────────────────

final goalsStreamProvider = StreamProvider<List<GoalEntity>>((ref) {
  return ref.watch(watchAllGoalsUseCaseProvider).call();
});

// ── Notifier ──────────────────────────────────────────────────────────────────

class GoalsNotifier extends AsyncNotifier<List<GoalEntity>> {
  @override
  Future<List<GoalEntity>> build() async {
    final result = await ref.read(getAllGoalsUseCaseProvider).call();
    return result.when(
      success: (data) => data,
      failure: (msg) {
        AppLogger.error('GoalsNotifier.build failed: $msg');
        throw Exception(msg);
      },
    );
  }

  Future<void> createGoal(CreateGoalParams params) async {
    final result = await ref.read(createGoalUseCaseProvider).call(params);
    result.when(
      success: (_) {
        AppLogger.info('GoalsNotifier: goal created');
        ref.invalidateSelf();
      },
      failure: (msg) {
        AppLogger.error('GoalsNotifier: createGoal failed — $msg');
        throw Exception(msg);
      },
    );
  }

  // Public update — used by EditGoalScreen to persist name, icon, color,
  // target amount, and deadline changes.
  Future<void> updateGoal(GoalEntity goal) async {
    final result = await ref.read(updateGoalUseCaseProvider).call(goal);
    result.when(
      success: (_) {
        AppLogger.info('GoalsNotifier: updated goal id=${goal.id}');
        ref.invalidateSelf();
      },
      failure: (msg) {
        AppLogger.error('GoalsNotifier: updateGoal failed — $msg');
        throw Exception(msg);
      },
    );
  }

  Future<void> addToSavings(int id, double amount) async {
    final result = await ref
        .read(addToSavingsUseCaseProvider)
        .call(AddToSavingsParams(id: id, amount: amount));

    await result.when(
      success: (_) async {
        AppLogger.info('GoalsNotifier: added $amount to goal id=$id');

        final allResult = await ref.read(getAllGoalsUseCaseProvider).call();
        final goals = allResult.dataOrNull ?? [];
        final goal = goals.where((g) => g.id == id).firstOrNull;

        if (goal != null && goal.savedAmount >= goal.targetAmount) {
          final updatedGoal = goal.copyWith(isCompleted: true);
          await ref.read(updateGoalUseCaseProvider).call(updatedGoal);

          await NotificationService.instance.showGoalReachedNotification(
            goalName: goal.name,
          );
          AppLogger.info('GoalsNotifier: goal "${goal.name}" completed!');
        }

        ref.invalidateSelf();
      },
      failure: (msg) {
        AppLogger.error('GoalsNotifier: addToSavings failed — $msg');
        throw Exception(msg);
      },
    );
  }

  Future<void> deleteGoal(int id) async {
    final result = await ref.read(deleteGoalUseCaseProvider).call(id);
    result.when(
      success: (_) {
        AppLogger.info('GoalsNotifier: deleted goal id=$id');
        ref.invalidateSelf();
      },
      failure: (msg) {
        AppLogger.error('GoalsNotifier: deleteGoal failed — $msg');
        throw Exception(msg);
      },
    );
  }
}

final goalsNotifierProvider =
    AsyncNotifierProvider<GoalsNotifier, List<GoalEntity>>(GoalsNotifier.new);
