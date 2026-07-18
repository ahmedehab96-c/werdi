import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

/// Local filesystem paths for downloaded ayah recitations.
class RecitationOfflineStorage {
  RecitationOfflineStorage();

  @visibleForTesting
  RecitationOfflineStorage.withRootPath(String path) : _rootPath = path;

  static const rootFolderName = 'recitations';
  String? _rootPath;

  Future<void> ensureReady() async {
    if (_rootPath != null) return;
    _rootPath = (await rootDirectory).path;
  }

  Future<Directory> get rootDirectory async {
    final docs = await getApplicationDocumentsDirectory();
    final dir = Directory(p.join(docs.path, rootFolderName));
    if (!await dir.exists()) {
      await dir.create(recursive: true);
    }
    return dir;
  }

  String? existingAyahFilePathSync({
    required String reciterKey,
    required int surahNumber,
    required int ayahNumber,
  }) {
    final root = _rootPath;
    if (root == null) return null;
    final surah = surahNumber.toString().padLeft(3, '0');
    final ayah = ayahNumber.toString().padLeft(3, '0');
    final path = p.join(root, reciterKey, '$surah$ayah.mp3');
    final file = File(path);
    if (file.existsSync() && file.lengthSync() > 512) {
      return path;
    }
    return null;
  }

  Future<String> ayahFilePath({
    required String reciterKey,
    required int surahNumber,
    required int ayahNumber,
  }) async {
    final root = await rootDirectory;
    final surah = surahNumber.toString().padLeft(3, '0');
    final ayah = ayahNumber.toString().padLeft(3, '0');
    final reciterDir = Directory(p.join(root.path, reciterKey));
    if (!await reciterDir.exists()) {
      await reciterDir.create(recursive: true);
    }
    return p.join(reciterDir.path, '$surah$ayah.mp3');
  }

  Future<String?> existingAyahFilePath({
    required String reciterKey,
    required int surahNumber,
    required int ayahNumber,
  }) async {
    final path = await ayahFilePath(
      reciterKey: reciterKey,
      surahNumber: surahNumber,
      ayahNumber: ayahNumber,
    );
    final file = File(path);
    if (await file.exists() && await file.length() > 512) {
      return path;
    }
    return null;
  }

  Future<bool> isSurahDownloaded({
    required String reciterKey,
    required int surahNumber,
    required int verseCount,
  }) async {
    for (var ayah = 1; ayah <= verseCount; ayah++) {
      final local = await existingAyahFilePath(
        reciterKey: reciterKey,
        surahNumber: surahNumber,
        ayahNumber: ayah,
      );
      if (local == null) return false;
    }
    return true;
  }

  Future<void> deleteSurah({
    required String reciterKey,
    required int surahNumber,
    required int verseCount,
  }) async {
    for (var ayah = 1; ayah <= verseCount; ayah++) {
      final path = await ayahFilePath(
        reciterKey: reciterKey,
        surahNumber: surahNumber,
        ayahNumber: ayah,
      );
      final file = File(path);
      if (await file.exists()) {
        await file.delete();
      }
    }
  }
}
