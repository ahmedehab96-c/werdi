import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:werdi/features/achievements/data/repositories/laravel_achievements_repository.dart';
import 'package:werdi/features/auth/domain/repositories/auth_repository.dart';
import 'package:werdi/features/profile/presentation/cubit/profile_state.dart';
import 'package:werdi/shared/repositories/user_progress_repository.dart';

class ProfileCubit extends Cubit<ProfileState> {
  ProfileCubit({
    required AuthRepository authRepository,
    required UserProgressRepository progressRepository,
    required LaravelAchievementsRepository achievementsRepository,
  })  : _authRepository = authRepository,
        _progressRepository = progressRepository,
        _achievementsRepository = achievementsRepository,
        super(const ProfileState());

  final AuthRepository _authRepository;
  final UserProgressRepository _progressRepository;
  final LaravelAchievementsRepository _achievementsRepository;

  Future<void> load() async {
    emit(state.copyWith(status: ProfileStatus.loading));
    try {
      final user = await _authRepository.getMe();
      final progress =
          await _progressRepository.getProgress(userId: user.id);

      List<String> badges = const [];
      try {
        final result = await _achievementsRepository.getAchievements();
        badges = result.earned.map((a) => a.title).toList();
      } catch (_) {}

      emit(state.copyWith(
        status: ProfileStatus.loaded,
        user: user,
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
