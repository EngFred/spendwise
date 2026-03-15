import '../entities/category_entity.dart';
import '../repositories/i_categories_repository.dart';

class WatchAllCategoriesUseCase {
  final ICategoriesRepository _repository;
  const WatchAllCategoriesUseCase(this._repository);

  Stream<List<CategoryEntity>> call() => _repository.watchAllCategories();
}
