import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../core/utils/app_logger.dart';
import '../../../../database/app_database.dart';

abstract interface class ISettingsLocalDatasource {
  Future<String?> getUserName();
  Future<String?> getCurrency();
  Future<bool?> getDarkMode();
  Future<bool?> getDailyReminder();
  Future<bool?> getBudgetAlerts();
  Future<bool?> getBiometricLock();

  Future<void> setUserName(String value);
  Future<void> setCurrency(String value);
  Future<void> setDarkMode(bool value);
  Future<void> setDailyReminder(bool value);
  Future<void> setBudgetAlerts(bool value);
  Future<void> setBiometricLock(bool value);

  Future<void> clearAllData(AppDatabase db);
  Future<String> exportTransactionsCsv(AppDatabase db);
}

class SettingsLocalDatasource implements ISettingsLocalDatasource {
  static const _keyUserName = 'user_name';
  static const _keyCurrency = 'currency';
  static const _keyDarkMode = 'dark_mode';
  static const _keyDailyReminder = 'daily_reminder';
  static const _keyBudgetAlerts = 'budget_alerts';
  static const _keyBiometricLock = 'biometric_lock';

  // ── Reads ──────────────────────────────────────────────────────────────────

  @override
  Future<String?> getUserName() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keyUserName);
  }

  @override
  Future<String?> getCurrency() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keyCurrency);
  }

  @override
  Future<bool?> getDarkMode() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_keyDarkMode);
  }

  @override
  Future<bool?> getDailyReminder() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_keyDailyReminder);
  }

  @override
  Future<bool?> getBudgetAlerts() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_keyBudgetAlerts);
  }

  @override
  Future<bool?> getBiometricLock() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_keyBiometricLock);
  }

  // ── Writes ─────────────────────────────────────────────────────────────────

  @override
  Future<void> setUserName(String value) async {
    AppLogger.debug('SettingsDatasource: setUserName');
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyUserName, value);
  }

  @override
  Future<void> setCurrency(String value) async {
    AppLogger.debug('SettingsDatasource: setCurrency($value)');
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyCurrency, value);
  }

  @override
  Future<void> setDarkMode(bool value) async {
    AppLogger.debug('SettingsDatasource: setDarkMode($value)');
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyDarkMode, value);
  }

  @override
  Future<void> setDailyReminder(bool value) async {
    AppLogger.debug('SettingsDatasource: setDailyReminder($value)');
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyDailyReminder, value);
  }

  @override
  Future<void> setBudgetAlerts(bool value) async {
    AppLogger.debug('SettingsDatasource: setBudgetAlerts($value)');
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyBudgetAlerts, value);
  }

  @override
  Future<void> setBiometricLock(bool value) async {
    AppLogger.debug('SettingsDatasource: setBiometricLock($value)');
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyBiometricLock, value);
  }

  // ── Clear ──────────────────────────────────────────────────────────────────

  @override
  Future<void> clearAllData(AppDatabase db) async {
    AppLogger.warning('SettingsDatasource: clearAllData — deleting all tables');
    await db.delete(db.transactions).go();
    await db.delete(db.budgets).go();
    await db.delete(db.goals).go();
    await db.delete(db.accounts).go();
  }

  // ── Export ─────────────────────────────────────────────────────────────────

  @override
  Future<String> exportTransactionsCsv(AppDatabase db) async {
    AppLogger.info('SettingsDatasource: exportTransactionsCsv()');

    // Fetch all data in parallel
    final results = await Future.wait([
      db.transactionsDao.getAllTransactions(),
      db.accountsDao.getAllAccounts(),
      db.categoriesDao.getAllCategories(),
    ]);

    final transactions = results[0] as List<Transaction>;
    final accounts = results[1] as List<Account>;
    final categories = results[2] as List<Category>;

    // Build O(1) lookup maps
    final accountNames = {for (final a in accounts) a.id: a.name};
    final categoryNames = {for (final c in categories) c.id: c.name};

    // Sort first into a new list, then map — no cascade confusion
    final sorted = List<Transaction>.of(transactions)
      ..sort((a, b) => b.date.compareTo(a.date));

    // ── Build rows ──────────────────────────────────────────────────────────
    final header = <String>[
      'Date',
      'Type',
      'Amount (UGX)',
      'Account',
      'Category',
      'Note',
      'Recurring',
      'Recurring Interval',
    ];

    final dataRows = sorted.map(
      (t) => <String>[
        _formatDate(t.date),
        t.type.toUpperCase(),
        t.amount.toStringAsFixed(2),
        accountNames[t.accountId] ?? 'Unknown',
        categoryNames[t.categoryId] ?? 'Unknown',
        t.note ?? '',
        t.isRecurring ? 'Yes' : 'No',
        t.recurringInterval ?? '',
      ],
    );

    // Manual CSV — ListToCsvConverter was removed in csv ^7.x
    final allRows = [header, ...dataRows];
    final csvString = _buildCsvString(allRows);

    // ── Write to temp file ──────────────────────────────────────────────────
    final directory = await getTemporaryDirectory();
    final timestamp = DateTime.now()
        .toIso8601String()
        .replaceAll(':', '-')
        .replaceAll('.', '-')
        .substring(0, 19);
    final filePath = '${directory.path}/spendwise_export_$timestamp.csv';

    await File(filePath).writeAsString(csvString);

    AppLogger.info(
      'SettingsDatasource: CSV written → $filePath '
      '(${transactions.length} rows)',
    );

    return filePath;
  }

  // ── Helpers ────────────────────────────────────────────────────────────────

  String _formatDate(DateTime date) =>
      '${date.year}-'
      '${date.month.toString().padLeft(2, '0')}-'
      '${date.day.toString().padLeft(2, '0')} '
      '${date.hour.toString().padLeft(2, '0')}:'
      '${date.minute.toString().padLeft(2, '0')}';

  /// Builds a properly escaped CSV string from a list of rows.
  /// Wraps any cell containing a comma, double-quote, or newline in quotes,
  /// and escapes existing double-quotes by doubling them (RFC 4180).
  String _buildCsvString(List<List<String>> rows) {
    return rows
        .map((row) {
          return row
              .map((cell) {
                // Must quote if cell contains comma, double-quote, or newline
                if (cell.contains(',') ||
                    cell.contains('"') ||
                    cell.contains('\n')) {
                  return '"${cell.replaceAll('"', '""')}"';
                }
                return cell;
              })
              .join(',');
        })
        .join('\n');
  }
}
