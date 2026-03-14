import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/providers/app_providers.dart';
import '../../../database/app_database.dart';

final categoriesStreamProvider = StreamProvider<List<Category>>((ref) {
  return ref.watch(categoriesRepositoryProvider).watchAllCategories();
});

final expenseCategoriesProvider = FutureProvider<List<Category>>((ref) {
  return ref.watch(categoriesRepositoryProvider).getCategoriesByType('expense');
});

final incomeCategoriesProvider = FutureProvider<List<Category>>((ref) {
  return ref.watch(categoriesRepositoryProvider).getCategoriesByType('income');
});

class CategoriesNotifier extends AsyncNotifier<List<Category>> {
  @override
  Future<List<Category>> build() async {
    return ref.watch(categoriesRepositoryProvider).getAllCategories();
  }

  Future<void> createCategory({
    required String name,
    required String icon,
    required String color,
    required String type,
  }) async {
    await ref
        .read(categoriesRepositoryProvider)
        .createCategory(name: name, icon: icon, color: color, type: type);
    ref.invalidateSelf();
  }

  Future<void> deleteCategory(int id) async {
    await ref.read(categoriesRepositoryProvider).deleteCategory(id);
    ref.invalidateSelf();
  }
}

final categoriesNotifierProvider =
    AsyncNotifierProvider<CategoriesNotifier, List<Category>>(
      CategoriesNotifier.new,
    );
