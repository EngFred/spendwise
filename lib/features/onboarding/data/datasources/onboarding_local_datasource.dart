import 'package:shared_preferences/shared_preferences.dart';
import '../../../../core/utils/app_logger.dart';

abstract interface class IOnboardingLocalDatasource {
  Future<bool> isOnboardingComplete();
  Future<void> setOnboardingComplete();
}

class OnboardingLocalDatasource implements IOnboardingLocalDatasource {
  static const _key = 'onboarding_complete';

  @override
  Future<bool> isOnboardingComplete() async {
    AppLogger.trace('OnboardingDatasource: isOnboardingComplete()');
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_key) ?? false;
  }

  @override
  Future<void> setOnboardingComplete() async {
    AppLogger.debug('OnboardingDatasource: setOnboardingComplete()');
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_key, true);
  }
}
