import 'package:werdi/core/constants/app_constants.dart';
import 'package:werdi/core/database/app_database.dart';
import 'package:werdi/core/services/app_preferences.dart';
import 'package:werdi/features/achievements/domain/repositories/achievements_repository.dart';
import 'package:werdi/features/home/presentation/cubit/home_state.dart';
import 'package:werdi/features/review/domain/models/review_item.dart';
import 'package:werdi/features/review/domain/repositories/review_repository.dart';
import 'package:werdi/features/tasmee3/domain/repositories/tasmee3_repository.dart';
import 'package:werdi/shared/repositories/user_progress_repository.dart';

/// Loads and composes all data shown on the home dashboard.
class HomeDashboardService {
  HomeDashboardService({
    required UserProgressRepository progressRepository,
    required ReviewRepository reviewRepository,
    required AchievementsRepository achievementsRepository,
    required Tasmee3Repository tasmee3Repository,
    required AppDatabase database,
    required AppPreferences preferences,
  })  : _progressRepository = progressRepository,
        _reviewRepository = reviewRepository,
        _achievementsRepository = achievementsRepository,
        _tasmee3Repository = tasmee3Repository,
        _database = database,
        _preferences = preferences;

  final UserProgressRepository _progressRepository;
  final ReviewRepository _reviewRepository;
  final AchievementsRepository _achievementsRepository;
  final Tasmee3Repository _tasmee3Repository;
  final AppDatabase _database;
  final AppPreferences _preferences;

  static const _lastReadKey = 'quran_last_read_surah';
  static const _userNameKey = 'profile_display_name';
  static const _milestones = [100, 300, 500, 1000, 2000];

  static const dailyQuotes = [
    'وَمَن يَتَّقِ اللَّهَ يَجْعَل لَّهُ مَخْرَجًا',
    'إِنَّ مَعَ الْعُسْرِ يُسْرًا',
    'وَاذْكُرُوا اللَّهَ كَثِيرًا لَّعَلَّكُمْ تُفْلِحُونَ',
    'وَقُل رَّبِّ زِدْنِي عِلْمًا',
    'فَإِنَّ مَعَ الْعُسْرِ يُسْرًا',
    'وَاصْبِرْ وَمَا صَبْرُكَ إِلَّا بِاللَّهِ',
    'رَبَّنَا آتِنَا فِي الدُّنْيَا حَسَنَةً وَفِي الْآخِرَةِ حَسَنَةً',
  ];

  Future<HomeDashboardSnapshot> load({required int dailyTargetAyahs}) async {
    final reviewItemsFuture = _reviewRepository.getReviewItems();
    final lastReadFuture = _preferences.getString(_lastReadKey);
    final userNameFuture = _preferences.getString(_userNameKey);
    final tasmee3Future = _tasmee3Repository.getHistory();
    final progressFuture = _progressRepository.getProgress(
      userId: AppConstants.localUserId,
    );
    final dailyCountsFuture = _database.memorizationCountsByDay(
      userId: AppConstants.localUserId,
    );
    final weeklySessionsFuture = _database.countActiveDaysThisWeek(
      userId: AppConstants.localUserId,
    );
    final todayAyahsFuture = _database.countMemorizationToday(
      userId: AppConstants.localUserId,
    );
    final weeklyMemorizedFuture = _database.countMemorizationThisWeek(
      userId: AppConstants.localUserId,
    );
    final weeklyReviewedFuture = _database.countReviewsThisWeek();

    final reviewItems = await reviewItemsFuture;
    final lastReadSurah = await lastReadFuture;
    final userName = await userNameFuture;
    final tasmee3History = await tasmee3Future;
    final snapshot = await progressFuture;
    final dailyCounts = await dailyCountsFuture;
    final weeklySessions = await weeklySessionsFuture;
    final todayAyahs = await todayAyahsFuture;
    final weeklyMemorized = await weeklyMemorizedFuture;
    final weeklyReviewed = await weeklyReviewedFuture;

    final pendingCount = reviewItems.where((i) => !i.reviewed).length;
    final overdueCount = reviewItems.where((i) => i.difficult).length;
    final lastReviewed = _lastReviewedTitle(reviewItems);

    final currentSurah =
        lastReadSurah?.replaceFirst('سورة ', '') ?? 'الملك';
    final lastContext = lastReadSurah ?? '—';

    final achievements = await _achievementsRepository.evaluateFromMetrics(
      memorizedAyahCount: snapshot.memorizedAyahCount,
      reviewedItemsCount: snapshot.reviewedItemsCount,
      streakDays: snapshot.streakDays,
      tasmee3Sessions: tasmee3History.length,
    );

    final maxDaily = dailyCounts.isEmpty
        ? 1
        : dailyCounts.reduce((a, b) => a > b ? a : b).clamp(1, 999);
    final weeklyProgress =
        dailyCounts.map((c) => (c / maxDaily).clamp(0.0, 1.0)).toList();

    final plan = _recommendedPlan(
      pendingReviews: pendingCount,
      overdueReviews: overdueCount,
      dailyRemaining: (dailyTargetAyahs - todayAyahs).clamp(0, dailyTargetAyahs),
      surahName: currentSurah,
      streakDays: snapshot.streakDays,
    );

    return HomeDashboardSnapshot(
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
      totalMemorizationProgress:
          (snapshot.memorizedAyahCount / 6236).clamp(0.0, 1.0),
      currentSurahProgress: todayAyahs == 0
          ? 0.0
          : (todayAyahs / dailyTargetAyahs).clamp(0.0, 1.0),
      currentMilestoneAyahs: snapshot.memorizedAyahCount,
      nextMilestoneAyahs: _nextMilestone(snapshot.memorizedAyahCount),
      streakDays: snapshot.streakDays,
      weeklyMemorizedAyahs: weeklyMemorized,
      weeklyReviewedAyahs: weeklyReviewed,
      weeklySessions: weeklySessions,
      weeklyProgress: weeklyProgress,
      badges: achievements.earned.map((e) => e.title).toList(),
      nextBadgeTitle:
          achievements.upcoming.isNotEmpty ? achievements.upcoming.first.title : '',
      dailyQuote: dailyQuotes[DateTime.now().day % dailyQuotes.length],
      recommendedNextStep: plan.text,
      recommendedPlanAction: plan.action,
    );
  }

  String? _lastReviewedTitle(List<ReviewItem> items) {
    for (final item in items) {
      if (item.reviewed) return item.title;
    }
    return null;
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

class HomeDashboardSnapshot {
  const HomeDashboardSnapshot({
    required this.userName,
    required this.motivationSubtitle,
    required this.reviewDueCount,
    required this.overdueReviewCount,
    required this.currentSurahName,
    required this.lastMemorizedContext,
    required this.lastReviewContext,
    required this.dailyCompletedAyahs,
    required this.totalMemorizationProgress,
    required this.currentSurahProgress,
    required this.currentMilestoneAyahs,
    required this.nextMilestoneAyahs,
    required this.streakDays,
    required this.weeklyMemorizedAyahs,
    required this.weeklyReviewedAyahs,
    required this.weeklySessions,
    required this.weeklyProgress,
    required this.badges,
    required this.nextBadgeTitle,
    required this.dailyQuote,
    required this.recommendedNextStep,
    required this.recommendedPlanAction,
  });

  final String userName;
  final String motivationSubtitle;
  final int reviewDueCount;
  final int overdueReviewCount;
  final String currentSurahName;
  final String lastMemorizedContext;
  final String lastReviewContext;
  final int dailyCompletedAyahs;
  final double totalMemorizationProgress;
  final double currentSurahProgress;
  final int currentMilestoneAyahs;
  final int nextMilestoneAyahs;
  final int streakDays;
  final int weeklyMemorizedAyahs;
  final int weeklyReviewedAyahs;
  final int weeklySessions;
  final List<double> weeklyProgress;
  final List<String> badges;
  final String nextBadgeTitle;
  final String dailyQuote;
  final String recommendedNextStep;
  final HomePlanAction recommendedPlanAction;

  factory HomeDashboardSnapshot.fallback() {
    return const HomeDashboardSnapshot(
      userName: '',
      motivationSubtitle: 'ابدأ جلسة اليوم لبناء سلسلة إنجازك',
      reviewDueCount: 0,
      overdueReviewCount: 0,
      currentSurahName: 'الملك',
      lastMemorizedContext: '—',
      lastReviewContext: '—',
      dailyCompletedAyahs: 0,
      totalMemorizationProgress: 0,
      currentSurahProgress: 0,
      currentMilestoneAyahs: 0,
      nextMilestoneAyahs: 100,
      streakDays: 0,
      weeklyMemorizedAyahs: 0,
      weeklyReviewedAyahs: 0,
      weeklySessions: 0,
      weeklyProgress: [0, 0, 0, 0, 0, 0, 0],
      badges: [],
      nextBadgeTitle: '',
      dailyQuote: 'وَمَن يَتَّقِ اللَّهَ يَجْعَل لَّهُ مَخْرَجًا',
      recommendedNextStep: 'ابدأ جلسة حفظ أو مراجعة اليوم',
      recommendedPlanAction: HomePlanAction.memorize,
    );
  }
}
