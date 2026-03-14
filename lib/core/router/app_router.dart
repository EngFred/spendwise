import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../features/onboarding/presentation/onboarding_screen.dart';
import '../../features/onboarding/providers/onboarding_provider.dart';
import '../../features/splash/presentation/splash_screen.dart';
import '../../features/dashboard/presentation/dashboard_screen.dart';
import '../../features/transactions/presentation/transactions_screen.dart';
import '../../features/transactions/presentation/add_transaction_screen.dart';
import '../../features/accounts/presentation/accounts_screen.dart';
import '../../features/accounts/presentation/add_account_screen.dart';
import '../../features/budgets/presentation/budgets_screen.dart';
import '../../features/budgets/presentation/add_budget_screen.dart';
import '../../features/goals/presentation/goals_screen.dart';
import '../../features/goals/presentation/add_goal_screen.dart';
import '../../features/reports/presentation/reports_screen.dart';
import '../../features/categories/presentation/categories_screen.dart';
import '../../features/settings/presentation/settings_screen.dart';
import '../../features/settings/presentation/lock_screen.dart';
import '../../features/settings/providers/settings_provider.dart';
import '../../shared/widgets/main_shell.dart';

final _rootNavigatorKey = GlobalKey<NavigatorState>();
final _shellNavigatorKey = GlobalKey<NavigatorState>();

class SessionUnlockedNotifier extends Notifier<bool> {
  @override
  bool build() => false;

  void unlock() => state = true;
  void lock() => state = false;
}

final sessionUnlockedProvider = NotifierProvider<SessionUnlockedNotifier, bool>(
  SessionUnlockedNotifier.new,
);

final appRouterProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    navigatorKey: _rootNavigatorKey,
    // Always start at splash — it decides where to go next
    initialLocation: '/splash',
    redirect: (context, state) {
      final isOnboardingComplete = ref.read(onboardingProvider).value ?? false;
      final isOnboarding = state.matchedLocation == '/onboarding';
      final isLockScreen = state.matchedLocation == '/lock';
      final isSplash = state.matchedLocation == '/splash';

      // Splash handles its own navigation — never redirect away from it
      if (isSplash) return null;

      // ── Onboarding gate ──────────────────────────────────────────────
      if (!isOnboardingComplete && !isOnboarding) return '/onboarding';
      if (isOnboardingComplete && isOnboarding) return '/dashboard';

      // ── Biometric lock gate ──────────────────────────────────────────
      if (isOnboardingComplete && !isLockScreen) {
        final settings = ref.read(settingsProvider).value;
        final isUnlocked = ref.read(sessionUnlockedProvider);
        if (settings != null && settings.biometricLock && !isUnlocked) {
          return '/lock';
        }
      }

      return null;
    },
    routes: [
      GoRoute(
        path: '/splash',
        builder: (context, state) => const SplashScreen(),
      ),
      GoRoute(
        path: '/onboarding',
        builder: (context, state) => const OnboardingScreen(),
      ),
      GoRoute(path: '/lock', builder: (context, state) => const LockScreen()),
      ShellRoute(
        navigatorKey: _shellNavigatorKey,
        builder: (context, state, child) => MainShell(child: child),
        routes: [
          GoRoute(
            path: '/dashboard',
            pageBuilder: (context, state) =>
                const NoTransitionPage(child: DashboardScreen()),
          ),
          GoRoute(
            path: '/transactions',
            pageBuilder: (context, state) =>
                const NoTransitionPage(child: TransactionsScreen()),
          ),
          GoRoute(
            path: '/accounts',
            pageBuilder: (context, state) =>
                const NoTransitionPage(child: AccountsScreen()),
          ),
          GoRoute(
            path: '/budgets',
            pageBuilder: (context, state) =>
                const NoTransitionPage(child: BudgetsScreen()),
          ),
          GoRoute(
            path: '/goals',
            pageBuilder: (context, state) =>
                const NoTransitionPage(child: GoalsScreen()),
          ),
          GoRoute(
            path: '/reports',
            pageBuilder: (context, state) =>
                const NoTransitionPage(child: ReportsScreen()),
          ),
        ],
      ),
      GoRoute(
        path: '/transactions/add',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => const AddTransactionScreen(),
      ),
      GoRoute(
        path: '/accounts/add',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => const AddAccountScreen(),
      ),
      GoRoute(
        path: '/budgets/add',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => const AddBudgetScreen(),
      ),
      GoRoute(
        path: '/goals/add',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => const AddGoalScreen(),
      ),
      GoRoute(
        path: '/categories',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => const CategoriesScreen(),
      ),
      GoRoute(
        path: '/settings',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => const SettingsScreen(),
      ),
    ],
  );
});
