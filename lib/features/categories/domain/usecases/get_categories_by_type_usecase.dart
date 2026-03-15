import '../../../../core/error/app_result.dart';
import '../entities/category_entity.dart';
import '../repositories/i_categories_repository.dart';

class GetCategoriesByTypeUseCase {
  final ICategoriesRepository _repository;
  const GetCategoriesByTypeUseCase(this._repository);

  Future<AppResult<List<CategoryEntity>>> call(String type) =>
      _repository.getCategoriesByType(type);
}
