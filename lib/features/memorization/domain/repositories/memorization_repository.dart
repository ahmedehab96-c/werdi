import 'package:werdi/features/memorization/domain/models/memorization_ayah.dart';

abstract interface class MemorizationRepository {
  Future<List<MemorizationAyah>> getSessionAyahs({
    required int surahNumber,
    required int ayahStart,
    required int ayahEnd,
  });
}
