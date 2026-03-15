import '../../../../core/error/app_result.dart';
import '../repositories/i_accounts_repository.dart';

class UpdateBalanceParams {
  final int id;
  final double newBalance;
  const UpdateBalanceParams({required this.id, required this.newBalance});
}

class UpdateBalanceUseCase {
  final IAccountsRepository _repository;
  const UpdateBalanceUseCase(this._repository);

  Future<AppResult<void>> call(UpdateBalanceParams params) =>
      _repository.updateBalance(params.id, params.newBalance);
}
