import 'dart:async';

import 'package:audio_service/audio_service.dart';
import 'package:just_audio/just_audio.dart';
import 'package:werdi/core/audio/quran_audio_session.dart';

/// Background-capable audio handler for Quran recitation playback.
class QuranAudioHandler extends BaseAudioHandler with SeekHandler {
  QuranAudioHandler() {
    _player = AudioPlayer();
    _subscriptions.add(
      _player.playbackEventStream.listen(_broadcastPlaybackState),
    );
    _subscriptions.add(
      _player.processingStateStream.listen((_) => _broadcastPlaybackState(null)),
    );
  }

  late final AudioPlayer _player;
  final List<StreamSubscription<dynamic>> _subscriptions = [];

  AudioPlayer get player => _player;

  @override
  Future<void> play() => _player.play();

  @override
  Future<void> pause() => _player.pause();

  @override
  Future<void> stop() async {
    await _player.stop();
    QuranAudioSession.clear();
    await super.stop();
  }

  @override
  Future<void> seek(Duration position) => _player.seek(position);

  @override
  Future<void> setSpeed(double speed) => _player.setSpeed(speed);

  @override
  Future<void> skipToNext() async {
    QuranAudioSession.invokeSkipNext();
  }

  @override
  Future<void> skipToPrevious() async {
    QuranAudioSession.invokeSkipPrevious();
  }

  Future<void> loadSource({
    required String source,
    String? title,
    String? artist,
  }) async {
    try {
      await _player.stop();
    } catch (_) {}

    if (source.startsWith('http://') || source.startsWith('https://')) {
      await _player.setUrl(source);
    } else {
      await _player.setFilePath(source);
    }
    try {
      await _player.seek(Duration.zero);
    } catch (_) {}

    final metadata = QuranAudioSession.metadata;
    final duration = _player.duration;
    mediaItem.add(
      MediaItem(
        id: source,
        title: title ?? metadata?.notificationTitle ?? 'تلاوة القرآن',
        artist: artist ?? metadata?.reciterName ?? 'وردي',
        duration: duration,
        playable: true,
        extras: {
          if (metadata != null) 'surah_number': metadata.surahNumber,
          if (metadata != null) 'ayah_number': metadata.ayahNumber,
        },
      ),
    );
    _broadcastPlaybackState(null);
  }

  void _broadcastPlaybackState(PlaybackEvent? event) {
    final controls = <MediaControl>[
      if (QuranAudioSession.canSkipPrevious) MediaControl.skipToPrevious,
      if (_player.playing) MediaControl.pause else MediaControl.play,
      if (QuranAudioSession.canSkipNext) MediaControl.skipToNext,
      MediaControl.stop,
    ];

    final compactIndices = <int>[];
    for (var i = 0; i < controls.length && compactIndices.length < 3; i++) {
      final control = controls[i];
      if (control == MediaControl.stop) continue;
      compactIndices.add(i);
    }

    playbackState.add(
      playbackState.value.copyWith(
        controls: controls,
        systemActions: const {
          MediaAction.seek,
          MediaAction.skipToNext,
          MediaAction.skipToPrevious,
        },
        androidCompactActionIndices: compactIndices,
        processingState: const {
          ProcessingState.idle: AudioProcessingState.idle,
          ProcessingState.loading: AudioProcessingState.loading,
          ProcessingState.buffering: AudioProcessingState.buffering,
          ProcessingState.ready: AudioProcessingState.ready,
          ProcessingState.completed: AudioProcessingState.completed,
        }[_player.processingState]!,
        playing: _player.playing,
        updatePosition: _player.position,
        bufferedPosition: _player.bufferedPosition,
        speed: _player.speed,
      ),
    );
  }

  void refreshControls() => _broadcastPlaybackState(null);

  @override
  Future<void> onTaskRemoved() async {
    await stop();
  }

  Future<void> disposeHandler() async {
    for (final subscription in _subscriptions) {
      await subscription.cancel();
    }
    await _player.dispose();
  }
}
