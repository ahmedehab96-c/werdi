import 'package:dio/dio.dart';
import 'package:werdi/features/quran/data/services/offline_quran_tafsir_service.dart';
import 'package:werdi/features/quran/domain/models/tafsir_item.dart';
import 'package:werdi/features/quran/domain/services/quran_tafsir_service.dart';

/// Real tafsir provider backed by https://api.alquran.cloud.
///
/// If the remote API is unavailable, it falls back to the offline provider
/// so the UI keeps working.
class RemoteQuranTafsirService implements QuranTafsirService {
  RemoteQuranTafsirService({QuranTafsirService? fallback})
      : _fallback = fallback ?? const OfflineQuranTafsirService(),
        _dio = Dio(
          BaseOptions(
            baseUrl: 'https://api.alquran.cloud/v1',
            connectTimeout: const Duration(seconds: 20),
            receiveTimeout: const Duration(seconds: 20),
          ),
        );

  final QuranTafsirService _fallback;
  final Dio _dio;

  static const _preferredSourceOrder = <String>[
    // Egyptian-oriented preference first, then common simple tafsir.
    'ar.waseet',
    'ar.muyassar',
  ];

  @override
  Future<List<String>> getAvailableSources() async {
    try {
      final response = await _dio.get<Map<String, dynamic>>(
        '/edition/type/tafsir',
      );
      final raw = response.data?['data'];
      final editions = raw is List ? raw : const [];
      final sources = editions
          .whereType<Map>()
          .map((e) => e['identifier'])
          .whereType<String>()
          .toSet()
          .toList();

      if (sources.isEmpty) {
        return _fallback.getAvailableSources();
      }

      sources.sort((a, b) {
        final ia = _preferredSourceOrder.indexOf(a);
        final ib = _preferredSourceOrder.indexOf(b);
        if (ia != -1 || ib != -1) {
          if (ia == -1) return 1;
          if (ib == -1) return -1;
          return ia.compareTo(ib);
        }
        return a.compareTo(b);
      });
      return sources;
    } catch (_) {
      return _fallback.getAvailableSources();
    }
  }

  @override
  Future<TafsirItem> getTafsir({
    required int surahNumber,
    required int ayahStart,
    required int ayahEnd,
    required String source,
  }) async {
    final sourceId = _normalizeSourceIdentifier(source);
    try {
      final response = await _dio.get<Map<String, dynamic>>(
        '/surah/$surahNumber/$sourceId',
      );
      final data = response.data?['data'];
      if (data is! Map) {
        return _fallback.getTafsir(
          surahNumber: surahNumber,
          ayahStart: ayahStart,
          ayahEnd: ayahEnd,
          source: source,
        );
      }

      final ayahsRaw = data['ayahs'];
      final ayahs = ayahsRaw is List ? ayahsRaw.whereType<Map>().toList() : [];
      if (ayahs.isEmpty) {
        return _fallback.getTafsir(
          surahNumber: surahNumber,
          ayahStart: ayahStart,
          ayahEnd: ayahEnd,
          source: source,
        );
      }

      final buffer = StringBuffer();
      for (final ayah in ayahs) {
        final number = ayah['numberInSurah'];
        final text = ayah['text'];
        if (number is! int || text is! String) continue;
        if (number < ayahStart || number > ayahEnd) continue;
        buffer.writeln('($number) $text');
        if (number < ayahEnd) buffer.writeln();
      }

      final tafsirText = buffer.toString().trim();
      if (tafsirText.isEmpty) {
        return _fallback.getTafsir(
          surahNumber: surahNumber,
          ayahStart: ayahStart,
          ayahEnd: ayahEnd,
          source: source,
        );
      }

      return TafsirItem(
        surahNumber: surahNumber,
        ayahStart: ayahStart,
        ayahEnd: ayahEnd,
        source: _sourceDisplayLabel(sourceId),
        text: tafsirText,
      );
    } catch (_) {
      return _fallback.getTafsir(
        surahNumber: surahNumber,
        ayahStart: ayahStart,
        ayahEnd: ayahEnd,
        source: source,
      );
    }
  }

  String _normalizeSourceIdentifier(String raw) {
    final source = raw.trim();
    for (final known in _preferredSourceOrder) {
      if (source.contains(known)) return known;
    }
    if (source.contains('ar.')) {
      final token = source.split(RegExp(r'\s+')).firstWhere(
            (part) => part.startsWith('ar.'),
            orElse: () => source,
          );
      return token;
    }
    return source;
  }

  String _sourceDisplayLabel(String sourceId) {
    return switch (sourceId) {
      'ar.waseet' => 'التفسير الوسيط (مصر)',
      'ar.muyassar' => 'التفسير الميسر',
      'ar.jalalayn' => 'تفسير الجلالين',
      'ar.qurtubi' => 'تفسير القرطبي',
      'ar.miqbas' => 'تنوير المقباس',
      'ar.baghawi' => 'تفسير البغوي',
      _ => sourceId,
    };
  }
}
