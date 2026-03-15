class AppSettings {
  final String userName;
  final String currency;
  final bool isDarkMode;
  final bool dailyReminder;
  final bool budgetAlerts;
  final bool biometricLock;

  const AppSettings({
    this.userName = '',
    this.currency = 'UGX',
    this.isDarkMode = true,
    this.dailyReminder = false,
    this.budgetAlerts = true,
    this.biometricLock = false,
  });

  AppSettings copyWith({
    String? userName,
    String? currency,
    bool? isDarkMode,
    bool? dailyReminder,
    bool? budgetAlerts,
    bool? biometricLock,
  }) {
    return AppSettings(
      userName: userName ?? this.userName,
      currency: currency ?? this.currency,
      isDarkMode: isDarkMode ?? this.isDarkMode,
      dailyReminder: dailyReminder ?? this.dailyReminder,
      budgetAlerts: budgetAlerts ?? this.budgetAlerts,
      biometricLock: biometricLock ?? this.biometricLock,
    );
  }
}
