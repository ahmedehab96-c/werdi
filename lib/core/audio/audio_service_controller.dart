import 'package:audio_service/audio_service.dart';
import 'package:audio_session/audio_session.dart';
import 'package:werdi/core/audio/quran_audio_handler.dart';

/// Initializes [audio_service] for background Quran playback.
final class AudioServiceController {
  const AudioServiceController._();

  static QuranAudioHandler? _handler;

  static QuranAudioHandler? get handler => _handler;

  static Future<void> ensureInitialized() async {
    if (_handler != null) return;

    final session = await AudioSession.instance;
    await session.configure(const AudioSessionConfiguration.music());

    _handler = await AudioService.init(
      builder: QuranAudioHandler.new,
      config: const AudioServiceConfig(
        androidNotificationChannelId: 'werdi.quran.audio',
        androidNotificationChannelName: 'Quran recitation',
        androidNotificationOngoing: true,
        androidStopForegroundOnPause: true,
      ),
    );
  }
}
