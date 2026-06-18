import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:werdi/features/quran/domain/models/quran_text_source.dart';
import 'package:werdi/features/quran/domain/models/quran_verse.dart';

class TrustedQuranRemoteService {
  TrustedQuranRemoteService({Dio? dio}) : _dio = dio ?? Dio();

  final Dio _dio;

  static const String _quranComUthmaniApi =
      'https://api.quran.com/api/v4/quran/verses/uthmani';
  static const String _tanzilUthmaniDataset =
      'https://raw.githubusercontent.com/tanzil-net/tanzil/master/quran-uthmani.txt';

  Future<TrustedQuranRemoteResult?> fetchSurah(int surahNumber) async {
    final quranCom = await _fetchFromQuranCom(surahNumber);
    if (quranCom != null && quranCom.isNotEmpty) {
      return TrustedQuranRemoteResult(
        verses: quranCom,
        source: QuranTextSource.quranCom,
      );
    }

    final tanzil = await _fetchFromTanzil(surahNumber);
    if (tanzil != null && tanzil.isNotEmpty) {
      return TrustedQuranRemoteResult(
        verses: tanzil,
        source: QuranTextSource.tanzil,
      );
    }
    return null;
  }

  Future<List<QuranVerse>?> _fetchFromQuranCom(int surahNumber) async {
    try {
      final response = await _dio.get<dynamic>(
        _quranComUthmaniApi,
        queryParameters: <String, dynamic>{
          'chapter_number': surahNumber,
        },
      );
      final body = response.data;
      if (body is! Map) return null;
      final versesRaw = body['verses'];
      if (versesRaw is! List) return null;

      final verses = <QuranVerse>[];
      for (final item in versesRaw) {
        if (item is! Map) continue;
        final key = item['verse_key']?.toString();
        final text = item['text_uthmani']?.toString();
        if (key == null || text == null || text.trim().isEmpty) continue;

        final segments = key.split(':');
        if (segments.length != 2) continue;
        final ayah = int.tryParse(segments[1]);
        if (ayah == null) continue;
        verses.add(QuranVerse(ayahNumber: ayah, text: text.trim()));
      }
      verses.sort((a, b) => a.ayahNumber.compareTo(b.ayahNumber));
      return verses;
    } catch (_) {
      return null;
    }
  }

  Future<List<QuranVerse>?> _fetchFromTanzil(int surahNumber) async {
    try {
      final response = await _dio.get<String>(_tanzilUthmaniDataset);
      final data = response.data;
      if (data == null || data.isEmpty) return null;

      final content = _ensureUtf8(data);
      final verses = <QuranVerse>[];
      final lines = content.split('\n');
      for (final line in lines) {
        final trimmed = line.trim();
        if (trimmed.isEmpty || trimmed.startsWith('#')) continue;
        final parts = trimmed.split('|');
        if (parts.length < 3) continue;
        final surah = int.tryParse(parts[0]);
        final ayah = int.tryParse(parts[1]);
        if (surah != surahNumber || ayah == null) continue;
        final text = parts.sublist(2).join('|').trim();
        if (text.isEmpty) continue;
        verses.add(QuranVerse(ayahNumber: ayah, text: text));
      }
      verses.sort((a, b) => a.ayahNumber.compareTo(b.ayahNumber));
      return verses;
    } catch (_) {
      return null;
    }
  }

  String _ensureUtf8(String input) {
    final codeUnits = input.codeUnits;
    return utf8.decode(codeUnits, allowMalformed: true);
  }
}

class TrustedQuranRemoteResult {
  const TrustedQuranRemoteResult({
    required this.verses,
    required this.source,
  });

  final List<QuranVerse> verses;
  final QuranTextSource source;
}
