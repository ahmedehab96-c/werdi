import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:werdi/features/achievements/data/repositories/laravel_achievements_repository.dart';
import 'package:werdi/features/achievements/presentation/cubit/achievements_state.dart';

class AchievementsCubit extends Cubit<AchievementsState> {
  AchievementsCubit({required LaravelAchievementsRepository repository})
      : _repository = repository,
        super(const AchievementsState());

  final LaravelAchievementsRepository _repository;

  Future<void> load() async {
    emit(state.copyWith(status: AchievementsStatus.loading));
    try {
      final result = await _repository.getAchievements();
      emit(state.copyWith(
        status: AchievementsStatus.loaded,
        earned: result.earned,
        upcoming: result.upcoming,
      ));
    } catch (_) {
      emit(state.copyWith(
        status: AchievementsStatus.error,
        errorMessage: 'تعذّر تحميل الإنجازات',
      ));
    }
  }
}
