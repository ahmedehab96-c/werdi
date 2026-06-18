import 'package:flutter/foundation.dart';

final class AppLogger {
  const AppLogger._();

  static void log(String message) {
    if (kDebugMode) {
      debugPrint('[Werdi] $message');
    }
  }
}
