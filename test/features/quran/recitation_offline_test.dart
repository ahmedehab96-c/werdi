import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:werdi/features/quran/data/repositories/quran_repository_impl.dart';
import 'package:werdi/features/quran/data/services/quran_service.dart';
import 'package:werdi/features/quran/data/services/recitation_offline_storage.dart';
import 'package:werdi/features/quran/domain/models/quran_audio_reciter.dart';

void main() {
  group('RecitationOfflineStorage', () {
    late Directory tempDir;
    late RecitationOfflineStorage storage;

    setUp(() async {
      tempDir = await Directory.systemTemp.createTemp('werdi_recitation_test');
      storage = RecitationOfflineStorage.withRootPath(tempDir.path);
    });

    tearDown(() async {
      if (await tempDir.exists()) {
        await tempDir.delete(recursive: true);
      }
    });

    test('existingAyahFilePathSync returns path for valid mp3', () async {
      final reciterKey = 'mp3quran_123';
      final file = File('${tempDir.path}/$reciterKey/001001.mp3');
      await file.parent.create(recursive: true);
      await file.writeAsBytes(List<int>.filled(600, 1));

      final path = storage.existingAyahFilePathSync(
        reciterKey: reciterKey,
        surahNumber: 1,
        ayahNumber: 1,
      );

      expect(path, file.path);
    });

    test('existingAyahFilePathSync ignores tiny files', () async {
      final reciterKey = 'mp3quran_123';
      final file = File('${tempDir.path}/$reciterKey/001001.mp3');
      await file.parent.create(recursive: true);
      await file.writeAsBytes([1, 2, 3]);

      final path = storage.existingAyahFilePathSync(
        reciterKey: reciterKey,
        surahNumber: 1,
        ayahNumber: 1,
      );

      expect(path, isNull);
    });
  });

  group('QuranRepositoryImpl offline priority', () {
    test('prefers local ayah file before remote urls', () async {
      final tempDir = await Directory.systemTemp.createTemp('werdi_repo_test');
      addTearDown(() async {
        if (await tempDir.exists()) {
          await tempDir.delete(recursive: true);
        }
      });

      final reciter = QuranAudioReciter.ayahCapable().first;
      final localFile = File(
        '${tempDir.path}/${reciter.persistenceKey}/001001.mp3',
      );
      await localFile.parent.create(recursive: true);
      await localFile.writeAsBytes(List<int>.filled(600, 1));

      final storage = RecitationOfflineStorage.withRootPath(tempDir.path);
      final repository = QuranRepositoryImpl(
        service: const QuranPackageService(),
        offlineStorage: storage,
      );

      final urls = repository.getAudioAyahUrls(
        surahNumber: 1,
        ayahNumber: 1,
        reciter: reciter,
      );

      expect(urls.first, localFile.path);
      expect(urls.length, greaterThan(1));
    });
  });
}
