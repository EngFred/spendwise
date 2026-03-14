import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../core/providers/app_providers.dart';
import '../../../core/services/notification_service.dart';
import '../domain/app_settings.dart';

export '../domain/app_settings.dart';

class SettingsNotifier extends AsyncNotifier<AppSettings> {
  static const _keyUserName = 'user_name';
  static const _keyCurrency = 'currency';
  static const _keyDarkMode = 'dark_mode';
  static const _keyDailyReminder = 'daily_reminder';
  static const _keyBudgetAlerts = 'budget_alerts';
  static const _keyBiometricLock = 'biometric_lock';

  @override
  Future<AppSettings> build() async {
    final prefs = await SharedPreferences.getInstance();
    return AppSettings(
      userName: prefs.getString(_keyUserName) ?? '',
      currency: prefs.getString(_keyCurrency) ?? 'UGX',
      isDarkMode: prefs.getBool(_keyDarkMode) ?? true,
      dailyReminder: prefs.getBool(_keyDailyReminder) ?? false,
      budgetAlerts: prefs.getBool(_keyBudgetAlerts) ?? true,
      biometricLock: prefs.getBool(_keyBiometricLock) ?? false,
    );
  }

  Future<void> setUserName(String name) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyUserName, name);
    state = AsyncData(state.value!.copyWith(userName: name));
  }

  Future<void> setCurrency(String currency) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyCurrency, currency);
    state = AsyncData(state.value!.copyWith(currency: currency));
  }

  Future<void> setDarkMode(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyDarkMode, value);
    state = AsyncData(state.value!.copyWith(isDarkMode: value));
  }

  Future<void> setDailyReminder(bool value) async {
    final prefs = await SharedPreferences.getInstance();

    if (value) {
      await NotificationService.instance.requestPermissions();
      try {
        await NotificationService.instance.scheduleDailyReminder();
        // Only persist + update state if scheduling succeeded
        await prefs.setBool(_keyDailyReminder, true);
        state = AsyncData(state.value!.copyWith(dailyReminder: true));
      } catch (e) {
        // Scheduling failed (e.g. exact alarms denied by user in system settings).
        // Revert to disabled so the UI stays consistent.
        await prefs.setBool(_keyDailyReminder, false);
        state = AsyncData(state.value!.copyWith(dailyReminder: false));
        // Rethrow so the UI can show a snackbar/dialog if desired.
        rethrow;
      }
    } else {
      await NotificationService.instance.cancelDailyReminder();
      await prefs.setBool(_keyDailyReminder, false);
      state = AsyncData(state.value!.copyWith(dailyReminder: false));
    }
  }

  Future<void> setBudgetAlerts(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyBudgetAlerts, value);
    state = AsyncData(state.value!.copyWith(budgetAlerts: value));
  }

  Future<void> setBiometricLock(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyBiometricLock, value);
    state = AsyncData(state.value!.copyWith(biometricLock: value));
  }

  // ── Clear all data ──────────────────────
  Future<void> clearAllData() async {
    final db = ref.read(appDatabaseProvider);
    await db.delete(db.transactions).go();
    await db.delete(db.accounts).go();
    await db.delete(db.budgets).go();
    await db.delete(db.goals).go();
  }
}

final settingsProvider = AsyncNotifierProvider<SettingsNotifier, AppSettings>(
  SettingsNotifier.new,
);
