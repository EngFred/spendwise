import '../../../../core/error/app_result.dart';
import '../entities/account_entity.dart';
import '../repositories/i_accounts_repository.dart';

class CreateAccountParams {
  final String name;
  final String type;
  final double balance;
  final String color;
  final String icon;
  final String currency;
  final bool isDefault;

  const CreateAccountParams({
    required this.name,
    required this.type,
    required this.balance,
    required this.color,
    required this.icon,
    this.currency = 'UGX',
    this.isDefault = false,
  });
}

class CreateAccountUseCase {
  final IAccountsRepository _repository;
  const CreateAccountUseCase(this._repository);

  Future<AppResult<int>> call(CreateAccountParams params) {
    final entity = AccountEntity(
      name: params.name,
      type: params.type,
      balance: params.balance,
      color: params.color,
      icon: params.icon,
      currency: params.currency,
      isDefault: params.isDefault,
      createdAt: DateTime.now(),
    );
    return _repository.createAccount(entity);
  }
}
