import 'package:logger/logger.dart';
import 'package:flutter/foundation.dart';

class AppLogger {
  static final Logger _logger = Logger(
    printer: PrettyPrinter(
      methodCount: 2,
      errorMethodCount: 8,
      lineLength: 120,
      colors: true,
      printEmojis: false,
      dateTimeFormat: DateTimeFormat.onlyTimeAndSinceStart,
    ),
  );

  static void debug(String message, [dynamic error, StackTrace? stackTrace]) {
    if (kDebugMode) {
      _logger.d(message, error: error, stackTrace: stackTrace);
    }
  }

  static void info(String message, [dynamic error, StackTrace? stackTrace]) {
    _logger.i(message, error: error, stackTrace: stackTrace);
  }

  static void warning(String message, [dynamic error, StackTrace? stackTrace]) {
    _logger.w(message, error: error, stackTrace: stackTrace);
  }

  static void error(String message, [dynamic error, StackTrace? stackTrace]) {
    final sanitized = _sanitize(message);
    _logger.e(sanitized, error: error, stackTrace: stackTrace);
  }

  static String _sanitize(String message) {
    return message
        .replaceAll(
          RegExp(r'password["\s:=]+[^\s,}"]+', caseSensitive: false),
          'password=***',
        )
        .replaceAll(
          RegExp(r'token["\s:=]+[^\s,}"]+', caseSensitive: false),
          'token=***',
        )
        .replaceAll(
          RegExp(r'api[_-]?key["\s:=]+[^\s,}"]+', caseSensitive: false),
          'apiKey=***',
        );
  }
}
