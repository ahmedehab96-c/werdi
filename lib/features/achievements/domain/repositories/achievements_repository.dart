import 'package:werdi/features/achievements/domain/models/achievement_item.dart';

abstract interface class AchievementsRepository {
  Future<({List<AchievementItem> earned, List<AchievementItem> upcoming})>
      getAchievements();

  Future<({List<AchievementItem> earned, List<AchievementItem> upcoming})>
      evaluateFromMetrics({
    required int memorizedAyahCount,
    required int reviewedItemsCount,
    required int streakDays,
    required int tasmee3Sessions,
  });
}
