import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:werdi/core/audio/audio_service_controller.dart';
import 'package:werdi/core/di/app_injector.dart';
import 'package:werdi/core/network/supabase_service.dart';

final class BootstrapService {
  const BootstrapService._();

  static final Connectivity _connectivity = Connectivity();
  static bool _initialized = false;

  static Future<void> init() async {
    if (_initialized) return;
    _initialized = true;

    await AppInjector.appDatabase.ensureInitialized();
    await AppInjector.recitationOfflineStorage.ensureReady();
    try {
      await AudioServiceController.ensureInitialized();
    } catch (error, stack) {
      // Foreground-only playback remains available via JustAudio.
      assert(() {
        // ignore: avoid_print
        print('AudioService init failed: $error\n$stack');
        return true;
      }());
    }
    AppInjector.configureAudio();
    await SupabaseService.initialize();
    // Defer heavy Quran seed so the home dashboard can load first.
    Future<void>.delayed(const Duration(seconds: 4), () {
      unawaited(AppInjector.quranContentSeedService.warmUpInBackground());
    });
    unawaited(AppInjector.localQuranCacheService.clearExpired());
    unawaited(AppInjector.offlineSyncService.flushPending());
    if (SupabaseService.hasSession) {
      unawaited(AppInjector.remoteDataPullService.pullIfSignedIn());
    }
    _connectivity.onConnectivityChanged.listen((results) {
      if (_isOnline(results)) {
        unawaited(AppInjector.offlineSyncService.flushPending());
        if (SupabaseService.hasSession) {
          unawaited(AppInjector.remoteDataPullService.pullIfSignedIn());
        }
      }
    });
  }

  static bool _isOnline(List<ConnectivityResult> results) {
    return results.any((r) => r != ConnectivityResult.none);
  }
}
