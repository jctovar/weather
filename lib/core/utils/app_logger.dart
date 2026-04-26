import 'package:logger/logger.dart';

/// Centralized app logger with emoji prefixes for visual scanning.
class AppLogger {
  AppLogger._();

  static final _logger = Logger(
    printer: PrettyPrinter(
      methodCount: 0,
      errorMethodCount: 4,
      lineLength: 80,
      colors: true,
      printEmojis: false,
    ),
  );

  /// 📦 Cache operations
  static void cache(String msg) => _logger.d('📦 $msg');

  /// 🌐 API requests
  static void api(String msg) => _logger.d('🌐 $msg');

  /// 📍 Location events
  static void location(String msg) => _logger.d('📍 $msg');

  /// ℹ️ General info
  static void info(String msg) => _logger.i('ℹ️ $msg');

  /// ⚠️ Warnings
  static void warn(String msg) => _logger.w('⚠️ $msg');

  /// ❌ Errors
  static void error(String msg) => _logger.e('❌ $msg');
}
