import 'dart:async';

import 'package:werdi/core/audio/audio_playback.dart';
import 'package:werdi/core/audio/quran_audio_session.dart';
import 'package:werdi/features/quran/domain/models/quran_audio_reciter.dart';
import 'package:werdi/shared/repositories/audio_repository.dart';

typedef AyahUrlResolver = List<String> Function(int ayahNumber);

/// Plays a contiguous ayah range sequentially (ayah-by-ayah queue).
class AyahPlaylistPlayer {
  AyahPlaylistPlayer(this._audio);

  final AudioRepository _audio;
  StreamSubscription<void>? _completionSub;
  bool _active = false;
  bool _advancing = false;
  int _startAyah = 1;
  int _currentAyah = 1;
  int _endAyah = 1;
  int _surahNumber = 1;
  String _surahNameArabic = '';
  QuranAudioReciter? _reciter;
  AyahUrlResolver? _urlResolver;
  void Function(int ayah)? _onAyahChanged;
  void Function()? _onCompleted;

  bool get isActive => _active;

  int? get currentAyah => _active ? _currentAyah : null;

  Future<void> playRange({
    required int surahNumber,
    required String surahNameArabic,
    required int startAyah,
    required int endAyah,
    required QuranAudioReciter reciter,
    required AyahUrlResolver urlResolver,
    void Function(int ayah)? onAyahChanged,
    void Function()? onCompleted,
  }) async {
    final start = startAyah.clamp(1, endAyah);
    final end = endAyah.clamp(start, 9999);

    await stop();
    _active = true;
    _advancing = false;
    _surahNumber = surahNumber;
    _surahNameArabic = surahNameArabic;
    _startAyah = start;
    _currentAyah = start;
    _endAyah = end;
    _reciter = reciter;
    _urlResolver = urlResolver;
    _onAyahChanged = onAyahChanged;
    _onCompleted = onCompleted;

    _completionSub = _audio.onPlaybackCompleted.listen((_) {
      unawaited(_handleAyahCompleted());
    });

    await _playCurrentAyah();
  }

  Future<void> stop() async {
    _active = false;
    _advancing = false;
    await _completionSub?.cancel();
    _completionSub = null;
    _urlResolver = null;
    _onAyahChanged = null;
    _onCompleted = null;
    await _audio.stop();
  }

  Future<void> _finish({required bool notifyCompleted}) async {
    final done = _onCompleted;
    _onCompleted = null;
    _active = false;
    _advancing = false;
    await _completionSub?.cancel();
    _completionSub = null;
    _urlResolver = null;
    _onAyahChanged = null;
    await _audio.stop();
    if (notifyCompleted) done?.call();
  }

  Future<void> _handleAyahCompleted() async {
    if (!_active || _advancing) return;
    _advancing = true;
    try {
      if (_currentAyah >= _endAyah) {
        await _finish(notifyCompleted: true);
        return;
      }
      _currentAyah++;
      await _playCurrentAyah();
    } finally {
      _advancing = false;
    }
  }

  Future<void> _playCurrentAyah() async {
    if (!_active) return;
    final resolver = _urlResolver;
    final reciter = _reciter;
    if (resolver == null || reciter == null) {
      await _finish(notifyCompleted: true);
      return;
    }

    final urls = resolver(_currentAyah);
    if (urls.isEmpty) {
      await _finish(notifyCompleted: true);
      return;
    }

    _onAyahChanged?.call(_currentAyah);

    final ayah = _currentAyah;
    try {
      await playAudioUrlsWithFallback(
        _audio,
        urls: urls,
        metadata: AyahPlaybackMetadata(
          surahNumber: _surahNumber,
          surahNameArabic: _surahNameArabic,
          ayahNumber: ayah,
          reciterName: reciter.name,
        ),
        onSkipNext: ayah < _endAyah
            ? () {
                if (!_active || _advancing) return;
                _advancing = true;
                _currentAyah = ayah + 1;
                unawaited(() async {
                  try {
                    await _playCurrentAyah();
                  } finally {
                    _advancing = false;
                  }
                }());
              }
            : null,
        onSkipPrevious: ayah > _startAyah
            ? () {
                if (!_active || _advancing) return;
                _advancing = true;
                _currentAyah = ayah - 1;
                unawaited(() async {
                  try {
                    await _playCurrentAyah();
                  } finally {
                    _advancing = false;
                  }
                }());
              }
            : null,
      );
    } catch (_) {
      await _finish(notifyCompleted: true);
    }
  }
}
