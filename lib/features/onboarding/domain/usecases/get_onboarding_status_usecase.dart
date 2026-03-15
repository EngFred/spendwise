import '../../../../core/error/app_result.dart';
import '../repositories/i_onboarding_repository.dart';

class GetOnboardingStatusUseCase {
  final IOnboardingRepository _repository;
  const GetOnboardingStatusUseCase(this._repository);

  Future<AppResult<bool>> call() => _repository.isOnboardingComplete();
}
