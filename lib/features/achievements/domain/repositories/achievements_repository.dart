import 'package:werdi/features/achievements/domain/models/achievement_item.dart';

abstract interface class AchievementsRepository {
  Future<({List<AchievementItem> earned, List<AchievementItem> upcoming})>
      getAchievements();
}
