import '../../../../core/error/app_result.dart';
import '../entities/category_entity.dart';
import '../repositories/i_categories_repository.dart';

class GetAllCategoriesUseCase {
  final ICategoriesRepository _repository;
  const GetAllCategoriesUseCase(this._repository);

  Future<AppResult<List<CategoryEntity>>> call() =>
      _repository.getAllCategories();
}
