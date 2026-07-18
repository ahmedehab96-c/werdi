import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:quran/quran.dart' as quran_pkg;
import 'package:werdi/features/quran/data/services/recitation_download_service.dart';
import 'package:werdi/features/quran/data/services/recitation_offline_storage.dart';
import 'package:werdi/features/quran/domain/models/quran_audio_reciter.dart';
import 'package:werdi/features/quran/presentation/cubit/offline_recitations_state.dart';

class OfflineRecitationsCubit extends Cubit<OfflineRecitationsState> {
  OfflineRecitationsCubit({
    required RecitationDownloadService downloadService,
    required RecitationOfflineStorage storage,
  })  : _downloadService = downloadService,
        _storage = storage,
        super(const OfflineRecitationsState());

  final RecitationDownloadService _downloadService;
  final RecitationOfflineStorage _storage;

  Future<void> load() async {
    final reciters = QuranAudioReciter.ayahCapableSorted();
    final selected = reciters.isEmpty ? null : reciters.first;
    if (isClosed) return;
    emit(
      state.copyWith(
        reciters: reciters,
        selectedReciter: selected,
        clearError: true,
      ),
    );
    if (selected != null) {
      await refreshDownloadStatus();
    }
  }

  Future<void> selectReciter(QuranAudioReciter reciter) async {
    emit(
      state.copyWith(
        selectedReciter: reciter,
        downloadStatus: SurahDownloadStatus.unknown,
        clearError: true,
        clearProgress: true,
      ),
    );
    await refreshDownloadStatus();
  }

  Future<void> selectSurah(int surahNumber) async {
    emit(
      state.copyWith(
        selectedSurahNumber: surahNumber,
        downloadStatus: SurahDownloadStatus.unknown,
        clearError: true,
        clearProgress: true,
      ),
    );
    await refreshDownloadStatus();
  }

  Future<void> refreshDownloadStatus() async {
    final reciter = state.selectedReciter;
    if (reciter == null) return;

    final verseCount = quran_pkg.getVerseCount(state.selectedSurahNumber);
    final downloaded = await _storage.isSurahDownloaded(
      reciterKey: reciter.persistenceKey,
      surahNumber: state.selectedSurahNumber,
      verseCount: verseCount,
    );
    if (isClosed) return;
    emit(
      state.copyWith(
        downloadStatus: downloaded
            ? SurahDownloadStatus.downloaded
            : SurahDownloadStatus.notDownloaded,
      ),
    );
  }

  Future<void> downloadSelectedSurah() async {
    final reciter = state.selectedReciter;
    if (reciter == null || state.isDownloading) return;

    emit(
      state.copyWith(
        isDownloading: true,
        clearError: true,
        clearProgress: true,
      ),
    );

    try {
      final success = await _downloadService.downloadSurah(
        reciter: reciter,
        surahNumber: state.selectedSurahNumber,
        onProgress: (progress) {
          if (isClosed) return;
          emit(state.copyWith(progress: progress));
        },
      );
      if (isClosed) return;
      emit(
        state.copyWith(
          isDownloading: false,
          downloadStatus:
              success ? SurahDownloadStatus.downloaded : state.downloadStatus,
          errorMessage: success ? null : 'download_failed',
          clearProgress: true,
        ),
      );
    } catch (_) {
      if (isClosed) return;
      emit(
        state.copyWith(
          isDownloading: false,
          errorMessage: 'download_failed',
          clearProgress: true,
        ),
      );
    }
  }

  Future<void> deleteSelectedSurah() async {
    final reciter = state.selectedReciter;
    if (reciter == null || state.isDownloading) return;

    final verseCount = quran_pkg.getVerseCount(state.selectedSurahNumber);
    await _storage.deleteSurah(
      reciterKey: reciter.persistenceKey,
      surahNumber: state.selectedSurahNumber,
      verseCount: verseCount,
    );
    if (isClosed) return;
    emit(
      state.copyWith(
        downloadStatus: SurahDownloadStatus.notDownloaded,
        clearError: true,
        clearProgress: true,
      ),
    );
  }
}
