import 'package:werdi/shared/repositories/audio_repository.dart';

/// Tries each URL until playback succeeds (CDN mirrors often differ).
Future<void> playAudioUrlsWithFallback(
  AudioRepository audio, {
  required List<String> urls,
}) async {
  if (urls.isEmpty) {
    throw StateError('no_audio_urls');
  }
  Object? lastError;
  for (final url in urls) {
    try {
      await audio.loadSource(source: url);
      await audio.play();
      return;
    } catch (error) {
      lastError = error;
    }
  }
  throw lastError ?? StateError('all_audio_urls_failed');
}
