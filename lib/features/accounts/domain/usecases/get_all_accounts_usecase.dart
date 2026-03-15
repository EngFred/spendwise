import '../../../../core/error/app_result.dart';
import '../entities/account_entity.dart';
import '../repositories/i_accounts_repository.dart';

class GetAllAccountsUseCase {
  final IAccountsRepository _repository;
  const GetAllAccountsUseCase(this._repository);

  Future<AppResult<List<AccountEntity>>> call() => _repository.getAllAccounts();
}
