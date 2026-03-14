import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/providers/app_providers.dart';
import '../../../database/app_database.dart';

// Watch all accounts as a stream
final accountsStreamProvider = StreamProvider<List<Account>>((ref) {
  return ref.watch(accountsRepositoryProvider).watchAllAccounts();
});

// Accounts notifier for mutations
class AccountsNotifier extends AsyncNotifier<List<Account>> {
  @override
  Future<List<Account>> build() async {
    return ref.watch(accountsRepositoryProvider).getAllAccounts();
  }

  Future<void> createAccount({
    required String name,
    required String type,
    required double balance,
    required String color,
    required String icon,
    String currency = 'UGX',
    bool isDefault = false,
  }) async {
    await ref
        .read(accountsRepositoryProvider)
        .createAccount(
          name: name,
          type: type,
          balance: balance,
          color: color,
          icon: icon,
          currency: currency,
          isDefault: isDefault,
        );
    ref.invalidateSelf();
  }

  Future<void> updateAccount(Account account) async {
    await ref.read(accountsRepositoryProvider).updateAccount(account);
    ref.invalidateSelf();
  }

  Future<void> deleteAccount(int id) async {
    await ref.read(accountsRepositoryProvider).deleteAccount(id);
    ref.invalidateSelf();
  }
}

final accountsNotifierProvider =
    AsyncNotifierProvider<AccountsNotifier, List<Account>>(
      AccountsNotifier.new,
    );
