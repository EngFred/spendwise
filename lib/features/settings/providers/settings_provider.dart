import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/services/notification_service.dart';
import '../../../core/utils/app_logger.dart';
import '../domain/entities/app_settings.dart';
import '../settings_providers.dart';

class SettingsNotifier extends AsyncNotifier<AppSettings> {
  @override
  Future<AppSettings> build() async {
    final result = await ref.read(getSettingsUseCaseProvider).call();
    return result.when(
      success: (data) => data,
      failure: (msg) {
        AppLogger.error('SettingsNotifier.build failed: $msg');
        // Fall back to defaults rather than crashing the app
        return const AppSettings();
      },
    );
  }

  Future<void> setUserName(String name) async {
    final result = await ref.read(saveUserNameUseCaseProvider).call(name);
    result.when(
      success: (_) {
        state = AsyncData(state.value!.copyWith(userName: name));
        AppLogger.info('SettingsNotifier: userName updated');
      },
      failure: (msg) =>
          AppLogger.error('SettingsNotifier: setUserName failed — $msg'),
    );
  }

  Future<void> setCurrency(String currency) async {
    final result = await ref.read(saveCurrencyUseCaseProvider).call(currency);
    result.when(
      success: (_) {
        state = AsyncData(state.value!.copyWith(currency: currency));
        AppLogger.info('SettingsNotifier: currency updated to $currency');
      },
      failure: (msg) =>
          AppLogger.error('SettingsNotifier: setCurrency failed — $msg'),
    );
  }

  Future<void> setDarkMode(bool value) async {
    final result = await ref.read(saveDarkModeUseCaseProvider).call(value);
    result.when(
      success: (_) =>
          state = AsyncData(state.value!.copyWith(isDarkMode: value)),
      failure: (msg) =>
          AppLogger.error('SettingsNotifier: setDarkMode failed — $msg'),
    );
  }

  Future<void> setDailyReminder(bool value) async {
    if (value) {
      await NotificationService.instance.requestPermissions();
      try {
        await NotificationService.instance.scheduleDailyReminder();
        final result = await ref
            .read(saveDailyReminderUseCaseProvider)
            .call(true);
        result.when(
          success: (_) =>
              state = AsyncData(state.value!.copyWith(dailyReminder: true)),
          failure: (msg) => AppLogger.error(
            'SettingsNotifier: setDailyReminder persist failed — $msg',
          ),
        );
      } catch (e) {
        // Scheduling failed — revert to disabled
        await ref.read(saveDailyReminderUseCaseProvider).call(false);
        state = AsyncData(state.value!.copyWith(dailyReminder: false));
        AppLogger.warning('SettingsNotifier: scheduleDailyReminder failed', e);
        rethrow; // Let the UI show an error snackbar
      }
    } else {
      await NotificationService.instance.cancelDailyReminder();
      final result = await ref
          .read(saveDailyReminderUseCaseProvider)
          .call(false);
      result.when(
        success: (_) =>
            state = AsyncData(state.value!.copyWith(dailyReminder: false)),
        failure: (msg) => AppLogger.error(
          'SettingsNotifier: setDailyReminder false failed — $msg',
        ),
      );
    }
  }

  Future<void> setBudgetAlerts(bool value) async {
    final result = await ref.read(saveBudgetAlertsUseCaseProvider).call(value);
    result.when(
      success: (_) =>
          state = AsyncData(state.value!.copyWith(budgetAlerts: value)),
      failure: (msg) =>
          AppLogger.error('SettingsNotifier: setBudgetAlerts failed — $msg'),
    );
  }

  Future<void> setBiometricLock(bool value) async {
    final result = await ref.read(saveBiometricLockUseCaseProvider).call(value);
    result.when(
      success: (_) =>
          state = AsyncData(state.value!.copyWith(biometricLock: value)),
      failure: (msg) =>
          AppLogger.error('SettingsNotifier: setBiometricLock failed — $msg'),
    );
  }

  Future<void> clearAllData() async {
    final result = await ref.read(clearAllDataUseCaseProvider).call();
    result.when(
      success: (_) => AppLogger.warning('SettingsNotifier: all data cleared'),
      failure: (msg) {
        AppLogger.error('SettingsNotifier: clearAllData failed — $msg');
        throw Exception(msg);
      },
    );
  }

  /// Returns the file path on success so the UI can share it immediately.
  Future<String> exportCsv() async {
    final result = await ref.read(exportCsvUseCaseProvider).call();
    return result.when(
      success: (filePath) {
        AppLogger.info('SettingsNotifier: CSV ready at $filePath');
        return filePath;
      },
      failure: (msg) {
        AppLogger.error('SettingsNotifier: exportCsv failed — $msg');
        throw Exception(msg);
      },
    );
  }
}

final settingsProvider = AsyncNotifierProvider<SettingsNotifier, AppSettings>(
  SettingsNotifier.new,
);
