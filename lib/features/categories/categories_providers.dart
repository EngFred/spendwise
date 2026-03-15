import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/providers/app_providers.dart';
import 'data/datasources/categories_local_datasource.dart';
import 'data/repositories/categories_repository_impl.dart';
import 'domain/repositories/i_categories_repository.dart';
import 'domain/usecases/create_category_usecase.dart';
import 'domain/usecases/delete_category_usecase.dart';
import 'domain/usecases/get_all_categories_usecase.dart';
import 'domain/usecases/get_categories_by_type_usecase.dart';
import 'domain/usecases/update_category_usecase.dart';
import 'domain/usecases/watch_all_categories_usecase.dart';

// ── Datasource ────────────────────────────────────────────────────────────────

final categoriesLocalDatasourceProvider = Provider<ICategoriesLocalDatasource>((
  ref,
) {
  return CategoriesLocalDatasource(
    ref.watch(appDatabaseProvider).categoriesDao,
  );
});

// ── Repository ────────────────────────────────────────────────────────────────

final categoriesRepositoryProvider = Provider<ICategoriesRepository>((ref) {
  return CategoriesRepositoryImpl(ref.watch(categoriesLocalDatasourceProvider));
});

// ── Use Cases ─────────────────────────────────────────────────────────────────

final watchAllCategoriesUseCaseProvider = Provider(
  (ref) => WatchAllCategoriesUseCase(ref.watch(categoriesRepositoryProvider)),
);

final getAllCategoriesUseCaseProvider = Provider(
  (ref) => GetAllCategoriesUseCase(ref.watch(categoriesRepositoryProvider)),
);

final getCategoriesByTypeUseCaseProvider = Provider(
  (ref) => GetCategoriesByTypeUseCase(ref.watch(categoriesRepositoryProvider)),
);

final createCategoryUseCaseProvider = Provider(
  (ref) => CreateCategoryUseCase(ref.watch(categoriesRepositoryProvider)),
);

final updateCategoryUseCaseProvider = Provider(
  (ref) => UpdateCategoryUseCase(ref.watch(categoriesRepositoryProvider)),
);

final deleteCategoryUseCaseProvider = Provider(
  (ref) => DeleteCategoryUseCase(ref.watch(categoriesRepositoryProvider)),
);
