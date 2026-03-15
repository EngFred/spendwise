import '../../../../core/utils/app_logger.dart';
import '../../../../database/app_database.dart';
import '../../../../database/daos/categories_dao.dart';

abstract interface class ICategoriesLocalDatasource {
  Stream<List<Category>> watchAllCategories();
  Future<List<Category>> getAllCategories();
  Future<List<Category>> getCategoriesByType(String type);
  Future<int> insertCategory(CategoriesCompanion companion);
  Future<bool> updateCategory(CategoriesCompanion companion);
  Future<int> deleteCategory(int id);
}

class CategoriesLocalDatasource implements ICategoriesLocalDatasource {
  final CategoriesDao _dao;
  const CategoriesLocalDatasource(this._dao);

  @override
  Stream<List<Category>> watchAllCategories() {
    AppLogger.trace('CategoriesLocalDatasource: watchAllCategories()');
    return _dao.watchAllCategories();
  }

  @override
  Future<List<Category>> getAllCategories() {
    AppLogger.trace('CategoriesLocalDatasource: getAllCategories()');
    return _dao.getAllCategories();
  }

  @override
  Future<List<Category>> getCategoriesByType(String type) {
    AppLogger.trace('CategoriesLocalDatasource: getCategoriesByType($type)');
    return _dao.getCategoriesByType(type);
  }

  @override
  Future<int> insertCategory(CategoriesCompanion companion) {
    AppLogger.debug('CategoriesLocalDatasource: insertCategory()');
    return _dao.insertCategory(companion);
  }

  @override
  Future<bool> updateCategory(CategoriesCompanion companion) {
    AppLogger.debug('CategoriesLocalDatasource: updateCategory()');
    return _dao.updateCategory(companion);
  }

  @override
  Future<int> deleteCategory(int id) {
    AppLogger.debug('CategoriesLocalDatasource: deleteCategory($id)');
    return _dao.deleteCategory(id);
  }
}
