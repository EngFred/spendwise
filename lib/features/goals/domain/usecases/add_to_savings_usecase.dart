import '../../../../core/error/app_result.dart';
import '../repositories/i_goals_repository.dart';

class AddToSavingsParams {
  final int id;
  final double amount;
  const AddToSavingsParams({required this.id, required this.amount});
}

class AddToSavingsUseCase {
  final IGoalsRepository _repository;
  const AddToSavingsUseCase(this._repository);

  Future<AppResult<void>> call(AddToSavingsParams params) =>
      _repository.addToSavings(params.id, params.amount);
}
