import 'package:equatable/equatable.dart';

enum ReviewPriority { high, medium, low }

class ReviewItem extends Equatable {
  const ReviewItem({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.priority,
    this.surahNumber,
    this.ayahStart,
    this.ayahEnd,
    this.ayahText = '',
    this.reviewed = false,
    this.difficult = false,
  });

  final String id;
  final String title;
  final String subtitle;
  final ReviewPriority priority;
  final int? surahNumber;
  final int? ayahStart;
  final int? ayahEnd;
  // Loaded from quran package at runtime; never written to disk.
  final String ayahText;
  final bool reviewed;
  final bool difficult;

  ReviewItem copyWith({
    String? title,
    String? subtitle,
    ReviewPriority? priority,
    String? ayahText,
    bool? reviewed,
    bool? difficult,
  }) {
    return ReviewItem(
      id: id,
      title: title ?? this.title,
      subtitle: subtitle ?? this.subtitle,
      priority: priority ?? this.priority,
      surahNumber: surahNumber,
      ayahStart: ayahStart,
      ayahEnd: ayahEnd,
      ayahText: ayahText ?? this.ayahText,
      reviewed: reviewed ?? this.reviewed,
      difficult: difficult ?? this.difficult,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'subtitle': subtitle,
        'priority': priority.name,
        'surah_number': surahNumber,
        'ayah_start': ayahStart,
        'ayah_end': ayahEnd,
        'reviewed': reviewed,
        'difficult': difficult,
      };

  factory ReviewItem.fromJson(Map<String, dynamic> json) => ReviewItem(
        id: '${json['id'] ?? ''}',
        title: '${json['title'] ?? ''}',
        subtitle: '${json['subtitle'] ?? ''}',
        priority: _priorityFrom('${json['priority'] ?? 'medium'}'),
        surahNumber: json['surah_number'] as int?,
        ayahStart: json['ayah_start'] as int?,
        ayahEnd: json['ayah_end'] as int?,
        reviewed: json['reviewed'] as bool? ?? false,
        difficult: json['difficult'] as bool? ?? false,
      );

  static ReviewPriority _priorityFrom(String value) => switch (value) {
        'high' => ReviewPriority.high,
        'low' => ReviewPriority.low,
        _ => ReviewPriority.medium,
      };

  @override
  List<Object?> get props => [
        id,
        title,
        subtitle,
        priority,
        surahNumber,
        ayahStart,
        ayahEnd,
        ayahText,
        reviewed,
        difficult,
      ];
}
