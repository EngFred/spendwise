import '../../../../core/error/app_result.dart';
import '../entities/app_settings.dart';

abstract interface class ISettingsRepository {
  Future<AppResult<AppSettings>> getSettings();

  Future<AppResult<void>> saveUserName(String name);
  Future<AppResult<void>> saveCurrency(String currency);
  Future<AppResult<void>> saveDarkMode(bool value);
  Future<AppResult<void>> saveDailyReminder(bool value);
  Future<AppResult<void>> saveBudgetAlerts(bool value);
  Future<AppResult<void>> saveBiometricLock(bool value);

  /// Drops all transactional data from the database.
  Future<AppResult<void>> clearAllData();

  /// Writes all transactions to a CSV file and returns the file path.
  Future<AppResult<String>> exportTransactionsCsv();
}
