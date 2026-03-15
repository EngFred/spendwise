import '../../../../core/error/app_result.dart';
import '../repositories/i_accounts_repository.dart';

class DeleteAccountUseCase {
  final IAccountsRepository _repository;
  const DeleteAccountUseCase(this._repository);

  Future<AppResult<int>> call(int id) => _repository.deleteAccount(id);
}
