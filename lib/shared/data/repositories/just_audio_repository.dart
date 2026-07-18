import 'package:werdi/core/audio/audio_service_controller.dart';
import 'package:werdi/core/audio/quran_audio_handler.dart';
import 'package:werdi/core/audio/quran_audio_session.dart';
import 'package:werdi/shared/repositories/audio_repository.dart';
import 'package:just_audio/just_audio.dart';

class JustAudioRepository implements AudioRepository {
  JustAudioRepository({
    AudioPlayer? player,
    QuranAudioHandler? handler,
  })  : _handler = handler,
        _player = player ?? handler?.player ?? AudioPlayer();

  final QuranAudioHandler? _handler;
  final AudioPlayer _player;

  @override
  Stream<void> get onPlaybackCompleted => _player.processingStateStream
      .distinct()
      .where((state) => state == ProcessingState.completed)
      .map<void>((_) {});

  @override
  Future<void> loadSource({required String source}) async {
    final handler = _handler;
    if (handler != null) {
      await handler.loadSource(source: source);
      return;
    }
    if (source.startsWith('http://') || source.startsWith('https://')) {
      await _player.setUrl(source);
      return;
    }
    await _player.setFilePath(source);
  }

  @override
  Future<void> pause() => _player.pause();

  @override
  Future<void> play() => _player.play();

  @override
  Future<void> seek(Duration position) => _player.seek(position);

  @override
  Future<void> setSpeed(double speed) => _player.setSpeed(speed);

  @override
  Future<void> stop() async {
    final handler = _handler;
    if (handler != null) {
      await handler.stop();
      return;
    }
    await _player.stop();
    QuranAudioSession.clear();
    AudioServiceController.handler?.refreshControls();
  }
}
