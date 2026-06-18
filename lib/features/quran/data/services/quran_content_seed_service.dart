import 'dart:async';

import 'package:werdi/core/database/app_database.dart';
import 'package:werdi/features/quran/domain/repositories/quran_repository.dart';

class QuranContentSeedService {
  QuranContentSeedService({
    required AppDatabase database,
    required QuranRepository repository,
  })  : _database = database,
        _repository = repository;

  final AppDatabase _database;
  final QuranRepository _repository;

  static const _seedDoneKey = 'quran_full_seed_v1';
  static const _seedInProgressKey = 'quran_full_seed_in_progress_v1';

  Future<void> warmUpInBackground() async {
    final done = await _database.getAppSetting(_seedDoneKey);
    if (done == '1') return;

    final inProgress = await _database.getAppSetting(_seedInProgressKey);
    if (inProgress == '1') return;

    await _database.setAppSetting(key: _seedInProgressKey, value: '1');
    try {
      for (var surah = 1; surah <= 114; surah++) {
        await _repository.getSurahVerses(surahNumber: surah);
        if (surah % 6 == 0) {
          await Future<void>.delayed(const Duration(milliseconds: 20));
        }
      }
      await _database.setAppSetting(key: _seedDoneKey, value: '1');
    } catch (_) {
      // Keep partial cache and retry on the next app start.
    } finally {
      await _database.setAppSetting(key: _seedInProgressKey, value: '0');
    }
  }
}
