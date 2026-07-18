/// Metadata shown on the lock-screen player for ayah recitation.
class AyahPlaybackMetadata {
  const AyahPlaybackMetadata({
    required this.surahNumber,
    required this.surahNameArabic,
    required this.ayahNumber,
    required this.reciterName,
  });

  final int surahNumber;
  final String surahNameArabic;
  final int ayahNumber;
  final String reciterName;

  String get notificationTitle => '$surahNameArabic — آية $ayahNumber';
}

/// Registers skip callbacks and metadata for [QuranAudioHandler].
final class QuranAudioSession {
  const QuranAudioSession._();

  static AyahPlaybackMetadata? _metadata;
  static void Function()? _onSkipNext;
  static void Function()? _onSkipPrevious;

  static AyahPlaybackMetadata? get metadata => _metadata;

  static bool get canSkipNext => _onSkipNext != null;

  static bool get canSkipPrevious => _onSkipPrevious != null;

  static void prepare({
    required AyahPlaybackMetadata metadata,
    void Function()? onSkipNext,
    void Function()? onSkipPrevious,
  }) {
    _metadata = metadata;
    _onSkipNext = onSkipNext;
    _onSkipPrevious = onSkipPrevious;
  }

  static void clear() {
    _metadata = null;
    _onSkipNext = null;
    _onSkipPrevious = null;
  }

  static void invokeSkipNext() => _onSkipNext?.call();

  static void invokeSkipPrevious() => _onSkipPrevious?.call();
}
