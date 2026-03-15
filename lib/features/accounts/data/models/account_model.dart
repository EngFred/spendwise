import 'package:drift/drift.dart';
import '../../../../database/app_database.dart';
import '../../domain/entities/account_entity.dart';

/// Responsible for mapping between the Drift [Account] row
/// and the domain [AccountEntity]. No business logic here.
class AccountModel {
  AccountModel._();

  static AccountEntity fromDrift(Account account) => AccountEntity(
    id: account.id,
    name: account.name,
    type: account.type,
    balance: account.balance,
    currency: account.currency,
    color: account.color,
    icon: account.icon,
    isDefault: account.isDefault,
    createdAt: account.createdAt,
  );

  static AccountsCompanion toInsertCompanion(AccountEntity entity) =>
      AccountsCompanion.insert(
        name: entity.name,
        type: entity.type,
        balance: Value(entity.balance),
        color: entity.color,
        icon: entity.icon,
        currency: Value(entity.currency),
        isDefault: Value(entity.isDefault),
      );

  /// Used for full-row updates — requires a non-null [id].
  static AccountsCompanion toUpdateCompanion(AccountEntity entity) =>
      AccountsCompanion(
        id: Value(entity.id!),
        name: Value(entity.name),
        type: Value(entity.type),
        balance: Value(entity.balance),
        color: Value(entity.color),
        icon: Value(entity.icon),
        currency: Value(entity.currency),
        isDefault: Value(entity.isDefault),
        createdAt: Value(entity.createdAt),
      );
}
