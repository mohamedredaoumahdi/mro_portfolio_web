/// Simple logger utility to replace print statements
import 'package:flutter/foundation.dart';
/// 
/// In production, you can replace this with a proper logging package
/// like logger, or use Flutter's built-in debugPrint
class Logger {
  /// Log debug messages (only in debug mode)
  static void debug(String message) {
    assert(() {
      debugPrint('[DEBUG] $message');
      return true;
    }());
  }
  
  /// Log info messages
  static void info(String message) {
    debugPrint('[INFO] $message');
  }
  
  /// Log warning messages
  static void warning(String message) {
    debugPrint('[WARNING] $message');
  }
  
  /// Log error messages
  static void error(String message, [Object? error, StackTrace? stackTrace]) {
    debugPrint('[ERROR] $message');
    if (error != null) {
      debugPrint('Error: $error');
    }
    if (stackTrace != null) {
      debugPrint('Stack trace: $stackTrace');
    }
  }
}

