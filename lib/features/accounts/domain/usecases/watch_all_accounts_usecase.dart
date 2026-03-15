import '../entities/account_entity.dart';
import '../repositories/i_accounts_repository.dart';

class WatchAllAccountsUseCase {
  final IAccountsRepository _repository;
  const WatchAllAccountsUseCase(this._repository);

  /// Returns a live stream — no AppResult wrapper needed for streams;
  /// errors propagate via the stream's error channel.
  Stream<List<AccountEntity>> call() => _repository.watchAllAccounts();
}
