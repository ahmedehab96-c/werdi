import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:werdi/core/constants/app_constants.dart';
import 'package:werdi/features/achievements/domain/repositories/achievements_repository.dart';
import 'package:werdi/features/profile/presentation/cubit/profile_state.dart';
import 'package:werdi/shared/repositories/user_progress_repository.dart';

class ProfileCubit extends Cubit<ProfileState> {
  ProfileCubit({
    required UserProgressRepository progressRepository,
    required AchievementsRepository achievementsRepository,
  })  : _progressRepository = progressRepository,
        _achievementsRepository = achievementsRepository,
        super(const ProfileState());

  final UserProgressRepository _progressRepository;
  final AchievementsRepository _achievementsRepository;

  Future<void> load() async {
    emit(state.copyWith(status: ProfileStatus.loading));
    try {
      final progress = await _progressRepository.getProgress(
        userId: AppConstants.localUserId,
      );

      List<String> badges = const [];
      try {
        final result = await _achievementsRepository.getAchievements();
        badges = result.earned.map((a) => a.title).toList();
      } catch (_) {}

      emit(state.copyWith(
        status: ProfileStatus.loaded,
        progress: progress,
        earnedBadgeLabels: badges,
      ));
    } catch (_) {
      emit(state.copyWith(
        status: ProfileStatus.error,
        errorMessage: 'تعذّر تحميل الملف الشخصي',
      ));
    }
  }
}
