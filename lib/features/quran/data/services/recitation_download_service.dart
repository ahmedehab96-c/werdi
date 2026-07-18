import 'dart:io';

import 'package:dio/dio.dart';
import 'package:quran/quran.dart' as quran_pkg;
import 'package:werdi/features/quran/data/services/quran_service.dart';
import 'package:werdi/features/quran/data/services/recitation_offline_storage.dart';
import 'package:werdi/features/quran/domain/models/quran_audio_reciter.dart';

class RecitationDownloadProgress {
  const RecitationDownloadProgress({
    required this.completedAyahs,
    required this.totalAyahs,
    required this.currentAyah,
  });

  final int completedAyahs;
  final int totalAyahs;
  final int currentAyah;

  double get fraction =>
      totalAyahs == 0 ? 0 : completedAyahs / totalAyahs;
}

class RecitationDownloadService {
  RecitationDownloadService({
    required QuranService quranService,
    required RecitationOfflineStorage storage,
    Dio? dio,
  })  : _quranService = quranService,
        _storage = storage,
        _dio = dio ??
            Dio(
              BaseOptions(
                connectTimeout: const Duration(seconds: 20),
                receiveTimeout: const Duration(seconds: 30),
              ),
            );

  final QuranService _quranService;
  final RecitationOfflineStorage _storage;
  final Dio _dio;

  Future<bool> downloadSurah({
    required QuranAudioReciter reciter,
    required int surahNumber,
    void Function(RecitationDownloadProgress progress)? onProgress,
  }) async {
    final verseCount = quran_pkg.getVerseCount(surahNumber);
    var completed = 0;

    for (var ayah = 1; ayah <= verseCount; ayah++) {
      onProgress?.call(
        RecitationDownloadProgress(
          completedAyahs: completed,
          totalAyahs: verseCount,
          currentAyah: ayah,
        ),
      );

      final existing = await _storage.existingAyahFilePath(
        reciterKey: reciter.persistenceKey,
        surahNumber: surahNumber,
        ayahNumber: ayah,
      );
      if (existing != null) {
        completed++;
        continue;
      }

      final urls = _quranService.getAudioURLsForCatalogReciter(
        surahNumber,
        ayah,
        reciter,
        ayahOnly: true,
      );
      final saved = await _downloadFirstWorkingUrl(
        urls: urls,
        destination: await _storage.ayahFilePath(
          reciterKey: reciter.persistenceKey,
          surahNumber: surahNumber,
          ayahNumber: ayah,
        ),
      );
      if (!saved) return false;
      completed++;
    }

    onProgress?.call(
      RecitationDownloadProgress(
        completedAyahs: completed,
        totalAyahs: verseCount,
        currentAyah: verseCount,
      ),
    );
    return true;
  }

  Future<bool> _downloadFirstWorkingUrl({
    required List<String> urls,
    required String destination,
  }) async {
    for (final url in urls) {
      try {
        await _dio.download(url, destination);
        final file = File(destination);
        if (await file.exists() && await file.length() > 512) {
          return true;
        }
      } catch (_) {}
    }
    return false;
  }
}
