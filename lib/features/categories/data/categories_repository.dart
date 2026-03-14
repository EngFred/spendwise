import 'package:drift/drift.dart';
import '../../../database/app_database.dart';

class CategoriesRepository {
  final AppDatabase _db;

  CategoriesRepository(this._db);

  Stream<List<Category>> watchAllCategories() =>
      _db.categoriesDao.watchAllCategories();

  Future<List<Category>> getAllCategories() =>
      _db.categoriesDao.getAllCategories();

  Future<List<Category>> getCategoriesByType(String type) =>
      _db.categoriesDao.getCategoriesByType(type);

  Future<int> createCategory({
    required String name,
    required String icon,
    required String color,
    required String type,
    bool isDefault = false,
  }) {
    return _db.categoriesDao.insertCategory(
      CategoriesCompanion.insert(
        name: name,
        icon: icon,
        color: color,
        type: type,
        isDefault: Value(isDefault),
      ),
    );
  }

  Future<bool> updateCategory(Category category) {
    return _db.categoriesDao.updateCategory(category.toCompanion(true));
  }

  Future<int> deleteCategory(int id) => _db.categoriesDao.deleteCategory(id);
}
