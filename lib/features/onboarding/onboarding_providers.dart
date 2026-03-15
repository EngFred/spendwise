import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'data/datasources/onboarding_local_datasource.dart';
import 'data/repositories/onboarding_repository_impl.dart';
import 'domain/repositories/i_onboarding_repository.dart';
import 'domain/usecases/complete_onboarding_usecase.dart';
import 'domain/usecases/get_onboarding_status_usecase.dart';

// ── Datasource ────────────────────────────────────────────────────────────────

final onboardingLocalDatasourceProvider = Provider<IOnboardingLocalDatasource>((
  ref,
) {
  return OnboardingLocalDatasource();
});

// ── Repository ────────────────────────────────────────────────────────────────

final onboardingRepositoryProvider = Provider<IOnboardingRepository>((ref) {
  return OnboardingRepositoryImpl(ref.watch(onboardingLocalDatasourceProvider));
});

// ── Use Cases ─────────────────────────────────────────────────────────────────

final getOnboardingStatusUseCaseProvider = Provider(
  (ref) => GetOnboardingStatusUseCase(ref.watch(onboardingRepositoryProvider)),
);

final completeOnboardingUseCaseProvider = Provider(
  (ref) => CompleteOnboardingUseCase(ref.watch(onboardingRepositoryProvider)),
);
