import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'core/router/app_router.dart';
import 'core/theme/app_theme.dart';
import 'core/services/app_lifecycle_observer.dart';
import 'features/settings/providers/settings_provider.dart';

class App extends ConsumerStatefulWidget {
  const App({super.key});

  @override
  ConsumerState<App> createState() => _AppState();
}

class _AppState extends ConsumerState<App> {
  late AppLifecycleObserver _observer;

  @override
  void initState() {
    super.initState();
    _observer = AppLifecycleObserver(ref);
    WidgetsBinding.instance.addObserver(_observer);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(_observer);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final settingsAsync = ref.watch(settingsProvider);
    final router = ref.watch(appRouterProvider);

    // In Riverpod 3, AsyncValue.value returns null when not in data state.
    // Default to dark while loading — matches the splash background exactly
    // so there is never a white flash.
    final settings = switch (settingsAsync) {
      AsyncData(:final value) => value,
      _ => null,
    };

    final themeMode = settings?.isDarkMode == false
        ? ThemeMode.light
        : ThemeMode.dark;

    return MaterialApp.router(
      title: 'SpendWise',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: themeMode,
      routerConfig: router,
    );
  }
}
