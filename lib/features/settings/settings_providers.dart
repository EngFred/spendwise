import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/providers/app_providers.dart';
import 'data/datasources/settings_local_datasource.dart';
import 'data/repositories/settings_repository_impl.dart';
import 'domain/repositories/i_settings_repository.dart';
import 'domain/usecases/clear_all_data_usecase.dart';
import 'domain/usecases/export_csv_usecase.dart';
import 'domain/usecases/get_settings_usecase.dart';
import 'domain/usecases/update_settings_usecases.dart';

final settingsLocalDatasourceProvider = Provider<ISettingsLocalDatasource>((
  ref,
) {
  return SettingsLocalDatasource();
});

final settingsRepositoryProvider = Provider<ISettingsRepository>((ref) {
  return SettingsRepositoryImpl(
    ref.watch(settingsLocalDatasourceProvider),
    ref.watch(appDatabaseProvider),
  );
});

final getSettingsUseCaseProvider = Provider(
  (ref) => GetSettingsUseCase(ref.watch(settingsRepositoryProvider)),
);
final saveUserNameUseCaseProvider = Provider(
  (ref) => SaveUserNameUseCase(ref.watch(settingsRepositoryProvider)),
);
final saveCurrencyUseCaseProvider = Provider(
  (ref) => SaveCurrencyUseCase(ref.watch(settingsRepositoryProvider)),
);
final saveDarkModeUseCaseProvider = Provider(
  (ref) => SaveDarkModeUseCase(ref.watch(settingsRepositoryProvider)),
);
final saveDailyReminderUseCaseProvider = Provider(
  (ref) => SaveDailyReminderUseCase(ref.watch(settingsRepositoryProvider)),
);
final saveBudgetAlertsUseCaseProvider = Provider(
  (ref) => SaveBudgetAlertsUseCase(ref.watch(settingsRepositoryProvider)),
);
final saveBiometricLockUseCaseProvider = Provider(
  (ref) => SaveBiometricLockUseCase(ref.watch(settingsRepositoryProvider)),
);
final clearAllDataUseCaseProvider = Provider(
  (ref) => ClearAllDataUseCase(ref.watch(settingsRepositoryProvider)),
);

final exportCsvUseCaseProvider = Provider(
  (ref) => ExportCsvUseCase(ref.watch(settingsRepositoryProvider)),
);
