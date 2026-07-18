import 'package:flutter/foundation.dart';
import 'package:werdi/core/audio/audio_playback.dart';
import 'package:werdi/core/audio/quran_audio_session.dart';
import 'package:werdi/features/quran/domain/models/quran_audio_reciter.dart';
import 'package:werdi/shared/repositories/audio_repository.dart';

typedef AyahUrlResolver = List<String> Function(int ayahNumber);

/// Plays a contiguous ayah range sequentially (ayah-by-ayah queue).
class AyahPlaylistPlayer {
  AyahPlaylistPlayer(this._audio);

  final AudioRepository _audio;
  bool _active = false;
  bool _skipRequested = false;
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
    _skipRequested = false;
    _surahNumber = surahNumber;
    _surahNameArabic = surahNameArabic;
    _startAyah = start;
    _currentAyah = start;
    _endAyah = end;
    _reciter = reciter;
    _urlResolver = urlResolver;
    _onAyahChanged = onAyahChanged;
    _onCompleted = onCompleted;

    if (kDebugMode) {
      debugPrint('Playlist start surah=$surahNumber ayahs=$start-$end');
    }

    try {
      for (var ayah = start; ayah <= end; ayah++) {
        if (!_active) return;
        _currentAyah = ayah;
        _skipRequested = false;
        _onAyahChanged?.call(ayah);

        final played = await _playAyah(ayah);
        if (!_active) return;
        if (!played) {
          if (kDebugMode) {
            debugPrint('Playlist skip failed ayah $ayah — continuing');
          }
          continue;
        }

        await _audio.waitForCurrentTrackEnd(
          shouldCancel: () => !_active || _skipRequested,
        );
        if (!_active) return;

        if (_skipRequested) {
          try {
            await _audio.softReset();
          } catch (_) {}
        }

        if (kDebugMode) {
          debugPrint('Playlist finished ayah $ayah — next');
        }
      }
    } finally {
      final done = _onCompleted;
      _active = false;
      _urlResolver = null;
      _onAyahChanged = null;
      _onCompleted = null;
      done?.call();
      if (kDebugMode) {
        debugPrint('Playlist ended surah=$surahNumber');
      }
    }
  }

  Future<bool> _playAyah(int ayah) async {
    final resolver = _urlResolver;
    final reciter = _reciter;
    if (resolver == null || reciter == null) return false;

    final urls = resolver(ayah);
    if (urls.isEmpty) return false;

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
        onSkipNext: ayah < _endAyah ? _requestSkip : null,
        onSkipPrevious: ayah > _startAyah ? _requestSkip : null,
      );
      return true;
    } catch (error) {
      if (kDebugMode) {
        debugPrint('Playlist ayah $ayah failed: $error');
      }
      return false;
    }
  }

  void _requestSkip() {
    _skipRequested = true;
  }

  Future<void> stop() async {
    _active = false;
    _skipRequested = true;
    _urlResolver = null;
    _onAyahChanged = null;
    _onCompleted = null;
    try {
      await _audio.stop();
    } catch (_) {}
  }
}
