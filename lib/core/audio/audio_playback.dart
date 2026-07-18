import 'package:flutter/foundation.dart';
import 'package:werdi/core/audio/audio_file_cache.dart';
import 'package:werdi/core/audio/audio_service_controller.dart';
import 'package:werdi/core/audio/quran_audio_session.dart';
import 'package:werdi/shared/repositories/audio_repository.dart';

/// Tries each URL until real audible playback starts.
///
/// Strategy:
/// 1. Download CDN file to local cache (avoids ExoPlayer stream stalls)
/// 2. Load + play
/// 3. Confirm playback started — otherwise try the next mirror
Future<void> playAudioUrlsWithFallback(
  AudioRepository audio, {
  required List<String> urls,
  AyahPlaybackMetadata? metadata,
  void Function()? onSkipNext,
  void Function()? onSkipPrevious,
}) async {
  if (urls.isEmpty) {
    throw StateError('no_audio_urls');
  }

  if (metadata != null) {
    QuranAudioSession.prepare(
      metadata: metadata,
      onSkipNext: onSkipNext,
      onSkipPrevious: onSkipPrevious,
    );
    AudioServiceController.handler?.refreshControls();
  }

  Object? lastError;
  for (final url in urls) {
    try {
      if (kDebugMode) {
        debugPrint('Audio resolve: $url');
      }
      final source = await AudioFileCache.resolve(url);
      if (kDebugMode) {
        debugPrint('Audio load: $source');
      }
      await audio.loadSource(source: source);
      await audio.play();
      await audio.ensurePlaybackStarted();
      AudioServiceController.handler?.refreshControls();
      if (kDebugMode) {
        debugPrint('Audio confirmed playing: $url');
      }
      return;
    } catch (error, stack) {
      lastError = error;
      if (kDebugMode) {
        debugPrint('Audio failed ($url): $error\n$stack');
      }
      // Soft reset only — keep playlist session / skip callbacks intact.
      try {
        await audio.softReset();
      } catch (_) {}
    }
  }
  throw lastError ?? StateError('all_audio_urls_failed');
}
