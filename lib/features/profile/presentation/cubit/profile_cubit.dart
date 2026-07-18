import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:werdi/core/constants/app_constants.dart';
import 'package:werdi/core/services/app_preferences.dart';
import 'package:werdi/features/achievements/domain/repositories/achievements_repository.dart';
import 'package:werdi/features/goals/data/repositories/user_goals_repository.dart';
import 'package:werdi/features/profile/presentation/cubit/profile_state.dart';
import 'package:werdi/features/tasmee3/domain/repositories/tasmee3_repository.dart';
import 'package:werdi/shared/repositories/user_progress_repository.dart';

class ProfileCubit extends Cubit<ProfileState> {
  ProfileCubit({
    required UserProgressRepository progressRepository,
    required AchievementsRepository achievementsRepository,
    required Tasmee3Repository tasmee3Repository,
    required UserGoalsRepository goalsRepository,
    required AppPreferences preferences,
  })  : _progressRepository = progressRepository,
        _achievementsRepository = achievementsRepository,
        _tasmee3Repository = tasmee3Repository,
        _goalsRepository = goalsRepository,
        _preferences = preferences,
        super(const ProfileState());

  final UserProgressRepository _progressRepository;
  final AchievementsRepository _achievementsRepository;
  final Tasmee3Repository _tasmee3Repository;
  final UserGoalsRepository _goalsRepository;
  final AppPreferences _preferences;

  static const _userNameKey = 'profile_display_name';

  Future<void> load() async {
    emit(state.copyWith(status: ProfileStatus.loading));
    try {
      final progress = await _progressRepository.getProgress(
        userId: AppConstants.localUserId,
      );
      if (isClosed) return;
      final goals = await _goalsRepository.load();
      if (isClosed) return;
      final displayName = await _preferences.getString(_userNameKey);
      if (isClosed) return;

      List<String> badges = const [];
      try {
        final sessions = await _tasmee3Repository.getHistory();
        if (isClosed) return;
        final result = await _achievementsRepository.evaluateFromMetrics(
          memorizedAyahCount: progress.memorizedAyahCount,
          reviewedItemsCount: progress.reviewedItemsCount,
          streakDays: progress.streakDays,
          tasmee3Sessions: sessions.length,
        );
        badges = result.earned.map((a) => a.title).toList();
      } catch (_) {}

      if (isClosed) return;
      emit(state.copyWith(
        status: ProfileStatus.loaded,
        progress: progress,
        earnedBadgeLabels: badges,
        goals: goals,
        displayName: displayName ?? '',
      ));
    } catch (_) {
      if (isClosed) return;
      emit(state.copyWith(
        status: ProfileStatus.error,
        errorMessage: 'تعذّر تحميل الملف الشخصي',
      ));
    }
  }

  Future<void> saveDisplayName(String name) async {
    final trimmed = name.trim();
    await _preferences.setString(_userNameKey, trimmed);
    emit(state.copyWith(displayName: trimmed));
  }
}
