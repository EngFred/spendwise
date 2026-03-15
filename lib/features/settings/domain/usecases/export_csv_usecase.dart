import '../../../../core/error/app_result.dart';
import '../repositories/i_settings_repository.dart';

class ExportCsvUseCase {
  final ISettingsRepository _repository;
  const ExportCsvUseCase(this._repository);

  /// Returns the path of the written CSV file on success.
  Future<AppResult<String>> call() => _repository.exportTransactionsCsv();
}
