import 'package:equatable/equatable.dart';

class HomeState extends Equatable {
  const HomeState({
    this.isLoading = false,
    this.userName = '',
    this.motivationSubtitle = '',
    this.dailyTargetAyahs = 8,
    this.dailyCompletedAyahs = 0,
    this.totalMemorizationProgress = 0,
    this.currentSurahName = '',
    this.currentSurahProgress = 0,
    this.weeklyProgress = const [0, 0, 0, 0, 0, 0, 0],
    this.lastMemorizedContext = '—',
    this.lastReviewContext = '—',
    this.reviewDueCount = 0,
    this.overdueReviewCount = 0,
    this.dailyQuote = '—',
    this.streakDays = 0,
    this.nextMilestoneAyahs = 150,
    this.currentMilestoneAyahs = 0,
    this.badges = const [],
    this.weeklyReviewedAyahs = 0,
    this.weeklyMemorizedAyahs = 0,
    this.weeklySessions = 0,
    this.recommendedNextStep = '—',
  });

  final bool isLoading;
  final String userName;
  final String motivationSubtitle;
  final int dailyTargetAyahs;
  final int dailyCompletedAyahs;
  final double totalMemorizationProgress;
  final String currentSurahName;
  final double currentSurahProgress;
  final List<double> weeklyProgress;
  final String lastMemorizedContext;
  final String lastReviewContext;
  final int reviewDueCount;
  final int overdueReviewCount;
  final String dailyQuote;
  final int streakDays;
  final int nextMilestoneAyahs;
  final int currentMilestoneAyahs;
  final List<String> badges;
  final int weeklyReviewedAyahs;
  final int weeklyMemorizedAyahs;
  final int weeklySessions;
  final String recommendedNextStep;

  int get dailyRemainingAyahs =>
      (dailyTargetAyahs - dailyCompletedAyahs).clamp(0, 999);
  double get dailyProgress =>
      dailyTargetAyahs == 0 ? 0 : dailyCompletedAyahs / dailyTargetAyahs;
  double get milestoneProgress =>
      nextMilestoneAyahs == 0 ? 0 : currentMilestoneAyahs / nextMilestoneAyahs;
  bool get hasOverdueReviews => overdueReviewCount > 0;

  HomeState copyWith({
    bool? isLoading,
    String? userName,
    String? motivationSubtitle,
    int? dailyTargetAyahs,
    int? dailyCompletedAyahs,
    double? totalMemorizationProgress,
    String? currentSurahName,
    double? currentSurahProgress,
    List<double>? weeklyProgress,
    String? lastMemorizedContext,
    String? lastReviewContext,
    int? reviewDueCount,
    int? overdueReviewCount,
    String? dailyQuote,
    int? streakDays,
    int? nextMilestoneAyahs,
    int? currentMilestoneAyahs,
    List<String>? badges,
    int? weeklyReviewedAyahs,
    int? weeklyMemorizedAyahs,
    int? weeklySessions,
    String? recommendedNextStep,
  }) {
    return HomeState(
      isLoading: isLoading ?? this.isLoading,
      userName: userName ?? this.userName,
      motivationSubtitle: motivationSubtitle ?? this.motivationSubtitle,
      dailyTargetAyahs: dailyTargetAyahs ?? this.dailyTargetAyahs,
      dailyCompletedAyahs: dailyCompletedAyahs ?? this.dailyCompletedAyahs,
      totalMemorizationProgress: totalMemorizationProgress ?? this.totalMemorizationProgress,
      currentSurahName: currentSurahName ?? this.currentSurahName,
      currentSurahProgress: currentSurahProgress ?? this.currentSurahProgress,
      weeklyProgress: weeklyProgress ?? this.weeklyProgress,
      lastMemorizedContext: lastMemorizedContext ?? this.lastMemorizedContext,
      lastReviewContext: lastReviewContext ?? this.lastReviewContext,
      reviewDueCount: reviewDueCount ?? this.reviewDueCount,
      overdueReviewCount: overdueReviewCount ?? this.overdueReviewCount,
      dailyQuote: dailyQuote ?? this.dailyQuote,
      streakDays: streakDays ?? this.streakDays,
      nextMilestoneAyahs: nextMilestoneAyahs ?? this.nextMilestoneAyahs,
      currentMilestoneAyahs: currentMilestoneAyahs ?? this.currentMilestoneAyahs,
      badges: badges ?? this.badges,
      weeklyReviewedAyahs: weeklyReviewedAyahs ?? this.weeklyReviewedAyahs,
      weeklyMemorizedAyahs: weeklyMemorizedAyahs ?? this.weeklyMemorizedAyahs,
      weeklySessions: weeklySessions ?? this.weeklySessions,
      recommendedNextStep: recommendedNextStep ?? this.recommendedNextStep,
    );
  }

  @override
  List<Object> get props => [
    isLoading,
    userName,
    motivationSubtitle,
    dailyTargetAyahs,
    dailyCompletedAyahs,
    totalMemorizationProgress,
    currentSurahName,
    currentSurahProgress,
    weeklyProgress,
    lastMemorizedContext,
    lastReviewContext,
    reviewDueCount,
    overdueReviewCount,
    dailyQuote,
    streakDays,
    nextMilestoneAyahs,
    currentMilestoneAyahs,
    badges,
    weeklyReviewedAyahs,
    weeklyMemorizedAyahs,
    weeklySessions,
    recommendedNextStep,
  ];
}
