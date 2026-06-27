/// Splits Uthmani ayah text into display words for manual error marking.
List<String> splitAyahWords(String text) => text
    .split(RegExp(r'\s+'))
    .map((w) => w.trim())
    .where((w) => w.isNotEmpty)
    .toList();

int accuracyFromWordMarks({
  required int totalWords,
  required int wrongCount,
}) {
  if (totalWords == 0) return 0;
  final correct = totalWords - wrongCount;
  return ((correct / totalWords) * 100).round();
}
