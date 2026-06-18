import 'package:equatable/equatable.dart';
import 'package:werdi/features/memorization/domain/models/memorization_ayah.dart';
import 'package:werdi/features/quran/domain/models/surah_item.dart';

enum MemorizationPhase { loading, setup, session }

class MemorizationState extends Equatable {
  const MemorizationState({
    this.phase = MemorizationPhase.loading,
    this.availableSurahs = const [],
    this.selectedSurahNumber = 1,
    this.selectedSurahName = '',
    this.selectedVerseCount = 7,
    this.ayahStart = 1,
    this.ayahEnd = 7,
    this.currentIndex = 0,
    this.isPlaying = false,
    this.repeatCount = 1,
    this.playbackSpeed = 1.0,
    this.ayahs = const [],
    this.memorizedAyahNumbers = const {},
    this.difficultAyahNumbers = const {},
    this.showAyahText = true,
  });

  final MemorizationPhase phase;
  final List<SurahItem> availableSurahs;
  final int selectedSurahNumber;
  final String selectedSurahName;
  final int selectedVerseCount;
  final int ayahStart;
  final int ayahEnd;
  final int currentIndex;
  final bool isPlaying;
  final int repeatCount;
  final double playbackSpeed;
  final List<MemorizationAyah> ayahs;
  final Set<int> memorizedAyahNumbers;
  final Set<int> difficultAyahNumbers;
  final bool showAyahText;

  MemorizationAyah? get currentAyah =>
      ayahs.isNotEmpty ? ayahs[currentIndex] : null;

  bool get isFirstAyah => currentIndex == 0;
  bool get isLastAyah => ayahs.isEmpty || currentIndex == ayahs.length - 1;

  MemorizationState copyWith({
    MemorizationPhase? phase,
    List<SurahItem>? availableSurahs,
    int? selectedSurahNumber,
    String? selectedSurahName,
    int? selectedVerseCount,
    int? ayahStart,
    int? ayahEnd,
    int? currentIndex,
    bool? isPlaying,
    int? repeatCount,
    double? playbackSpeed,
    List<MemorizationAyah>? ayahs,
    Set<int>? memorizedAyahNumbers,
    Set<int>? difficultAyahNumbers,
    bool? showAyahText,
  }) {
    return MemorizationState(
      phase: phase ?? this.phase,
      availableSurahs: availableSurahs ?? this.availableSurahs,
      selectedSurahNumber: selectedSurahNumber ?? this.selectedSurahNumber,
      selectedSurahName: selectedSurahName ?? this.selectedSurahName,
      selectedVerseCount: selectedVerseCount ?? this.selectedVerseCount,
      ayahStart: ayahStart ?? this.ayahStart,
      ayahEnd: ayahEnd ?? this.ayahEnd,
      currentIndex: currentIndex ?? this.currentIndex,
      isPlaying: isPlaying ?? this.isPlaying,
      repeatCount: repeatCount ?? this.repeatCount,
      playbackSpeed: playbackSpeed ?? this.playbackSpeed,
      ayahs: ayahs ?? this.ayahs,
      memorizedAyahNumbers: memorizedAyahNumbers ?? this.memorizedAyahNumbers,
      difficultAyahNumbers: difficultAyahNumbers ?? this.difficultAyahNumbers,
      showAyahText: showAyahText ?? this.showAyahText,
    );
  }

  @override
  List<Object> get props => [
    phase,
    availableSurahs,
    selectedSurahNumber,
    selectedSurahName,
    selectedVerseCount,
    ayahStart,
    ayahEnd,
    currentIndex,
    isPlaying,
    repeatCount,
    playbackSpeed,
    ayahs,
    memorizedAyahNumbers,
    difficultAyahNumbers,
    showAyahText,
  ];
}
