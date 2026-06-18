final class ArabicTextNormalizer {
  const ArabicTextNormalizer._();

  static String normalize(String text) {
    return text
        .replaceAll(RegExp(r'[\u0640]'), '')
        .replaceAll(RegExp(r'[\u064B-\u065F\u0670\u06D6-\u06ED]'), '')
        .replaceAll(RegExp(r'[\u06DD\u06DE\u06E9]'), '')
        .replaceAll(RegExp(r'[^\u0621-\u063A\u0641-\u064A0-9 ]'), '')
        .replaceAll('أ', 'ا')
        .replaceAll('إ', 'ا')
        .replaceAll('آ', 'ا')
        .replaceAll('ٱ', 'ا')
        .replaceAll('ى', 'ي')
        .replaceAll('ة', 'ه')
        .replaceAll('ؤ', 'و')
        .replaceAll('ئ', 'ي')
        .replaceAll(RegExp(r'\s+'), ' ')
        .trim();
  }
}
