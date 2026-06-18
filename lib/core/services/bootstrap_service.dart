import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:werdi/core/di/app_injector.dart';

final class BootstrapService {
  const BootstrapService._();

  static final Connectivity _connectivity = Connectivity();
  static bool _initialized = false;

  static Future<void> init() async {
    if (_initialized) return;
    _initialized = true;

    await Hive.initFlutter();
    await AppInjector.appDatabase.ensureInitialized();
    await AppInjector.restoreAuthSession();
    unawaited(AppInjector.quranContentSeedService.warmUpInBackground());
    unawaited(AppInjector.localQuranCacheService.clearExpired());
    unawaited(AppInjector.offlineSyncService.flushPending());
    _connectivity.onConnectivityChanged.listen((results) {
      if (_isOnline(results)) {
        unawaited(AppInjector.offlineSyncService.flushPending());
      }
    });
  }

  static bool _isOnline(List<ConnectivityResult> results) {
    return results.any((r) => r != ConnectivityResult.none);
  }
}
