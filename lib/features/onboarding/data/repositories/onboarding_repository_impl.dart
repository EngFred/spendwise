import '../../../../core/error/app_result.dart';
import '../../../../core/utils/app_logger.dart';
import '../../domain/repositories/i_onboarding_repository.dart';
import '../datasources/onboarding_local_datasource.dart';

class OnboardingRepositoryImpl implements IOnboardingRepository {
  final IOnboardingLocalDatasource _datasource;
  const OnboardingRepositoryImpl(this._datasource);

  @override
  Future<AppResult<bool>> isOnboardingComplete() async {
    try {
      final result = await _datasource.isOnboardingComplete();
      AppLogger.info('OnboardingRepository: isComplete=$result');
      return Success(result);
    } catch (e, st) {
      AppLogger.error(
        'OnboardingRepository: isOnboardingComplete failed',
        e,
        st,
      );
      // Default to false — user sees onboarding again rather than crashing
      return const Success(false);
    }
  }

  @override
  Future<AppResult<void>> completeOnboarding() async {
    try {
      await _datasource.setOnboardingComplete();
      AppLogger.info('OnboardingRepository: onboarding marked complete');
      return const Success(null);
    } catch (e, st) {
      AppLogger.error('OnboardingRepository: completeOnboarding failed', e, st);
      return Failure('Failed to save onboarding status: $e');
    }
  }
}
