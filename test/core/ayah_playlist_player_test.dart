import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:werdi/core/audio/ayah_playlist_player.dart';
import 'package:werdi/features/quran/domain/models/quran_audio_reciter.dart';
import 'package:werdi/shared/repositories/audio_repository.dart';

class _FakeAudioRepository implements AudioRepository {
  final _completionController = StreamController<void>.broadcast();
  final List<String> loadedSources = [];

  @override
  Stream<void> get onPlaybackCompleted => _completionController.stream;

  @override
  Future<void> loadSource({required String source}) async {
    loadedSources.add(source);
  }

  @override
  Future<void> pause() async {}

  @override
  Future<void> play() async {}

  @override
  Future<void> seek(Duration position) async {}

  @override
  Future<void> setSpeed(double speed) async {}

  @override
  Future<void> stop() async {}

  void completeCurrent() {
    _completionController.add(null);
  }

  void dispose() {
    _completionController.close();
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

    tearDown(() {
      audio.dispose();
    });

    test('plays ayahs sequentially until range ends', () async {
      final played = <int>[];
      var completed = false;

      await player.playRange(
        surahNumber: 1,
        surahNameArabic: 'الفاتحة',
        startAyah: 1,
        endAyah: 3,
        reciter: QuranAudioReciter.ayahCapable().first,
        urlResolver: (ayah) => ['file:///ayah$ayah.mp3'],
        onAyahChanged: played.add,
        onCompleted: () => completed = true,
      );

      expect(played, [1]);
      expect(audio.loadedSources, ['file:///ayah1.mp3']);

      audio.completeCurrent();
      await Future<void>.delayed(Duration.zero);
      expect(played, [1, 2]);

      audio.completeCurrent();
      await Future<void>.delayed(Duration.zero);
      expect(played, [1, 2, 3]);

      audio.completeCurrent();
      await Future<void>.delayed(Duration.zero);
      expect(player.isActive, isFalse);
      expect(completed, isTrue);
    });

    test('notifies completion when urls are empty', () async {
      var completed = false;

      await player.playRange(
        surahNumber: 1,
        surahNameArabic: 'الفاتحة',
        startAyah: 1,
        endAyah: 3,
        reciter: QuranAudioReciter.ayahCapable().first,
        urlResolver: (_) => const [],
        onCompleted: () => completed = true,
      );

      expect(player.isActive, isFalse);
      expect(completed, isTrue);
    });
  });
}
