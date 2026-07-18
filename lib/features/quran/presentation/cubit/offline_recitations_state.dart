import 'package:equatable/equatable.dart';
import 'package:werdi/features/quran/data/services/recitation_download_service.dart';
import 'package:werdi/features/quran/domain/models/quran_audio_reciter.dart';

enum SurahDownloadStatus { unknown, notDownloaded, downloaded }

class OfflineRecitationsState extends Equatable {
  const OfflineRecitationsState({
    this.reciters = const [],
    this.selectedReciter,
    this.selectedSurahNumber = 1,
    this.downloadStatus = SurahDownloadStatus.unknown,
    this.isDownloading = false,
    this.progress,
    this.errorMessage,
  });

  final List<QuranAudioReciter> reciters;
  final QuranAudioReciter? selectedReciter;
  final int selectedSurahNumber;
  final SurahDownloadStatus downloadStatus;
  final bool isDownloading;
  final RecitationDownloadProgress? progress;
  final String? errorMessage;

  OfflineRecitationsState copyWith({
    List<QuranAudioReciter>? reciters,
    QuranAudioReciter? selectedReciter,
    int? selectedSurahNumber,
    SurahDownloadStatus? downloadStatus,
    bool? isDownloading,
    RecitationDownloadProgress? progress,
    String? errorMessage,
    bool clearError = false,
    bool clearProgress = false,
  }) {
    return OfflineRecitationsState(
      reciters: reciters ?? this.reciters,
      selectedReciter: selectedReciter ?? this.selectedReciter,
      selectedSurahNumber: selectedSurahNumber ?? this.selectedSurahNumber,
      downloadStatus: downloadStatus ?? this.downloadStatus,
      isDownloading: isDownloading ?? this.isDownloading,
      progress: clearProgress ? null : progress ?? this.progress,
      errorMessage: clearError ? null : errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [
        reciters,
        selectedReciter,
        selectedSurahNumber,
        downloadStatus,
        isDownloading,
        progress,
        errorMessage,
      ];
}
