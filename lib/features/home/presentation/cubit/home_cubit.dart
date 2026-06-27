import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:werdi/core/constants/app_constants.dart';
import 'package:werdi/core/database/app_database.dart';
import 'package:werdi/core/services/app_preferences.dart';
import 'package:werdi/features/achievements/domain/repositories/achievements_repository.dart';
import 'package:werdi/features/home/presentation/cubit/home_state.dart';
import 'package:werdi/features/review/data/repositories/review_repository_impl.dart';
import 'package:werdi/features/tasmee3/domain/repositories/tasmee3_repository.dart';
import 'package:werdi/shared/repositories/user_progress_repository.dart';

class HomeCubit extends Cubit<HomeState> {
  HomeCubit({
    required UserProgressRepository progressRepository,
    required LocalReviewRepository reviewRepository,
    required AchievementsRepository achievementsRepository,
    required Tasmee3Repository tasmee3Repository,
    required AppDatabase database,
    required AppPreferences preferences,
  })  : _progressRepository = progressRepository,
        _reviewRepository = reviewRepository,
        _achievementsRepository = achievementsRepository,
        _tasmee3Repository = tasmee3Repository,
        _database = database,
        _preferences = preferences,
        super(const HomeState());

  final UserProgressRepository _progressRepository;
  final LocalReviewRepository _reviewRepository;
  final AchievementsRepository _achievementsRepository;
  final Tasmee3Repository _tasmee3Repository;
  final AppDatabase _database;
  final AppPreferences _preferences;

  static const _lastReadKey = 'quran_last_read_surah';
  static const _userNameKey = 'profile_display_name';
  static const _milestones = [100, 300, 500, 1000, 2000];

  static const _dailyQuotes = [
    'وَمَن يَتَّقِ اللَّهَ يَجْعَل لَّهُ مَخْرَجًا',
    'إِنَّ مَعَ الْعُسْرِ يُسْرًا',
    'وَاذْكُرُوا اللَّهَ كَثِيرًا لَّعَلَّكُمْ تُفْلِحُونَ',
    'وَقُل رَّبِّ زِدْنِي عِلْمًا',
    'فَإِنَّ مَعَ الْعُسْرِ يُسْرًا',
    'وَاصْبِرْ وَمَا صَبْرُكَ إِلَّا بِاللَّهِ',
    'رَبَّنَا آتِنَا فِي الدُّنْيَا حَسَنَةً وَفِي الْآخِرَةِ حَسَنَةً',
  ];

  Future<void> initialize() => _load(showFullLoader: true);

  Future<void> refresh() => _load(showFullLoader: false);

  Future<void> _load({required bool showFullLoader}) async {
    if (showFullLoader) {
      emit(state.copyWith(isLoading: true));
    } else {
      emit(state.copyWith(isRefreshing: true));
    }

    try {
      final localResults = await Future.wait([
        _reviewRepository.getReviewItems(),
        _preferences.getString(_lastReadKey),
        _preferences.getString(_userNameKey),
        _tasmee3Repository.getHistory(),
      ]);

      final reviewItems = localResults[0] as List<dynamic>;
      final lastReadSurah = localResults[1] as String?;
      final userName = localResults[2] as String?;
      final tasmee3History = localResults[3] as List<dynamic>;

      final pendingCount =
          reviewItems.where((i) => !(i.reviewed as bool)).length;
      final overdueCount =
          reviewItems.where((i) => i.difficult as bool).length;
      final lastReviewed = reviewItems
          .where((i) => i.reviewed as bool)
          .map((i) => i.title as String)
          .firstOrNull;

      final currentSurah =
          lastReadSurah?.replaceFirst('سورة ', '') ?? state.currentSurahName;
      final lastContext = lastReadSurah ?? state.lastMemorizedContext;

      final snapshot = await _progressRepository.getProgress(
        userId: AppConstants.localUserId,
      );

      final achievements = await _achievementsRepository.evaluateFromMetrics(
        memorizedAyahCount: snapshot.memorizedAyahCount,
        reviewedItemsCount: snapshot.reviewedItemsCount,
        streakDays: snapshot.streakDays,
        tasmee3Sessions: tasmee3History.length,
      );

      final dailyCounts = await _database.memorizationCountsByDay(
        userId: AppConstants.localUserId,
      );
      final maxDaily = dailyCounts.isEmpty
          ? 1
          : dailyCounts.reduce((a, b) => a > b ? a : b).clamp(1, 999);
      final weeklyProgress =
          dailyCounts.map((c) => (c / maxDaily).clamp(0.0, 1.0)).toList();

      final weeklySessions = await _database.countActiveDaysThisWeek(
        userId: AppConstants.localUserId,
      );
      final todayAyahs = await _database.countMemorizationToday(
        userId: AppConstants.localUserId,
      );
      final weeklyMemorized = await _database.countMemorizationThisWeek(
        userId: AppConstants.localUserId,
      );
      final weeklyReviewed = await _database.countReviewsThisWeek();

      final totalProgress =
          (snapshot.memorizedAyahCount / 6236).clamp(0.0, 1.0);
      final surahProgress = snapshot.memorizedAyahCount == 0
          ? 0.0
          : (todayAyahs / state.dailyTargetAyahs).clamp(0.0, 1.0);
      final nextMilestone = _nextMilestone(snapshot.memorizedAyahCount);
      final quote = _dailyQuotes[DateTime.now().day % _dailyQuotes.length];
      final badges = achievements.earned.map((e) => e.title).toList();
      final nextBadge = achievements.upcoming.isNotEmpty
          ? achievements.upcoming.first.title
          : '';
      final plan = _recommendedPlan(
        pendingReviews: pendingCount,
        overdueReviews: overdueCount,
        dailyRemaining:
            (state.dailyTargetAyahs - todayAyahs).clamp(0, state.dailyTargetAyahs),
        surahName: currentSurah,
        streakDays: snapshot.streakDays,
      );

      emit(state.copyWith(
        isLoading: false,
        isRefreshing: false,
        userName: userName ?? '',
        motivationSubtitle: snapshot.streakDays > 0
            ? '${snapshot.streakDays} يوم التزام — واصل اليوم!'
            : 'ابدأ جلسة اليوم لبناء سلسلة إنجازك',
        reviewDueCount: pendingCount,
        overdueReviewCount: overdueCount,
        currentSurahName: currentSurah,
        lastMemorizedContext: lastContext,
        lastReviewContext: lastReviewed ?? '—',
        dailyCompletedAyahs: todayAyahs,
        totalMemorizationProgress: totalProgress,
        currentSurahProgress: surahProgress,
        currentMilestoneAyahs: snapshot.memorizedAyahCount,
        nextMilestoneAyahs: nextMilestone,
        streakDays: snapshot.streakDays,
        weeklyMemorizedAyahs: weeklyMemorized,
        weeklyReviewedAyahs: weeklyReviewed,
        weeklySessions: weeklySessions,
        weeklyProgress: weeklyProgress,
        badges: badges,
        nextBadgeTitle: nextBadge,
        dailyQuote: quote,
        recommendedNextStep: plan.text,
        recommendedPlanAction: plan.action,
      ));
    } catch (_) {
      emit(state.copyWith(isLoading: false, isRefreshing: false));
    }
  }

  int _nextMilestone(int current) {
    for (final milestone in _milestones) {
      if (current < milestone) return milestone;
    }
    return ((current ~/ 500) + 1) * 500;
  }

  ({String text, HomePlanAction action}) _recommendedPlan({
    required int pendingReviews,
    required int overdueReviews,
    required int dailyRemaining,
    required String surahName,
    required int streakDays,
  }) {
    if (overdueReviews > 0) {
      return (
        text: 'ركّز على $overdueReviews آيات صعبة في المراجعة',
        action: HomePlanAction.review,
      );
    }
    if (pendingReviews > 0) {
      return (
        text: 'راجع $pendingReviews آيات اليوم قبل الحفظ الجديد',
        action: HomePlanAction.review,
      );
    }
    if (dailyRemaining > 0) {
      return (
        text: 'احفظ $dailyRemaining آيات من سورة $surahName',
        action: HomePlanAction.memorize,
      );
    }
    if (streakDays == 0) {
      return (
        text: 'ابدأ جلسة حفظ أو مراجعة لبدء سلسلة الإنجاز',
        action: HomePlanAction.memorize,
      );
    }
    return (
      text: 'جرّب جلسة تسميع على سورة $surahName',
      action: HomePlanAction.tasmee3,
    );
  }
}
