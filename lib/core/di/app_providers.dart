import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:werdi/core/di/app_injector.dart';
import 'package:werdi/features/quran/domain/repositories/quran_repository.dart';
import 'package:werdi/features/quran/domain/repositories/quran_tafsir_repository.dart';
import 'package:werdi/shared/repositories/audio_repository.dart';

/// Phase-1 Riverpod bridge providers.
/// Keeps existing AppInjector wiring intact while enabling incremental migration.
final quranRepositoryProvider = Provider<QuranRepository>(
  (ref) => AppInjector.quranRepository,
);

final quranTafsirRepositoryProvider = Provider<QuranTafsirRepository>(
  (ref) => AppInjector.quranTafsirRepository,
);

final audioRepositoryProvider = Provider<AudioRepository>(
  (ref) => AppInjector.audioRepository,
);
