import '../../../../core/error/app_result.dart';
import '../entities/category_entity.dart';
import '../repositories/i_categories_repository.dart';

class CreateCategoryParams {
  final String name;
  final String icon;
  final String color;
  final String type;
  final bool isDefault;

  const CreateCategoryParams({
    required this.name,
    required this.icon,
    required this.color,
    required this.type,
    this.isDefault = false,
  });
}

class CreateCategoryUseCase {
  final ICategoriesRepository _repository;
  const CreateCategoryUseCase(this._repository);

  Future<AppResult<int>> call(CreateCategoryParams params) {
    final entity = CategoryEntity(
      name: params.name,
      icon: params.icon,
      color: params.color,
      type: params.type,
      isDefault: params.isDefault,
    );
    return _repository.createCategory(entity);
  }
}
