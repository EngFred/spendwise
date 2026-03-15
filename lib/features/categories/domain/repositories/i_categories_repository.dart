import '../../../../core/error/app_result.dart';
import '../entities/category_entity.dart';

abstract interface class ICategoriesRepository {
  Stream<List<CategoryEntity>> watchAllCategories();

  Future<AppResult<List<CategoryEntity>>> getAllCategories();

  Future<AppResult<List<CategoryEntity>>> getCategoriesByType(String type);

  Future<AppResult<int>> createCategory(CategoryEntity category);

  Future<AppResult<bool>> updateCategory(CategoryEntity category);

  Future<AppResult<int>> deleteCategory(int id);
}
