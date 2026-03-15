import '../../../../core/error/app_result.dart';
import '../repositories/i_onboarding_repository.dart';

class CompleteOnboardingUseCase {
  final IOnboardingRepository _repository;
  const CompleteOnboardingUseCase(this._repository);

  Future<AppResult<void>> call() => _repository.completeOnboarding();
}
