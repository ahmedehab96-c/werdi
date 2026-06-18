import 'package:werdi/shared/repositories/audio_repository.dart';
import 'package:just_audio/just_audio.dart';

class JustAudioRepository implements AudioRepository {
  JustAudioRepository() : _player = AudioPlayer();

  final AudioPlayer _player;

  @override
  Stream<void> get onPlaybackCompleted => _player.playerStateStream
      .where(
        (state) =>
            state.processingState == ProcessingState.completed &&
            !state.playing,
      )
      .map<void>((_) {});

  @override
  Future<void> loadSource({required String source}) async {
    await _player.setUrl(source);
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
  Future<void> stop() => _player.stop();
}
