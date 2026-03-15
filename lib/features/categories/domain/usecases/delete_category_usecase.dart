import '../../../../core/error/app_result.dart';
import '../repositories/i_categories_repository.dart';

class DeleteCategoryUseCase {
  final ICategoriesRepository _repository;
  const DeleteCategoryUseCase(this._repository);

  Future<AppResult<int>> call(int id) => _repository.deleteCategory(id);
}
