import 'package:drift/drift.dart';
import '../../../../database/app_database.dart';
import '../../domain/entities/category_entity.dart';

class CategoryModel {
  CategoryModel._();

  static CategoryEntity fromDrift(Category category) => CategoryEntity(
    id: category.id,
    name: category.name,
    icon: category.icon,
    color: category.color,
    type: category.type,
    isDefault: category.isDefault,
  );

  static CategoriesCompanion toInsertCompanion(CategoryEntity entity) =>
      CategoriesCompanion.insert(
        name: entity.name,
        icon: entity.icon,
        color: entity.color,
        type: entity.type,
        isDefault: Value(entity.isDefault),
      );

  static CategoriesCompanion toUpdateCompanion(CategoryEntity entity) =>
      CategoriesCompanion(
        id: Value(entity.id!),
        name: Value(entity.name),
        icon: Value(entity.icon),
        color: Value(entity.color),
        type: Value(entity.type),
        isDefault: Value(entity.isDefault),
      );
}
