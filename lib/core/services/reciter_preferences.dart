import 'package:werdi/core/services/app_preferences.dart';
import 'package:werdi/features/quran/domain/models/quran_audio_reciter.dart';

/// Resolves the saved reciter for ayah-by-ayah playback.
abstract final class ReciterPreferences {
  static const selectedReciterKey = 'quran_selected_reciter';
  static const defaultMp3QuranId = 123;

  static List<QuranAudioReciter> filterAyahCapable(
    Iterable<QuranAudioReciter> reciters,
  ) =>
      reciters.where((r) => r.supportsAyahPlayback).toList();

  static QuranAudioReciter resolve({
    required List<QuranAudioReciter> candidates,
    String? savedKey,
  }) {
    final list = filterAyahCapable(candidates);
    if (list.isEmpty) {
      return QuranAudioReciter.ayahCapableSorted().first;
    }
    if (savedKey == null || savedKey.isEmpty) {
      return _defaultReciter(list);
    }
    final mp3Id = QuranAudioReciter.tryParsePersistenceKey(savedKey);
    if (mp3Id != null) {
      for (final r in list) {
        if (r.mp3QuranId == mp3Id) return r;
      }
    }
    for (final r in list) {
      if (r.packageReciter?.name == savedKey) return r;
    }
    return _defaultReciter(list);
  }

  static QuranAudioReciter _defaultReciter(List<QuranAudioReciter> list) {
    for (final r in list) {
      if (r.mp3QuranId == defaultMp3QuranId) return r;
    }
    return list.first;
  }

  static Future<QuranAudioReciter> loadSelected(
    AppPreferences prefs, {
    List<QuranAudioReciter>? candidates,
  }) async {
    final saved = await prefs.getString(selectedReciterKey);
    final list = candidates ?? QuranAudioReciter.ayahCapableSorted();
    return resolve(candidates: list, savedKey: saved);
  }
}
