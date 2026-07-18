import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:werdi/core/audio/ayah_playlist_player.dart';
import 'package:werdi/features/quran/domain/models/quran_audio_reciter.dart';
import 'package:werdi/shared/repositories/audio_repository.dart';

class _FakeAudioRepository implements AudioRepository {
  final List<String> loadedSources = [];
  Completer<void>? _trackEnd;

  @override
  Stream<void> get onPlaybackCompleted => const Stream.empty();

  @override
  Future<void> loadSource({required String source}) async {
    loadedSources.add(source);
    _trackEnd = Completer<void>();
  }

  @override
  Future<void> pause() async {}

  @override
  Future<void> play() async {}

  @override
  Future<void> ensurePlaybackStarted({
    Duration timeout = const Duration(seconds: 10),
  }) async {}

  @override
  Future<void> waitForCurrentTrackEnd({
    Duration timeout = const Duration(minutes: 3),
    bool Function()? shouldCancel,
  }) async {
    final pending = _trackEnd;
    if (pending == null) return;
    while (!pending.isCompleted) {
      if (shouldCancel?.call() ?? false) return;
      await Future.any([
        pending.future,
        Future<void>.delayed(const Duration(milliseconds: 10)),
      ]);
    }
  }

  @override
  Future<void> softReset() async {}

  @override
  Future<void> seek(Duration position) async {}

  @override
  Future<void> setSpeed(double speed) async {}

  @override
  Future<void> stop() async {
    _trackEnd?.complete();
    _trackEnd = null;
  }

  void completeCurrent() {
    final pending = _trackEnd;
    if (pending != null && !pending.isCompleted) {
      pending.complete();
    }
  }
}

void main() {
  group('AyahPlaylistPlayer', () {
    late _FakeAudioRepository audio;
    late AyahPlaylistPlayer player;

    setUp(() {
      audio = _FakeAudioRepository();
      player = AyahPlaylistPlayer(audio);
    });

    test('plays ayahs sequentially until range ends', () async {
      final played = <int>[];
      var completed = false;

      final run = player.playRange(
        surahNumber: 1,
        surahNameArabic: 'الفاتحة',
        startAyah: 1,
        endAyah: 3,
        reciter: QuranAudioReciter.ayahCapable().first,
        urlResolver: (ayah) => ['file:///ayah$ayah.mp3'],
        onAyahChanged: played.add,
        onCompleted: () => completed = true,
      );

      await Future<void>.delayed(Duration.zero);
      expect(played, [1]);
      expect(audio.loadedSources, ['file:///ayah1.mp3']);

      audio.completeCurrent();
      await Future<void>.delayed(const Duration(milliseconds: 20));
      expect(played, [1, 2]);

      audio.completeCurrent();
      await Future<void>.delayed(const Duration(milliseconds: 20));
      expect(played, [1, 2, 3]);

      audio.completeCurrent();
      await run;
      expect(player.isActive, isFalse);
      expect(completed, isTrue);
    });

    test('skips failed ayah and continues the range', () async {
      final played = <int>[];

      final run = player.playRange(
        surahNumber: 1,
        surahNameArabic: 'الفاتحة',
        startAyah: 1,
        endAyah: 3,
        reciter: QuranAudioReciter.ayahCapable().first,
        urlResolver: (ayah) {
          if (ayah == 2) return const [];
          return ['file:///ayah$ayah.mp3'];
        },
        onAyahChanged: played.add,
      );

      await Future<void>.delayed(Duration.zero);
      expect(played, [1]);
      audio.completeCurrent();
      await Future<void>.delayed(const Duration(milliseconds: 20));
      // ayah 2 fails (empty urls), continues to 3
      expect(played, [1, 2, 3]);
      audio.completeCurrent();
      await run;
      expect(player.isActive, isFalse);
    });
  });
}
