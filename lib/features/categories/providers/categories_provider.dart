import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:spendwise/features/categories/categories_providers.dart';
import 'package:spendwise/features/categories/domain/entities/category_entity.dart';
import 'package:spendwise/features/categories/domain/usecases/create_category_usecase.dart';
import '../../../core/utils/app_logger.dart';

// ── Stream (reactive list for UI) ─────────────────────────────────────────────

final categoriesStreamProvider = StreamProvider<List<CategoryEntity>>((ref) {
  return ref.watch(watchAllCategoriesUseCaseProvider).call();
});

// ── Filtered stream providers (used in AddTransactionScreen) ──────────────────

final expenseCategoriesProvider = FutureProvider<List<CategoryEntity>>((
  ref,
) async {
  final result = await ref
      .watch(getCategoriesByTypeUseCaseProvider)
      .call('expense');
  return result.when(
    success: (data) => data,
    failure: (msg) {
      AppLogger.error('expenseCategoriesProvider failed: $msg');
      throw Exception(msg);
    },
  );
});

final incomeCategoriesProvider = FutureProvider<List<CategoryEntity>>((
  ref,
) async {
  final result = await ref
      .watch(getCategoriesByTypeUseCaseProvider)
      .call('income');
  return result.when(
    success: (data) => data,
    failure: (msg) {
      AppLogger.error('incomeCategoriesProvider failed: $msg');
      throw Exception(msg);
    },
  );
});

// ── Notifier (for mutations) ──────────────────────────────────────────────────

class CategoriesNotifier extends AsyncNotifier<List<CategoryEntity>> {
  @override
  Future<List<CategoryEntity>> build() async {
    final result = await ref.read(getAllCategoriesUseCaseProvider).call();
    return result.when(
      success: (data) => data,
      failure: (msg) {
        AppLogger.error('CategoriesNotifier.build failed: $msg');
        throw Exception(msg);
      },
    );
  }

  Future<void> createCategory(CreateCategoryParams params) async {
    final result = await ref.read(createCategoryUseCaseProvider).call(params);
    result.when(
      success: (_) {
        AppLogger.info('CategoriesNotifier: category created');
        ref.invalidateSelf();
      },
      failure: (msg) {
        AppLogger.error('CategoriesNotifier: createCategory failed — $msg');
        throw Exception(msg);
      },
    );
  }

  Future<void> deleteCategory(int id) async {
    final result = await ref.read(deleteCategoryUseCaseProvider).call(id);
    result.when(
      success: (_) {
        AppLogger.info('CategoriesNotifier: deleted category id=$id');
        ref.invalidateSelf();
      },
      failure: (msg) {
        AppLogger.error('CategoriesNotifier: deleteCategory failed — $msg');
        throw Exception(msg);
      },
    );
  }
}

final categoriesNotifierProvider =
    AsyncNotifierProvider<CategoriesNotifier, List<CategoryEntity>>(
      CategoriesNotifier.new,
    );
