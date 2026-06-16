import 'package:flutter/foundation.dart';

/// Centralized logger for the application.
///
/// In development, uses debugPrint. In production, could be replaced
/// with a more robust solution like Sentry, Firebase Crashlytics, etc.
class AppLogger {
  static void error(String message, [Object? error, StackTrace? stackTrace]) {
    debugPrint('❌ ERROR: $message');
    if (error != null) debugPrint('   Cause: $error');
    if (stackTrace != null) debugPrint('   Stack: $stackTrace');
  }

  static void warning(String message) {
    debugPrint('⚠️  WARNING: $message');
  }

  static void info(String message) {
    debugPrint('ℹ️  INFO: $message');
  }
}
