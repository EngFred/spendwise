import '../../../../core/error/app_result.dart';
import '../../../../core/utils/app_logger.dart';
import '../../../../database/app_database.dart';
import '../../domain/entities/app_settings.dart';
import '../../domain/repositories/i_settings_repository.dart';
import '../datasources/settings_local_datasource.dart';

class SettingsRepositoryImpl implements ISettingsRepository {
  final ISettingsLocalDatasource _datasource;
  final AppDatabase _db;

  const SettingsRepositoryImpl(this._datasource, this._db);

  @override
  Future<AppResult<AppSettings>> getSettings() async {
    try {
      final settings = AppSettings(
        userName: await _datasource.getUserName() ?? '',
        currency: await _datasource.getCurrency() ?? 'UGX',
        isDarkMode: await _datasource.getDarkMode() ?? true,
        dailyReminder: await _datasource.getDailyReminder() ?? false,
        budgetAlerts: await _datasource.getBudgetAlerts() ?? true,
        biometricLock: await _datasource.getBiometricLock() ?? false,
      );
      AppLogger.info('SettingsRepository: settings loaded');
      return Success(settings);
    } catch (e, st) {
      AppLogger.error('SettingsRepository: getSettings failed', e, st);
      return Failure('Failed to load settings: $e');
    }
  }

  @override
  Future<AppResult<void>> saveUserName(String name) async {
    try {
      await _datasource.setUserName(name);
      return const Success(null);
    } catch (e, st) {
      AppLogger.error('SettingsRepository: saveUserName failed', e, st);
      return Failure('Failed to save name: $e');
    }
  }

  @override
  Future<AppResult<void>> saveCurrency(String currency) async {
    try {
      await _datasource.setCurrency(currency);
      return const Success(null);
    } catch (e, st) {
      AppLogger.error('SettingsRepository: saveCurrency failed', e, st);
      return Failure('Failed to save currency: $e');
    }
  }

  @override
  Future<AppResult<void>> saveDarkMode(bool value) async {
    try {
      await _datasource.setDarkMode(value);
      return const Success(null);
    } catch (e, st) {
      AppLogger.error('SettingsRepository: saveDarkMode failed', e, st);
      return Failure('Failed to save dark mode: $e');
    }
  }

  @override
  Future<AppResult<void>> saveDailyReminder(bool value) async {
    try {
      await _datasource.setDailyReminder(value);
      return const Success(null);
    } catch (e, st) {
      AppLogger.error('SettingsRepository: saveDailyReminder failed', e, st);
      return Failure('Failed to save daily reminder: $e');
    }
  }

  @override
  Future<AppResult<void>> saveBudgetAlerts(bool value) async {
    try {
      await _datasource.setBudgetAlerts(value);
      return const Success(null);
    } catch (e, st) {
      AppLogger.error('SettingsRepository: saveBudgetAlerts failed', e, st);
      return Failure('Failed to save budget alerts: $e');
    }
  }

  @override
  Future<AppResult<void>> saveBiometricLock(bool value) async {
    try {
      await _datasource.setBiometricLock(value);
      return const Success(null);
    } catch (e, st) {
      AppLogger.error('SettingsRepository: saveBiometricLock failed', e, st);
      return Failure('Failed to save biometric lock: $e');
    }
  }

  @override
  Future<AppResult<void>> clearAllData() async {
    try {
      await _datasource.clearAllData(_db);
      AppLogger.warning('SettingsRepository: all data cleared');
      return const Success(null);
    } catch (e, st) {
      AppLogger.error('SettingsRepository: clearAllData failed', e, st);
      return Failure('Failed to clear data: $e');
    }
  }

  // ✅ Added
  @override
  Future<AppResult<String>> exportTransactionsCsv() async {
    try {
      final filePath = await _datasource.exportTransactionsCsv(_db);
      AppLogger.info('SettingsRepository: CSV exported → $filePath');
      return Success(filePath);
    } catch (e, st) {
      AppLogger.error(
        'SettingsRepository: exportTransactionsCsv failed',
        e,
        st,
      );
      return Failure('Failed to export CSV: $e');
    }
  }
}
