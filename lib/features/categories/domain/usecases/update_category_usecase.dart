import '../../../../core/error/app_result.dart';
import '../entities/category_entity.dart';
import '../repositories/i_categories_repository.dart';

class UpdateCategoryUseCase {
  final ICategoriesRepository _repository;
  const UpdateCategoryUseCase(this._repository);

  Future<AppResult<bool>> call(CategoryEntity category) =>
      _repository.updateCategory(category);
}
