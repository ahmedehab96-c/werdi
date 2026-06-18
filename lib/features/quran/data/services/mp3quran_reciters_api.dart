import 'package:dio/dio.dart';
import 'package:werdi/features/quran/domain/models/quran_audio_reciter.dart';

/// جلب قائمة القرّاء من واجهة MP3Quran الرسمية.
/// المصدر: [https://www.mp3quran.net/api/v3/reciters](https://www.mp3quran.net/api/v3/reciters)
class Mp3QuranRecitersApi {
  Mp3QuranRecitersApi({Dio? dio})
    : _dio =
          dio ??
          Dio(
            BaseOptions(
              connectTimeout: const Duration(seconds: 12),
              receiveTimeout: const Duration(seconds: 12),
              validateStatus: (s) => s != null && s < 500,
            ),
          );

  static const _endpoint = 'https://www.mp3quran.net/api/v3/reciters';

  final Dio _dio;

  Future<List<QuranAudioReciter>> fetchRecitersSorted() async {
    final response = await _dio.get<Map<String, dynamic>>(_endpoint);
    if (response.statusCode != 200) {
      throw DioException(
        requestOptions: response.requestOptions,
        response: response,
        type: DioExceptionType.badResponse,
      );
    }
    final data = response.data;
    if (data == null) {
      throw DioException(
        requestOptions: response.requestOptions,
        type: DioExceptionType.badResponse,
        error: 'empty mp3quran response',
      );
    }
    final rawList = data['reciters'];
    if (rawList is! List) {
      throw DioException(
        requestOptions: response.requestOptions,
        type: DioExceptionType.badResponse,
        error: 'unexpected mp3quran json',
      );
    }

    final list = <QuranAudioReciter>[];
    for (final item in rawList) {
      if (item is! Map) continue;
      final reciter = QuranAudioReciter.fromApiJson(
        Map<String, dynamic>.from(item),
      );
      if (reciter != null) list.add(reciter);
    }
    if (list.isEmpty) {
      throw DioException(
        requestOptions: response.requestOptions,
        type: DioExceptionType.badResponse,
        error: 'no reciters parsed',
      );
    }
    list.sort(compareArabicReciterNames);
    return list;
  }
}
