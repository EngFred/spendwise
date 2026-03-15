import 'package:logger/logger.dart';

/// Central logger for the entire app.
/// Usage: AppLogger.debug('message'), AppLogger.error('oops', e, st)
class AppLogger {
  AppLogger._();

  static final Logger _logger = Logger(
    printer: PrettyPrinter(
      methodCount: 2,
      errorMethodCount: 10,
      lineLength: 120,
      colors: true,
      printEmojis: true,
      dateTimeFormat: DateTimeFormat.onlyTimeAndSinceStart,
    ),
    // Suppress logs in release builds
    level: const bool.fromEnvironment('dart.vm.product')
        ? Level.off
        : Level.trace,
  );

  static void trace(String message, [Object? error, StackTrace? st]) =>
      _logger.t(message, error: error, stackTrace: st);

  static void debug(String message, [Object? error, StackTrace? st]) =>
      _logger.d(message, error: error, stackTrace: st);

  static void info(String message, [Object? error, StackTrace? st]) =>
      _logger.i(message, error: error, stackTrace: st);

  static void warning(String message, [Object? error, StackTrace? st]) =>
      _logger.w(message, error: error, stackTrace: st);

  static void error(String message, [Object? error, StackTrace? st]) =>
      _logger.e(message, error: error, stackTrace: st);

  static void fatal(String message, [Object? error, StackTrace? st]) =>
      _logger.f(message, error: error, stackTrace: st);
}
