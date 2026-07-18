import 'package:audio_session/audio_session.dart';
import 'package:flutter/foundation.dart';
import 'package:just_audio/just_audio.dart';
import 'package:werdi/core/audio/audio_service_controller.dart';
import 'package:werdi/core/audio/quran_audio_handler.dart';
import 'package:werdi/core/audio/quran_audio_session.dart';
import 'package:werdi/shared/repositories/audio_repository.dart';

class JustAudioRepository implements AudioRepository {
  JustAudioRepository({
    AudioPlayer? player,
    QuranAudioHandler? handler,
  })  : _handler = handler,
        _player = player ?? handler?.player ?? AudioPlayer();

  final QuranAudioHandler? _handler;
  final AudioPlayer _player;

  bool _armedForCompletion = false;
  DateTime _ignoreCompletionUntil = DateTime.fromMillisecondsSinceEpoch(0);

  @override
  Stream<void> get onPlaybackCompleted {
    return _player.processingStateStream.where((state) {
      if (state == ProcessingState.ready ||
          state == ProcessingState.buffering) {
        _armedForCompletion = true;
        return false;
      }
      if (state != ProcessingState.completed) return false;
      if (!_armedForCompletion) return false;
      if (DateTime.now().isBefore(_ignoreCompletionUntil)) return false;
      _armedForCompletion = false;
      return true;
    }).map((_) {});
  }

  Future<void> _activateSession() async {
    try {
      final session = await AudioSession.instance;
      await session.setActive(true);
    } catch (error) {
      if (kDebugMode) {
        debugPrint('AudioSession.setActive failed: $error');
      }
    }
  }

  @override
  Future<void> loadSource({required String source}) async {
    _armedForCompletion = false;
    _ignoreCompletionUntil =
        DateTime.now().add(const Duration(milliseconds: 600));

    try {
      await _player.stop();
    } catch (_) {}

    final handler = _handler;
    if (handler != null) {
      await handler
          .loadSource(source: source)
          .timeout(const Duration(seconds: 15));
    } else if (source.startsWith('http://') || source.startsWith('https://')) {
      await _player.setUrl(source).timeout(const Duration(seconds: 15));
    } else {
      await _player.setFilePath(source).timeout(const Duration(seconds: 10));
    }

    try {
      await _player.seek(Duration.zero);
    } catch (_) {}
  }

  @override
  Future<void> pause() => _player.pause();

  @override
  Future<void> play() async {
    await _activateSession();
    await _player.setVolume(1.0);
    await _player.play();
    AudioServiceController.handler?.refreshControls();
  }

  @override
  Future<void> ensurePlaybackStarted({
    Duration timeout = const Duration(seconds: 10),
  }) async {
    final deadline = DateTime.now().add(timeout);
    var readyTicks = 0;
    while (DateTime.now().isBefore(deadline)) {
      final state = _player.processingState;
      final positionMs = _player.position.inMilliseconds;
      final durationMs = _player.duration?.inMilliseconds ?? 0;

      if (state == ProcessingState.completed && positionMs > 0) return;
      if (_player.playing && positionMs >= 30) return;

      if (_player.playing &&
          (state == ProcessingState.ready ||
              state == ProcessingState.buffering) &&
          durationMs > 0) {
        readyTicks++;
        if (readyTicks >= 3) return;
      } else {
        readyTicks = 0;
      }

      await Future<void>.delayed(const Duration(milliseconds: 120));
    }

    try {
      await _player.pause();
    } catch (_) {}
    throw StateError('playback_stalled');
  }

  @override
  Future<void> waitForCurrentTrackEnd({
    Duration timeout = const Duration(minutes: 3),
    bool Function()? shouldCancel,
  }) async {
    final deadline = DateTime.now().add(timeout);
    var sawPlaying = false;
    var lastPositionMs = -1;
    var stuckTicks = 0;

    while (DateTime.now().isBefore(deadline)) {
      if (shouldCancel?.call() ?? false) return;

      final state = _player.processingState;
      final playing = _player.playing;
      final position = _player.position;
      final duration = _player.duration;
      final positionMs = position.inMilliseconds;
      final durationMs = duration?.inMilliseconds ?? 0;

      if (playing) sawPlaying = true;

      // Primary signal from just_audio / ExoPlayer.
      if (state == ProcessingState.completed) {
        if (kDebugMode) {
          debugPrint('Track end: processingState=completed');
        }
        return;
      }

      // Fallback: position reached (or passed) the known duration.
      if (sawPlaying && durationMs > 200) {
        final nearEnd = positionMs >= durationMs - 120;
        final atEnd = positionMs >= durationMs;
        if (atEnd || (nearEnd && !playing)) {
          if (kDebugMode) {
            debugPrint(
              'Track end: position=$positionMs duration=$durationMs playing=$playing',
            );
          }
          return;
        }
      }

      // Fallback: was playing, then stopped near the end without completed.
      if (sawPlaying &&
          !playing &&
          durationMs > 200 &&
          positionMs >= (durationMs * 0.9).round()) {
        if (kDebugMode) {
          debugPrint('Track end: paused/stopped near end');
        }
        return;
      }

      // Detect mid-track stall (position frozen while "playing").
      if (playing && positionMs == lastPositionMs && positionMs > 0) {
        stuckTicks++;
        if (stuckTicks >= 40) {
          // ~4s frozen — treat as ended so playlist can continue.
          if (kDebugMode) {
            debugPrint('Track end: position stalled at $positionMs');
          }
          return;
        }
      } else {
        stuckTicks = 0;
      }
      lastPositionMs = positionMs;

      await Future<void>.delayed(const Duration(milliseconds: 100));
    }

    if (kDebugMode) {
      debugPrint('Track end: wait timed out');
    }
  }

  @override
  Future<void> seek(Duration position) => _player.seek(position);

  @override
  Future<void> setSpeed(double speed) => _player.setSpeed(speed);

  @override
  Future<void> softReset() async {
    _armedForCompletion = false;
    _ignoreCompletionUntil =
        DateTime.now().add(const Duration(milliseconds: 400));
    try {
      await _player.stop();
    } catch (_) {}
  }

  @override
  Future<void> stop() async {
    _armedForCompletion = false;
    try {
      await _player.stop();
    } catch (_) {}
    QuranAudioSession.clear();
    final handler = _handler;
    if (handler != null) {
      try {
        await handler.stop();
      } catch (_) {}
    }
    AudioServiceController.handler?.refreshControls();
  }
}
