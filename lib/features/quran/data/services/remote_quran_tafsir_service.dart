import 'package:dio/dio.dart';
import 'package:werdi/features/quran/data/services/offline_quran_tafsir_service.dart';
import 'package:werdi/features/quran/domain/constants/tafsir_sources.dart';
import 'package:werdi/features/quran/domain/models/tafsir_item.dart';
import 'package:werdi/features/quran/domain/services/quran_tafsir_service.dart';

/// Real tafsir provider backed by https://api.alquran.cloud.
///
/// Fetches ayah-by-ayah to avoid downloading entire long surahs.
class RemoteQuranTafsirService implements QuranTafsirService {
  RemoteQuranTafsirService({QuranTafsirService? fallback})
      : _fallback = fallback ?? const OfflineQuranTafsirService(),
        _dio = Dio(
          BaseOptions(
            baseUrl: 'https://api.alquran.cloud/v1',
            connectTimeout: const Duration(seconds: 15),
            receiveTimeout: const Duration(seconds: 15),
          ),
        );

  final QuranTafsirService _fallback;
  final Dio _dio;

  static const _maxAyahsPerRequest = 30;

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
          .where((id) => TafsirSources.labels.containsKey(id))
          .toSet()
          .toList();

      if (sources.isEmpty) {
        return _fallback.getAvailableSources();
      }

      sources.sort((a, b) {
        final ia = TafsirSources.preferredOrder.indexOf(a);
        final ib = TafsirSources.preferredOrder.indexOf(b);
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
    if (_isOfflineSource(source)) {
      return _fallback.getTafsir(
        surahNumber: surahNumber,
        ayahStart: ayahStart,
        ayahEnd: ayahEnd,
        source: source,
      );
    }

    final sourceId = _normalizeSourceIdentifier(source);
    if (!sourceId.startsWith('ar.')) {
      return _fallback.getTafsir(
        surahNumber: surahNumber,
        ayahStart: ayahStart,
        ayahEnd: ayahEnd,
        source: source,
      );
    }

    final safeEnd = ayahEnd > ayahStart + _maxAyahsPerRequest - 1
        ? ayahStart + _maxAyahsPerRequest - 1
        : ayahEnd;

    try {
      final buffer = StringBuffer();
      final ayahNumbers =
          List<int>.generate(safeEnd - ayahStart + 1, (i) => ayahStart + i);

      final results = await Future.wait(
        ayahNumbers.map((ayah) => _fetchAyahTafsir(surahNumber, ayah, sourceId)),
      );

      var wroteAny = false;
      for (var i = 0; i < ayahNumbers.length; i++) {
        final text = results[i];
        if (text == null || text.trim().isEmpty) continue;
        final ayah = ayahNumbers[i];
        buffer.writeln('($ayah) $text');
        if (ayah < safeEnd) buffer.writeln();
        wroteAny = true;
      }

      final tafsirText = buffer.toString().trim();
      if (!wroteAny || tafsirText.isEmpty) {
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
        ayahEnd: safeEnd,
        source: TafsirSources.labelFor(sourceId),
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

  Future<String?> _fetchAyahTafsir(
    int surahNumber,
    int ayahNumber,
    String sourceId,
  ) async {
    try {
      final response = await _dio.get<Map<String, dynamic>>(
        '/ayah/$surahNumber:$ayahNumber/$sourceId',
      );
      final data = response.data?['data'];
      if (data is! Map) return null;
      final text = data['text'];
      return text is String ? text.trim() : null;
    } catch (_) {
      return null;
    }
  }

  bool _isOfflineSource(String raw) {
    final source = raw.trim();
    return source == TafsirSources.offlineSourceId ||
        source.contains('احتياطي');
  }

  String _normalizeSourceIdentifier(String raw) {
    final source = raw.trim();
    if (source == TafsirSources.offlineSourceId) {
      return TafsirSources.offlineSourceId;
    }
    for (final known in TafsirSources.preferredOrder) {
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
}
