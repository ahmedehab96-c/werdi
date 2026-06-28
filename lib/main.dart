import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:werdi/app.dart';
import 'package:werdi/core/services/bootstrap_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  FlutterError.onError = (details) {
    FlutterError.presentError(details);
    if (kDebugMode) {
      debugPrint('FlutterError: ${details.exceptionAsString()}');
    }
  };

  PlatformDispatcher.instance.onError = (error, stack) {
    if (kDebugMode) {
      debugPrint('Uncaught error: $error\n$stack');
    }
    return true;
  };

  try {
    await BootstrapService.init();
  } catch (error, stack) {
    if (kDebugMode) {
      debugPrint('Bootstrap failed: $error\n$stack');
    }
  }

  runApp(const WerdiApp());
}
