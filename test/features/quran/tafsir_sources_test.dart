import 'package:flutter_test/flutter_test.dart';
import 'package:werdi/features/quran/domain/constants/tafsir_sources.dart';

void main() {
  test('labels cover all preferred editions', () {
    for (final id in TafsirSources.preferredOrder) {
      expect(TafsirSources.labels.containsKey(id), isTrue);
      expect(TafsirSources.labelFor(id), isNotEmpty);
    }
  });

  test('labelFor falls back to source id for unknown keys', () {
    expect(TafsirSources.labelFor('ar.unknown'), 'ar.unknown');
  });
}
