import 'package:equatable/equatable.dart';

class SettingsState extends Equatable {
  const SettingsState({
    this.fontScale = 1.0,
    this.remindersEnabled = false,
    this.reminderHour = 8,
    this.reminderMinute = 0,
    this.openSearchResultsInFocusMode = true,
    this.useUnifiedReadingPreferences = false,
  });

  final double fontScale;
  final bool remindersEnabled;
  final int reminderHour;
  final int reminderMinute;
  final bool openSearchResultsInFocusMode;
  final bool useUnifiedReadingPreferences;

  SettingsState copyWith({
    double? fontScale,
    bool? remindersEnabled,
    int? reminderHour,
    int? reminderMinute,
    bool? openSearchResultsInFocusMode,
    bool? useUnifiedReadingPreferences,
  }) {
    return SettingsState(
      fontScale: fontScale ?? this.fontScale,
      remindersEnabled: remindersEnabled ?? this.remindersEnabled,
      reminderHour: reminderHour ?? this.reminderHour,
      reminderMinute: reminderMinute ?? this.reminderMinute,
      openSearchResultsInFocusMode:
          openSearchResultsInFocusMode ?? this.openSearchResultsInFocusMode,
      useUnifiedReadingPreferences:
          useUnifiedReadingPreferences ?? this.useUnifiedReadingPreferences,
    );
  }

  @override
  List<Object> get props => [
    fontScale,
    remindersEnabled,
    reminderHour,
    reminderMinute,
    openSearchResultsInFocusMode,
    useUnifiedReadingPreferences,
  ];
}
