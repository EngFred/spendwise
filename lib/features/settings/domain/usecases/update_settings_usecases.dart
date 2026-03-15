import '../../../../core/error/app_result.dart';
import '../repositories/i_settings_repository.dart';

class SaveUserNameUseCase {
  final ISettingsRepository _repository;
  const SaveUserNameUseCase(this._repository);
  Future<AppResult<void>> call(String name) => _repository.saveUserName(name);
}

class SaveCurrencyUseCase {
  final ISettingsRepository _repository;
  const SaveCurrencyUseCase(this._repository);
  Future<AppResult<void>> call(String currency) =>
      _repository.saveCurrency(currency);
}

class SaveDarkModeUseCase {
  final ISettingsRepository _repository;
  const SaveDarkModeUseCase(this._repository);
  Future<AppResult<void>> call(bool value) => _repository.saveDarkMode(value);
}

class SaveDailyReminderUseCase {
  final ISettingsRepository _repository;
  const SaveDailyReminderUseCase(this._repository);
  Future<AppResult<void>> call(bool value) =>
      _repository.saveDailyReminder(value);
}

class SaveBudgetAlertsUseCase {
  final ISettingsRepository _repository;
  const SaveBudgetAlertsUseCase(this._repository);
  Future<AppResult<void>> call(bool value) =>
      _repository.saveBudgetAlerts(value);
}

class SaveBiometricLockUseCase {
  final ISettingsRepository _repository;
  const SaveBiometricLockUseCase(this._repository);
  Future<AppResult<void>> call(bool value) =>
      _repository.saveBiometricLock(value);
}
