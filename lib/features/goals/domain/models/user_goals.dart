import 'dart:convert';

import 'package:equatable/equatable.dart';

/// Preset + custom goals persisted locally for the user.
class UserGoals extends Equatable {
  const UserGoals({
    this.dailyTargetAyahs = 8,
    this.memorizationGoalAyahs = 300,
    this.reviewSessionsGoal = 15,
    this.customGoals = const [],
  });

  final int dailyTargetAyahs;
  final int memorizationGoalAyahs;
  final int reviewSessionsGoal;
  final List<UserCustomGoal> customGoals;

  static const storageKey = 'user_goals_v1';

  UserGoals copyWith({
    int? dailyTargetAyahs,
    int? memorizationGoalAyahs,
    int? reviewSessionsGoal,
    List<UserCustomGoal>? customGoals,
  }) {
    return UserGoals(
      dailyTargetAyahs: dailyTargetAyahs ?? this.dailyTargetAyahs,
      memorizationGoalAyahs:
          memorizationGoalAyahs ?? this.memorizationGoalAyahs,
      reviewSessionsGoal: reviewSessionsGoal ?? this.reviewSessionsGoal,
      customGoals: customGoals ?? this.customGoals,
    );
  }

  Map<String, dynamic> toJson() => {
        'dailyTargetAyahs': dailyTargetAyahs,
        'memorizationGoalAyahs': memorizationGoalAyahs,
        'reviewSessionsGoal': reviewSessionsGoal,
        'customGoals': customGoals.map((g) => g.toJson()).toList(),
      };

  factory UserGoals.fromJson(Map<String, dynamic> json) {
    final rawCustom = json['customGoals'];
    final custom = <UserCustomGoal>[];
    if (rawCustom is List) {
      for (final item in rawCustom) {
        if (item is Map) {
          custom.add(
            UserCustomGoal.fromJson(Map<String, dynamic>.from(item)),
          );
        }
      }
    }
    return UserGoals(
      dailyTargetAyahs: _readInt(json['dailyTargetAyahs'], 8).clamp(1, 200),
      memorizationGoalAyahs:
          _readInt(json['memorizationGoalAyahs'], 300).clamp(10, 6236),
      reviewSessionsGoal:
          _readInt(json['reviewSessionsGoal'], 15).clamp(1, 500),
      customGoals: custom,
    );
  }

  static UserGoals decode(String? raw) {
    if (raw == null || raw.isEmpty) return const UserGoals();
    try {
      final decoded = jsonDecode(raw);
      if (decoded is Map<String, dynamic>) {
        return UserGoals.fromJson(decoded);
      }
    } catch (_) {}
    return const UserGoals();
  }

  String encode() => jsonEncode(toJson());

  static int _readInt(Object? value, int fallback) {
    if (value is int) return value;
    if (value is num) return value.toInt();
    return int.tryParse('$value') ?? fallback;
  }

  @override
  List<Object?> get props => [
        dailyTargetAyahs,
        memorizationGoalAyahs,
        reviewSessionsGoal,
        customGoals,
      ];
}

class UserCustomGoal extends Equatable {
  const UserCustomGoal({
    required this.id,
    required this.title,
    required this.target,
  });

  final String id;
  final String title;
  final int target;

  UserCustomGoal copyWith({
    String? id,
    String? title,
    int? target,
  }) {
    return UserCustomGoal(
      id: id ?? this.id,
      title: title ?? this.title,
      target: target ?? this.target,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'target': target,
      };

  factory UserCustomGoal.fromJson(Map<String, dynamic> json) {
    return UserCustomGoal(
      id: '${json['id'] ?? DateTime.now().microsecondsSinceEpoch}',
      title: '${json['title'] ?? ''}'.trim(),
      target: UserGoals._readInt(json['target'], 1).clamp(1, 9999),
    );
  }

  @override
  List<Object?> get props => [id, title, target];
}
