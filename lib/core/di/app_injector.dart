import 'package:werdi/core/audio/audio_service_controller.dart';
import 'package:werdi/core/audio/ayah_playlist_player.dart';
import 'package:werdi/core/constants/app_constants.dart';
import 'package:werdi/core/database/app_database.dart';
import 'package:werdi/core/services/app_preferences.dart';
import 'package:werdi/core/services/drift_app_preferences.dart';
import 'package:werdi/core/services/local_notification_reminder_service.dart';
import 'package:werdi/core/services/offline_sync_service.dart';
import 'package:werdi/core/services/remote_data_pull_service.dart';
import 'package:werdi/core/services/reminder_service.dart';
import 'package:werdi/features/achievements/data/repositories/supabase_achievements_repository.dart';
import 'package:werdi/features/achievements/domain/repositories/achievements_repository.dart';
import 'package:werdi/features/goals/data/repositories/user_goals_repository.dart';
import 'package:werdi/features/home/domain/services/home_dashboard_service.dart';
import 'package:werdi/features/memorization/data/repositories/quran_memorization_repository.dart';
import 'package:werdi/features/memorization/domain/repositories/memorization_repository.dart';
import 'package:werdi/features/memorization/domain/services/memorization_analytics_service.dart';
import 'package:werdi/features/quran/data/repositories/quran_repository_impl.dart';
import 'package:werdi/features/quran/data/repositories/quran_tafsir_repository_impl.dart';
import 'package:werdi/features/quran/data/repositories/supabase_bookmark_repository.dart';
import 'package:werdi/features/quran/data/services/mp3quran_reciters_api.dart';
import 'package:werdi/features/quran/data/services/cached_quran_tafsir_service.dart';
import 'package:werdi/features/quran/data/services/quran_content_seed_service.dart';
import 'package:werdi/features/quran/data/services/local_quran_cache_service.dart';
import 'package:werdi/features/quran/data/services/offline_quran_tafsir_service.dart';
import 'package:werdi/features/quran/data/services/remote_quran_tafsir_service.dart';
import 'package:werdi/features/quran/data/services/recitation_download_service.dart';
import 'package:werdi/features/quran/data/services/recitation_offline_storage.dart';
import 'package:werdi/features/quran/data/services/quran_service.dart';
import 'package:werdi/features/quran/data/services/trusted_quran_remote_service.dart';
import 'package:werdi/features/quran/domain/repositories/bookmark_repository.dart';
import 'package:werdi/features/quran/domain/repositories/quran_repository.dart';
import 'package:werdi/features/quran/domain/repositories/quran_tafsir_repository.dart';
import 'package:werdi/features/review/data/repositories/drift_review_repository.dart';
import 'package:werdi/features/review/data/repositories/supabase_review_repository.dart';
import 'package:werdi/features/review/domain/repositories/review_repository.dart';
import 'package:werdi/features/tasmee3/data/repositories/tasmee3_repository_impl.dart';
import 'package:werdi/features/tasmee3/domain/repositories/tasmee3_repository.dart';
import 'package:werdi/shared/data/repositories/just_audio_repository.dart';
import 'package:werdi/shared/repositories/audio_repository.dart';
import 'package:werdi/shared/repositories/user_progress_repository.dart';
import 'package:werdi/shared/data/repositories/local_user_progress_repository.dart';
import 'package:werdi/shared/data/repositories/supabase_user_progress_repository.dart';

final class AppInjector {
  const AppInjector._();

  static final AppDatabase appDatabase = AppDatabase();

  static final OfflineSyncService offlineSyncService = OfflineSyncService(
    preferences: appPreferences,
    database: appDatabase,
  );

  static final DriftReviewRepository _driftReviewRepository =
      DriftReviewRepository(database: appDatabase);

  static final SupabaseReviewRepository? _supabaseReviewRepository =
      AppConstants.useSupabaseBackend
          ? SupabaseReviewRepository(
              local: _driftReviewRepository,
              syncService: offlineSyncService,
            )
          : null;

  static final UserProgressRepository userProgressGateway =
      AppConstants.useSupabaseBackend
          ? SupabaseUserProgressRepository(
              preferences: appPreferences,
              syncService: offlineSyncService,
              database: appDatabase,
            )
          : LocalUserProgressRepository(
              database: appDatabase,
              preferences: appPreferences,
            );

  static final LocalQuranCacheService localQuranCacheService =
      LocalQuranCacheService(database: appDatabase);
  static final TrustedQuranRemoteService trustedQuranRemoteService =
      TrustedQuranRemoteService();
  static final RecitationOfflineStorage recitationOfflineStorage =
      RecitationOfflineStorage();
  static final RecitationDownloadService recitationDownloadService =
      RecitationDownloadService(
        quranService: const QuranPackageService(),
        storage: recitationOfflineStorage,
      );
  static final QuranRepository quranRepository = QuranRepositoryImpl(
    service: const QuranPackageService(),
    localCache: localQuranCacheService,
    remoteService: trustedQuranRemoteService,
    database: appDatabase,
    offlineStorage: recitationOfflineStorage,
  );
  static final QuranTafsirRepository quranTafsirRepository =
      QuranTafsirRepositoryImpl(
        service: CachedQuranTafsirService(
          remote: RemoteQuranTafsirService(
            fallback: const OfflineQuranTafsirService(),
          ),
          fallback: const OfflineQuranTafsirService(),
          preferences: appPreferences,
        ),
      );
  static final BookmarkRepository bookmarkRepository = SupabaseBookmarkRepository(
    preferences: appPreferences,
    syncService: offlineSyncService,
    database: appDatabase,
  );
  static final Mp3QuranRecitersApi mp3QuranRecitersApi = Mp3QuranRecitersApi();
  static final QuranContentSeedService quranContentSeedService =
      QuranContentSeedService(
        database: appDatabase,
        repository: quranRepository,
      );

  static final MemorizationRepository memorizationRepository =
      QuranMemorizationRepository(quranRepository: quranRepository);
  static MemorizationRepository get memorizationGateway =>
      memorizationRepository;

  static final ReviewRepository reviewRepository =
      _supabaseReviewRepository ?? _driftReviewRepository;
  /// Alias kept for existing call sites.
  static ReviewRepository get reviewGateway => reviewRepository;

  static final RemoteDataPullService remoteDataPullService =
      RemoteDataPullService(
    bookmarkRepository: bookmarkRepository,
    progressRepository: AppConstants.useSupabaseBackend
        ? userProgressGateway as SupabaseUserProgressRepository
        : null,
    reviewRepository: _supabaseReviewRepository,
  );

  static final Tasmee3Repository _tasmee3Repository =
      LocalTasmee3Repository();
  static Tasmee3Repository get tasmee3Gateway => _tasmee3Repository;

  static late AudioRepository audioRepository;

  static AyahPlaylistPlayer? _ayahPlaylistPlayer;

  static AyahPlaylistPlayer get ayahPlaylistPlayer => _ayahPlaylistPlayer!;

  static void configureAudio() {
    final handler = AudioServiceController.handler;
    audioRepository = JustAudioRepository(
      player: handler?.player,
      handler: handler,
    );
    _ayahPlaylistPlayer = AyahPlaylistPlayer(audioRepository);
  }

  static final MemorizationAnalyticsService memorizationAnalyticsService =
      MemorizationAnalyticsService(database: appDatabase);

  static final AchievementsRepository achievementsRepository =
      SupabaseAchievementsRepository(preferences: appPreferences);

  static final HomeDashboardService homeDashboardService = HomeDashboardService(
    progressRepository: userProgressGateway,
    reviewRepository: reviewRepository,
    achievementsRepository: achievementsRepository,
    tasmee3Repository: tasmee3Gateway,
    database: appDatabase,
    preferences: appPreferences,
    goalsRepository: userGoalsRepository,
  );

  static final UserGoalsRepository userGoalsRepository = UserGoalsRepository(
    preferences: appPreferences,
  );

  static final ReminderService reminderService =
      LocalNotificationReminderService.instance;
  static final AppPreferences appPreferences = DriftAppPreferences(
    database: appDatabase,
    fallback: const SharedPrefsService(),
  );
}
