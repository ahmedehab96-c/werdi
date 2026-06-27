import 'package:equatable/equatable.dart';
import 'package:werdi/features/tasmee3/domain/models/ayah_evaluation_snapshot.dart';
import 'package:werdi/features/tasmee3/domain/models/ayah_range.dart';
import 'package:werdi/features/tasmee3/domain/models/tasmee3_result.dart';
import 'package:werdi/features/tasmee3/domain/models/tasmee3_session.dart';

enum Tasmee3FlowStatus { setup, testing, summary, history }

class Tasmee3State extends Equatable {
  const Tasmee3State({
    this.status = Tasmee3FlowStatus.setup,
    this.selectedSurah = 'الملك',
    this.selectedSurahNumber = 67,
    this.selectedRange = const AyahRange(start: 1, end: 5),
    this.availableSurahs = const [],
    this.availableSurahNumbers = const [],
    this.availableSurahVerseCounts = const [],
    this.ayahTexts = const [],
    this.currentAyahIndex = 0,
    this.grades = const {},
    this.result,
    this.history = const [],
    this.historyFilter = 'الكل',
    this.isLoading = false,
    this.isListening = false,
    this.speechAvailable = true,
    this.speechError,
    this.spokenText = '',
    this.spokenAccuracy = 0,
    this.ayahWords = const [],
    this.expectedWordCorrect = const [],
    this.evaluationReady = false,
    this.ayahEvaluations = const {},
    this.isAudioTestPlaying = false,
    this.audioTestError,
    this.playingReciterAyahNumber,
    this.isReciterAyahPlaying = false,
  });

  final Tasmee3FlowStatus status;
  final String selectedSurah;
  final int selectedSurahNumber;
  final AyahRange selectedRange;
  final List<String> availableSurahs;
  final List<int> availableSurahNumbers;
  final List<int> availableSurahVerseCounts;
  final List<String> ayahTexts;
  final int currentAyahIndex;
  final Map<int, AyahGrade> grades;
  final Tasmee3Result? result;
  final List<Tasmee3Session> history;
  final String historyFilter;
  final bool isLoading;
  final bool isListening;
  final bool speechAvailable;
  final String? speechError;
  final String spokenText;
  final int spokenAccuracy;
  final List<String> ayahWords;
  final List<bool> expectedWordCorrect;
  final bool evaluationReady;
  final Map<int, AyahEvaluationSnapshot> ayahEvaluations;
  final bool isAudioTestPlaying;
  final String? audioTestError;
  final int? playingReciterAyahNumber;
  final bool isReciterAyahPlaying;

  int get selectedSurahVerseCount =>
      availableSurahVerseCounts.isNotEmpty &&
              availableSurahNumbers.contains(selectedSurahNumber)
          ? availableSurahVerseCounts[
              availableSurahNumbers.indexOf(selectedSurahNumber)]
          : selectedRange.end;

  int get currentAyahNumber => selectedRange.start + currentAyahIndex;
  bool get isLastAyah => currentAyahIndex >= ayahTexts.length - 1;
  int get totalAyahs => selectedRange.end - selectedRange.start + 1;
  String? get currentAyahText =>
      ayahTexts.isNotEmpty && currentAyahIndex < ayahTexts.length
          ? ayahTexts[currentAyahIndex]
          : null;

  List<Tasmee3Session> get filteredHistory {
    if (historyFilter == 'الكل') return history;
    return history
        .where((s) => s.result.status.text == historyFilter)
        .toList();
  }

  Tasmee3State copyWith({
    Tasmee3FlowStatus? status,
    String? selectedSurah,
    int? selectedSurahNumber,
    AyahRange? selectedRange,
    List<String>? availableSurahs,
    List<int>? availableSurahNumbers,
    List<int>? availableSurahVerseCounts,
    List<String>? ayahTexts,
    int? currentAyahIndex,
    Map<int, AyahGrade>? grades,
    Tasmee3Result? result,
    bool clearResult = false,
    List<Tasmee3Session>? history,
    String? historyFilter,
    bool? isLoading,
    bool? isListening,
    bool? speechAvailable,
    String? speechError,
    bool clearSpeechError = false,
    String? spokenText,
    int? spokenAccuracy,
    List<String>? ayahWords,
    List<bool>? expectedWordCorrect,
    bool? evaluationReady,
    Map<int, AyahEvaluationSnapshot>? ayahEvaluations,
    bool? isAudioTestPlaying,
    String? audioTestError,
    bool clearAudioTestError = false,
    int? playingReciterAyahNumber,
    bool clearPlayingReciterAyahNumber = false,
    bool? isReciterAyahPlaying,
  }) {
    return Tasmee3State(
      status: status ?? this.status,
      selectedSurah: selectedSurah ?? this.selectedSurah,
      selectedSurahNumber: selectedSurahNumber ?? this.selectedSurahNumber,
      selectedRange: selectedRange ?? this.selectedRange,
      availableSurahs: availableSurahs ?? this.availableSurahs,
      availableSurahNumbers:
          availableSurahNumbers ?? this.availableSurahNumbers,
      availableSurahVerseCounts:
          availableSurahVerseCounts ?? this.availableSurahVerseCounts,
      ayahTexts: ayahTexts ?? this.ayahTexts,
      currentAyahIndex: currentAyahIndex ?? this.currentAyahIndex,
      grades: grades ?? this.grades,
      result: clearResult ? null : (result ?? this.result),
      history: history ?? this.history,
      historyFilter: historyFilter ?? this.historyFilter,
      isLoading: isLoading ?? this.isLoading,
      isListening: isListening ?? this.isListening,
      speechAvailable: speechAvailable ?? this.speechAvailable,
      speechError: clearSpeechError ? null : (speechError ?? this.speechError),
      spokenText: spokenText ?? this.spokenText,
      spokenAccuracy: spokenAccuracy ?? this.spokenAccuracy,
      ayahWords: ayahWords ?? this.ayahWords,
      expectedWordCorrect: expectedWordCorrect ?? this.expectedWordCorrect,
      evaluationReady: evaluationReady ?? this.evaluationReady,
      ayahEvaluations: ayahEvaluations ?? this.ayahEvaluations,
      isAudioTestPlaying: isAudioTestPlaying ?? this.isAudioTestPlaying,
      audioTestError:
          clearAudioTestError ? null : (audioTestError ?? this.audioTestError),
      playingReciterAyahNumber: clearPlayingReciterAyahNumber
          ? null
          : (playingReciterAyahNumber ?? this.playingReciterAyahNumber),
      isReciterAyahPlaying: isReciterAyahPlaying ?? this.isReciterAyahPlaying,
    );
  }

  @override
  List<Object?> get props => [
        status,
        selectedSurah,
        selectedSurahNumber,
        selectedRange,
        availableSurahs,
        availableSurahNumbers,
        availableSurahVerseCounts,
        ayahTexts,
        currentAyahIndex,
        grades,
        result,
        history,
        historyFilter,
        isLoading,
        isListening,
        speechAvailable,
        speechError,
        spokenText,
        spokenAccuracy,
        ayahWords,
        expectedWordCorrect,
        evaluationReady,
        ayahEvaluations,
        isAudioTestPlaying,
        audioTestError,
        playingReciterAyahNumber,
        isReciterAyahPlaying,
      ];
}
