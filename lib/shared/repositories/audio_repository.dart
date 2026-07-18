abstract interface class AudioRepository {
  Stream<void> get onPlaybackCompleted;

  Future<void> loadSource({required String source});

  Future<void> play();

  /// Waits until playback is actually producing audio (or completes).
  /// Throws if the player stalls (common with broken CDN streams).
  Future<void> ensurePlaybackStarted({
    Duration timeout = const Duration(seconds: 10),
  });

  /// Waits until the currently loaded track finishes (or [timeout]).
  Future<void> waitForCurrentTrackEnd({
    Duration timeout = const Duration(minutes: 3),
    bool Function()? shouldCancel,
  });

  Future<void> pause();

  /// Stops the engine without clearing lock-screen / playlist session metadata.
  Future<void> softReset();

  Future<void> stop();

  Future<void> seek(Duration position);

  Future<void> setSpeed(double speed);
}
