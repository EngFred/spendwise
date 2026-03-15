import '../../../../core/error/app_result.dart';
import '../../../../core/utils/app_logger.dart';
import '../../domain/entities/category_entity.dart';
import '../../domain/repositories/i_categories_repository.dart';
import '../datasources/categories_local_datasource.dart';
import '../models/category_model.dart';

class CategoriesRepositoryImpl implements ICategoriesRepository {
  final ICategoriesLocalDatasource _localDatasource;
  const CategoriesRepositoryImpl(this._localDatasource);

  @override
  Stream<List<CategoryEntity>> watchAllCategories() {
    AppLogger.info('CategoriesRepository: watchAllCategories()');
    return _localDatasource.watchAllCategories().map(
      (rows) => rows.map(CategoryModel.fromDrift).toList(),
    );
  }

  @override
  Future<AppResult<List<CategoryEntity>>> getAllCategories() async {
    try {
      final rows = await _localDatasource.getAllCategories();
      final entities = rows.map(CategoryModel.fromDrift).toList();
      AppLogger.info(
        'CategoriesRepository: fetched ${entities.length} categories',
      );
      return Success(entities);
    } catch (e, st) {
      AppLogger.error('CategoriesRepository: getAllCategories failed', e, st);
      return Failure('Failed to load categories: $e');
    }
  }

  @override
  Future<AppResult<List<CategoryEntity>>> getCategoriesByType(
    String type,
  ) async {
    try {
      final rows = await _localDatasource.getCategoriesByType(type);
      final entities = rows.map(CategoryModel.fromDrift).toList();
      AppLogger.info(
        'CategoriesRepository: fetched ${entities.length} $type categories',
      );
      return Success(entities);
    } catch (e, st) {
      AppLogger.error(
        'CategoriesRepository: getCategoriesByType($type) failed',
        e,
        st,
      );
      return Failure('Failed to load $type categories: $e');
    }
  }

  @override
  Future<AppResult<int>> createCategory(CategoryEntity category) async {
    try {
      final id = await _localDatasource.insertCategory(
        CategoryModel.toInsertCompanion(category),
      );
      AppLogger.info('CategoriesRepository: created category id=$id');
      return Success(id);
    } catch (e, st) {
      AppLogger.error('CategoriesRepository: createCategory failed', e, st);
      return Failure('Failed to create category: $e');
    }
  }

  @override
  Future<AppResult<bool>> updateCategory(CategoryEntity category) async {
    try {
      final updated = await _localDatasource.updateCategory(
        CategoryModel.toUpdateCompanion(category),
      );
      AppLogger.info(
        'CategoriesRepository: updated category id=${category.id}',
      );
      return Success(updated);
    } catch (e, st) {
      AppLogger.error('CategoriesRepository: updateCategory failed', e, st);
      return Failure('Failed to update category: $e');
    }
  }

  @override
  Future<AppResult<int>> deleteCategory(int id) async {
    try {
      final count = await _localDatasource.deleteCategory(id);
      AppLogger.info('CategoriesRepository: deleted category id=$id');
      return Success(count);
    } catch (e, st) {
      AppLogger.error(
        'CategoriesRepository: deleteCategory($id) failed',
        e,
        st,
      );
      return Failure('Failed to delete category: $e');
    }
  }
}
