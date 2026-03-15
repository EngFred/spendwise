import '../../../../core/error/app_result.dart';
import '../entities/account_entity.dart';
import '../repositories/i_accounts_repository.dart';

class UpdateAccountUseCase {
  final IAccountsRepository _repository;
  const UpdateAccountUseCase(this._repository);

  Future<AppResult<bool>> call(AccountEntity account) =>
      _repository.updateAccount(account);
}
