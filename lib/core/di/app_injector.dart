import 'package:werdi/core/constants/app_constants.dart';
import 'package:werdi/core/database/app_database.dart';
import 'package:werdi/core/network/laravel_api_client.dart';
import 'package:werdi/core/security/auth_token_store.dart';
import 'package:werdi/core/services/app_preferences.dart';
import 'package:werdi/core/services/drift_app_preferences.dart';
import 'package:werdi/core/services/local_notification_reminder_service.dart';
import 'package:werdi/core/services/offline_sync_service.dart';
import 'package:werdi/core/services/reminder_service.dart';
import 'package:werdi/features/achievements/data/repositories/laravel_achievements_repository.dart';
import 'package:werdi/features/auth/data/repositories/laravel_auth_repository.dart';
import 'package:werdi/features/auth/domain/repositories/auth_repository.dart';
import 'package:werdi/features/memorization/data/repositories/quran_memorization_repository.dart';
import 'package:werdi/features/memorization/domain/repositories/memorization_repository.dart';
import 'package:werdi/features/quran/data/repositories/laravel_bookmark_repository.dart';
import 'package:werdi/features/quran/data/repositories/quran_repository_impl.dart';
import 'package:werdi/features/quran/data/repositories/quran_tafsir_repository_impl.dart';
import 'package:werdi/features/quran/data/services/mp3quran_reciters_api.dart';
import 'package:werdi/features/quran/data/services/quran_content_seed_service.dart';
import 'package:werdi/features/quran/data/services/local_quran_cache_service.dart';
import 'package:werdi/features/quran/data/services/offline_quran_tafsir_service.dart';
import 'package:werdi/features/quran/data/services/remote_quran_tafsir_service.dart';
import 'package:werdi/features/quran/data/services/quran_service.dart';
import 'package:werdi/features/quran/data/services/trusted_quran_remote_service.dart';
import 'package:werdi/features/quran/domain/repositories/quran_repository.dart';
import 'package:werdi/features/quran/domain/repositories/quran_tafsir_repository.dart';
import 'package:werdi/features/review/data/repositories/review_repository_impl.dart';
import 'package:werdi/features/review/data/repositories/drift_review_repository.dart';
import 'package:werdi/features/review/domain/repositories/review_repository.dart';
import 'package:werdi/features/tasmee3/data/repositories/tasmee3_repository_impl.dart';
import 'package:werdi/features/tasmee3/domain/repositories/tasmee3_repository.dart';
import 'package:werdi/shared/data/repositories/just_audio_repository.dart';
import 'package:werdi/shared/data/repositories/laravel_user_progress_repository.dart';
import 'package:werdi/shared/repositories/audio_repository.dart';
import 'package:werdi/shared/repositories/user_progress_repository.dart';

final class AppInjector {
  const AppInjector._();

  // ── Network ───────────────────────────────────────────────────────────────
  static final LaravelApiClient _laravelApiClient = LaravelApiClient();
  static final AuthTokenStore _authTokenStore = AuthTokenStore();
  static final AppDatabase appDatabase = AppDatabase();
  static final OfflineSyncService offlineSyncService = OfflineSyncService(
    client: _laravelApiClient,
    preferences: appPreferences,
    database: appDatabase,
  );

  // ── Auth ──────────────────────────────────────────────────────────────────
  static final AuthRepository _noopAuthRepository = _NoopAuthRepository();
  static final AuthRepository _laravelAuthRepository = LaravelAuthRepository(
    client: _laravelApiClient,
    tokenStore: _authTokenStore,
    preferences: appPreferences,
  );
  static AuthRepository get authGateway => AppConstants.useLaravelBackend
      ? _laravelAuthRepository
      : _noopAuthRepository;

  // ── User Progress ─────────────────────────────────────────────────────────
  static final UserProgressRepository _noopProgressRepository =
      _NoopUserProgressRepository();
  static final UserProgressRepository _laravelProgressRepository =
      LaravelUserProgressRepository(
        client: _laravelApiClient,
        preferences: appPreferences,
        syncService: offlineSyncService,
        database: appDatabase,
      );
  static UserProgressRepository get userProgressGateway =>
      AppConstants.useLaravelBackend
          ? _laravelProgressRepository
          : _noopProgressRepository;

  // ── Quran ─────────────────────────────────────────────────────────────────
  static final LocalQuranCacheService localQuranCacheService =
      LocalQuranCacheService(database: appDatabase);
  static final TrustedQuranRemoteService trustedQuranRemoteService =
      TrustedQuranRemoteService();
  static final QuranRepository quranRepository = QuranRepositoryImpl(
    service: const QuranPackageService(),
    localCache: localQuranCacheService,
    remoteService: trustedQuranRemoteService,
    database: appDatabase,
  );
  static final QuranTafsirRepository quranTafsirRepository =
      QuranTafsirRepositoryImpl(
        service: RemoteQuranTafsirService(
          fallback: const OfflineQuranTafsirService(),
        ),
      );
  static final LaravelBookmarkRepository bookmarkRepository =
      LaravelBookmarkRepository(
        client: _laravelApiClient,
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

  // ── Memorization ──────────────────────────────────────────────────────────
  static final MemorizationRepository memorizationRepository =
      QuranMemorizationRepository(quranRepository: quranRepository);
  static MemorizationRepository get memorizationGateway =>
      memorizationRepository;

  // ── Review ────────────────────────────────────────────────────────────────
  static final LocalReviewRepository localReviewRepository =
      LocalReviewRepository();
  static final DriftReviewRepository driftReviewRepository =
      DriftReviewRepository(database: appDatabase);
  static ReviewRepository get reviewGateway => driftReviewRepository;

  // ── Tasmee3 ───────────────────────────────────────────────────────────────
  static final Tasmee3Repository _tasmee3Repository =
      LocalTasmee3Repository();
  static Tasmee3Repository get tasmee3Gateway => _tasmee3Repository;

  // ── Audio ─────────────────────────────────────────────────────────────────
  static final AudioRepository audioRepository = JustAudioRepository();

  // ── Achievements ──────────────────────────────────────────────────────────
  static final LaravelAchievementsRepository achievementsRepository =
      LaravelAchievementsRepository(
        client: _laravelApiClient,
        preferences: appPreferences,
      );

  // ── Services ──────────────────────────────────────────────────────────────
  static final ReminderService reminderService =
      LocalNotificationReminderService.instance;
  static final AppPreferences appPreferences = DriftAppPreferences(
    database: appDatabase,
    fallback: const SharedPrefsService(),
  );

  // ── Session restore ───────────────────────────────────────────────────────
  static Future<void> restoreAuthSession() async {
    if (!AppConstants.useLaravelBackend) return;
    final savedToken = await _authTokenStore.readToken();
    _laravelApiClient.setToken(savedToken);
  }
}

// ── Noop implementations ──────────────────────────────────────────────────────

class _NoopAuthRepository implements AuthRepository {
  @override
  Future<AuthUser> continueAsGuest() async =>
      const AuthUser(id: 'guest', name: 'زائر', email: '', isGuest: true);

  @override
  Future<AuthUser> registerWithEmail({
    required String name,
    required String email,
    required String password,
  }) async =>
      AuthUser(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        name: name,
        email: email,
        isGuest: false,
      );

  @override
  Future<void> sendPasswordReset({required String email}) async {}

  @override
  Future<AuthUser> signInWithEmail({
    required String email,
    required String password,
  }) async =>
      AuthUser(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        name: 'مستخدم',
        email: email,
        isGuest: false,
      );

  @override
  Future<AuthUser> getMe() async =>
      const AuthUser(id: 'guest', name: '', email: '', isGuest: true);

  @override
  Future<void> signOut() async {}
}

class _NoopUserProgressRepository implements UserProgressRepository {
  @override
  Future<UserProgressSnapshot> getProgress({required String userId}) async =>
      const UserProgressSnapshot(
        memorizedAyahCount: 0,
        reviewedItemsCount: 0,
        streakDays: 0,
      );

  @override
  Future<void> saveMemorizationProgress({
    required String userId,
    required int surahNumber,
    required int ayahNumber,
    required double progress,
  }) async {}

  @override
  Future<void> saveReviewProgress({
    required String userId,
    required String reviewId,
    required bool reviewed,
    required bool difficult,
  }) async {}
}
