import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

/// Downloads remote ayah MP3s to a local cache so ExoPlayer does not stall
/// on flaky CDN streaming (common on Android emulators).
final class AudioFileCache {
  AudioFileCache._();

  static final Dio _dio = Dio(
    BaseOptions(
      connectTimeout: const Duration(seconds: 12),
      receiveTimeout: const Duration(seconds: 30),
      followRedirects: true,
      validateStatus: (code) => code != null && code >= 200 && code < 400,
      headers: const {
        'User-Agent': 'Werdi/1.0 (Quran audio; Flutter)',
        'Accept': 'audio/mpeg,audio/*;q=0.9,*/*;q=0.8',
      },
    ),
  );

  static Directory? _cacheDir;

  static Future<Directory> _dir() async {
    final existing = _cacheDir;
    if (existing != null) return existing;
    final root = await getTemporaryDirectory();
    final dir = Directory(p.join(root.path, 'werdi_audio_cache'));
    if (!await dir.exists()) {
      await dir.create(recursive: true);
    }
    _cacheDir = dir;
    return dir;
  }

  /// Returns a local filesystem path for [url] (downloads when needed).
  static Future<String> resolve(String url) async {
    if (!url.startsWith('http://') && !url.startsWith('https://')) {
      return url;
    }

    final dir = await _dir();
    final key = url.hashCode & 0x7fffffff;
    final file = File(p.join(dir.path, 'a_$key.mp3'));

    if (await file.exists()) {
      final length = await file.length();
      if (length > 1024) return file.path;
      await file.delete();
    }

    if (kDebugMode) {
      debugPrint('Audio cache download: $url');
    }
    await _dio.download(url, file.path);
    final length = await file.length();
    if (length < 1024) {
      await file.delete();
      throw StateError('audio_download_too_small');
    }
    return file.path;
  }
}
