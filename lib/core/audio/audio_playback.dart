import 'package:werdi/core/audio/audio_service_controller.dart';
import 'package:werdi/core/audio/quran_audio_session.dart';
import 'package:werdi/shared/repositories/audio_repository.dart';

/// Tries each URL until playback succeeds (CDN mirrors often differ).
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
      await audio.loadSource(source: url);
      await audio.play();
      AudioServiceController.handler?.refreshControls();
      return;
    } catch (error) {
      lastError = error;
    }
  }
  throw lastError ?? StateError('all_audio_urls_failed');
}
