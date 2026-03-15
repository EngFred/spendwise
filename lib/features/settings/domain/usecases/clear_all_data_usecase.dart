import '../../../../core/error/app_result.dart';
import '../repositories/i_settings_repository.dart';

class ClearAllDataUseCase {
  final ISettingsRepository _repository;
  const ClearAllDataUseCase(this._repository);

  Future<AppResult<void>> call() => _repository.clearAllData();
}
