import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:spendwise/features/accounts/accounts_providers.dart';
import 'package:spendwise/features/accounts/domain/usecases/create_account_usecase.dart';
import 'package:spendwise/features/accounts/domain/usecases/update_balance_usecase.dart';
import '../../../../core/utils/app_logger.dart';
import '../domain/entities/account_entity.dart';

// ── Stream (reactive list for UI) ─────────────────────────────────────────────

final accountsStreamProvider = StreamProvider<List<AccountEntity>>((ref) {
  return ref.watch(watchAllAccountsUseCaseProvider).call();
});

// ── Notifier (for mutations) ──────────────────────────────────────────────────

class AccountsNotifier extends AsyncNotifier<List<AccountEntity>> {
  @override
  Future<List<AccountEntity>> build() async {
    final result = await ref.read(getAllAccountsUseCaseProvider).call();
    return result.when(
      success: (data) => data,
      failure: (msg) {
        AppLogger.error('AccountsNotifier.build failed: $msg');
        throw Exception(msg);
      },
    );
  }

  Future<void> createAccount(CreateAccountParams params) async {
    final result = await ref.read(createAccountUseCaseProvider).call(params);
    result.when(
      success: (_) {
        AppLogger.info('AccountsNotifier: account created');
        ref.invalidateSelf();
      },
      failure: (msg) {
        AppLogger.error('AccountsNotifier: createAccount failed — $msg');
        throw Exception(msg);
      },
    );
  }

  Future<void> updateAccount(AccountEntity account) async {
    final result = await ref.read(updateAccountUseCaseProvider).call(account);
    result.when(
      success: (_) => ref.invalidateSelf(),
      failure: (msg) {
        AppLogger.error('AccountsNotifier: updateAccount failed — $msg');
        throw Exception(msg);
      },
    );
  }

  Future<void> deleteAccount(int id) async {
    final result = await ref.read(deleteAccountUseCaseProvider).call(id);
    result.when(
      success: (_) {
        AppLogger.info('AccountsNotifier: deleted account id=$id');
        ref.invalidateSelf();
      },
      failure: (msg) {
        AppLogger.error('AccountsNotifier: deleteAccount failed — $msg');
        throw Exception(msg);
      },
    );
  }

  Future<void> updateBalance(int id, double newBalance) async {
    final result = await ref
        .read(updateBalanceUseCaseProvider)
        .call(UpdateBalanceParams(id: id, newBalance: newBalance));
    result.when(
      success: (_) => ref.invalidateSelf(),
      failure: (msg) {
        AppLogger.error('AccountsNotifier: updateBalance failed — $msg');
        throw Exception(msg);
      },
    );
  }
}

final accountsNotifierProvider =
    AsyncNotifierProvider<AccountsNotifier, List<AccountEntity>>(
      AccountsNotifier.new,
    );
