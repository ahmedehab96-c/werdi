abstract interface class AudioRepository {
  Stream<void> get onPlaybackCompleted;

  Future<void> loadSource({required String source});

  Future<void> play();

  Future<void> pause();

  Future<void> stop();

  Future<void> seek(Duration position);

  Future<void> setSpeed(double speed);
}
