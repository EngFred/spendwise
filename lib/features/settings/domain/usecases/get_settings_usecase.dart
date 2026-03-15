import '../../../../core/error/app_result.dart';
import '../entities/app_settings.dart';
import '../repositories/i_settings_repository.dart';

class GetSettingsUseCase {
  final ISettingsRepository _repository;
  const GetSettingsUseCase(this._repository);

  Future<AppResult<AppSettings>> call() => _repository.getSettings();
}
