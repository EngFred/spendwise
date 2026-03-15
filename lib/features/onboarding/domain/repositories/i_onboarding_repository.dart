import '../../../../core/error/app_result.dart';

abstract interface class IOnboardingRepository {
  Future<AppResult<bool>> isOnboardingComplete();
  Future<AppResult<void>> completeOnboarding();
}
