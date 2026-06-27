import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:werdi/core/di/app_injector.dart';
import 'package:werdi/core/theme/app_spacing.dart';
import 'package:werdi/core/widgets/app_button.dart';
import 'package:werdi/core/widgets/app_empty_state.dart';
import 'package:werdi/core/widgets/app_loading_state.dart';
import 'package:werdi/core/widgets/app_scaffold.dart';
import 'package:werdi/core/widgets/app_surface_card.dart';
import 'package:werdi/core/widgets/quran_ayah_text.dart';
import 'package:werdi/core/widgets/app_text.dart';
import 'package:werdi/features/tasmee3/domain/models/tasmee3_result.dart';
import 'package:werdi/features/tasmee3/presentation/cubit/tasmee3_cubit.dart';
import 'package:werdi/features/tasmee3/presentation/cubit/tasmee3_state.dart';
import 'package:werdi/features/tasmee3/presentation/pages/tasmee3_session_details_page.dart';
import 'package:werdi/features/tasmee3/presentation/widgets/ayah_diff_text.dart';
import 'package:werdi/features/tasmee3/presentation/widgets/tasmee3_widgets.dart';
import 'package:werdi/core/extensions/context_extensions.dart';

class Tasmee3Page extends StatelessWidget {
  const Tasmee3Page({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => Tasmee3Cubit(
        repository: AppInjector.tasmee3Gateway,
        quranRepository: AppInjector.quranRepository,
        audioRepository: AppInjector.audioRepository,
        preferences: AppInjector.appPreferences,
      )..initialize(),
      child: const _Tasmee3View(),
    );
  }
}

class _Tasmee3View extends StatelessWidget {
  const _Tasmee3View();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<Tasmee3Cubit, Tasmee3State>(
      builder: (context, state) {
        return AppScaffold(
          appBar: AppBar(
            title: Text(_title(context, state.status)),
            leading: state.status != Tasmee3FlowStatus.setup
                ? IconButton(
                    icon: const Icon(Icons.arrow_back_rounded),
                    onPressed: () =>
                        context.read<Tasmee3Cubit>().backToSetup(),
                  )
                : null,
            actions: [
              if (state.status == Tasmee3FlowStatus.setup)
                IconButton(
                  onPressed: () =>
                      context.read<Tasmee3Cubit>().openHistory(),
                  icon: const Icon(Icons.history_rounded),
                  tooltip: context.l10n.sessionHistory,
                ),
            ],
          ),
          body: state.isLoading
              ? AppLoadingState(message: context.l10n.preparingSession)
              : Padding(
                  padding: EdgeInsets.all(AppSpacing.md),
                  child: switch (state.status) {
                    Tasmee3FlowStatus.setup => _SetupScreen(state: state),
                    Tasmee3FlowStatus.testing => _TestingScreen(state: state),
                    Tasmee3FlowStatus.summary => _SummaryScreen(state: state),
                    Tasmee3FlowStatus.history => _HistoryScreen(state: state),
                  },
                ),
        );
      },
    );
  }

  String _title(BuildContext context, Tasmee3FlowStatus status) {
    final l10n = context.l10n;
    return switch (status) {
      Tasmee3FlowStatus.setup => l10n.tasmee3Title,
      Tasmee3FlowStatus.testing => l10n.tasmee3Title,
      Tasmee3FlowStatus.summary => l10n.testSummary,
      Tasmee3FlowStatus.history => l10n.sessionHistory,
    };
  }
}

// ─── شاشة الإعداد ────────────────────────────────────────────────────────────

class _SetupScreen extends StatelessWidget {
  const _SetupScreen({required this.state});
  final Tasmee3State state;

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<Tasmee3Cubit>();
    final l10n = context.l10n;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        AppSurfaceCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AppText(
                l10n.chooseSurah,
                style: Theme.of(context).textTheme.titleSmall,
              ),
              SizedBox(height: AppSpacing.sm),
              DropdownButtonFormField<int>(
                isExpanded: true,
                initialValue: state.availableSurahNumbers.contains(
                        state.selectedSurahNumber)
                    ? state.selectedSurahNumber
                    : (state.availableSurahNumbers.isNotEmpty
                        ? state.availableSurahNumbers.first
                        : null),
                items: List.generate(
                  state.availableSurahs.length,
                  (i) => DropdownMenuItem(
                    value: state.availableSurahNumbers[i],
                    child: Text(
                      '${state.availableSurahNumbers[i]}. ${state.availableSurahs[i]}',
                    ),
                  ),
                ),
                onChanged: (val) {
                  if (val == null) return;
                  cubit.selectSurah(
                    state.availableSurahNumbers.indexOf(val),
                  );
                },
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.menu_book_rounded),
                ),
              ),
            ],
          ),
        ),
        SizedBox(height: AppSpacing.md),
        AppSurfaceCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AppText(
                l10n.ayahRange,
                style: Theme.of(context).textTheme.titleSmall,
              ),
              SizedBox(height: AppSpacing.sm),
              Row(
                children: [
                  Expanded(
                    child: _RangeDropdown(
                      label: l10n.fromAyah,
                      value: state.selectedRange.start,
                      min: 1,
                      max: state.selectedSurahVerseCount,
                      onChanged: cubit.setRangeStart,
                    ),
                  ),
                  SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: _RangeDropdown(
                      label: l10n.toAyah,
                      value: state.selectedRange.end,
                      min: state.selectedRange.start,
                      max: state.selectedSurahVerseCount,
                      onChanged: cubit.setRangeEnd,
                    ),
                  ),
                ],
              ),
              SizedBox(height: AppSpacing.xs),
              AppText(
                l10n.ayahCount(
                  state.selectedRange.end - state.selectedRange.start + 1,
                ),
                style: Theme.of(context).textTheme.bodySmall,
              ),
              SizedBox(height: AppSpacing.md),
              FilledButton.tonalIcon(
                onPressed: cubit.toggleAudioTest,
                icon: Icon(
                  state.isAudioTestPlaying
                      ? Icons.stop_circle_rounded
                      : Icons.volume_up_rounded,
                ),
                label: Text(
                  state.isAudioTestPlaying
                      ? l10n.stopAudioTest
                      : l10n.playAudioTest,
                ),
              ),
              if (state.audioTestError != null) ...[
                SizedBox(height: AppSpacing.xs),
                AppText(
                  l10n.audioTestFailed,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(context).colorScheme.error,
                      ),
                ),
              ],
            ],
          ),
        ),
        const Spacer(),
        AppSurfaceCard(
          child: Row(
            children: [
              const Icon(Icons.info_outline_rounded, size: 18),
              SizedBox(width: 8.w),
              Expanded(
                child: AppText(
                  l10n.tasmee3Description,
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ),
            ],
          ),
        ),
        SizedBox(height: AppSpacing.md),
        AppButton(
          label: l10n.startTest,
          onPressed: cubit.startTest,
          icon: const Icon(Icons.play_arrow_rounded),
        ),
      ],
    );
  }
}

class _RangeDropdown extends StatelessWidget {
  const _RangeDropdown({
    required this.label,
    required this.value,
    required this.min,
    required this.max,
    required this.onChanged,
  });

  final String label;
  final int value;
  final int min;
  final int max;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    final effectiveMax = max < min ? min : max;
    final clamped = value.clamp(min, effectiveMax);
    return DropdownButtonFormField<int>(
      isExpanded: true,
      initialValue: clamped,
      decoration: InputDecoration(
        labelText: label,
        border: const OutlineInputBorder(),
      ),
      items: List.generate(
        effectiveMax - min + 1,
        (index) {
          final ayahNumber = min + index;
          return DropdownMenuItem<int>(
            value: ayahNumber,
            child: Text('$ayahNumber'),
          );
        },
      ),
      onChanged: (value) {
        if (value != null) onChanged(value);
      },
    );
  }
}

// ─── شاشة الاختبار ───────────────────────────────────────────────────────────

class _TestingScreen extends StatelessWidget {
  const _TestingScreen({required this.state});
  final Tasmee3State state;

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<Tasmee3Cubit>();
    final progress = state.totalAyahs == 0
        ? 0.0
        : state.currentAyahIndex / state.totalAyahs;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // ── شريط التقدم
        Row(
          children: [
            AppText(
              context.l10n.ayahProgress(
                state.currentAyahIndex + 1,
                state.totalAyahs,
              ),
              style: Theme.of(context).textTheme.bodySmall,
            ),
            const Spacer(),
            AppText(
              '${state.selectedSurah}  ${state.selectedRange.label}',
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
        ),
        SizedBox(height: 6.h),
        LinearProgressIndicator(
          value: progress,
          borderRadius: BorderRadius.circular(8),
          minHeight: 6,
        ),
        SizedBox(height: AppSpacing.md),

        // ── بطاقة الآية
        Expanded(
          child: _AyahCard(state: state, cubit: cubit),
        ),
        SizedBox(height: AppSpacing.md),

        // ── أزرار التسميع والتقييم
        if (state.evaluationReady) ...[
          AppButton(
            label: state.isLastAyah
                ? context.l10n.testSummary
                : context.l10n.nextAyah,
            onPressed: cubit.confirmAndNextAyah,
            icon: const Icon(Icons.arrow_forward_rounded),
          ),
          SizedBox(height: AppSpacing.sm),
          OutlinedButton.icon(
            onPressed: cubit.startListening,
            icon: const Icon(Icons.replay_rounded),
            label: Text(context.l10n.retryRecitation),
          ),
        ] else if (state.isRevealed) ...[
          AppText(
            context.l10n.hiddenAyah,
            style: Theme.of(context).textTheme.titleSmall,
            textAlign: TextAlign.center,
          ),
          SizedBox(height: AppSpacing.sm),
          _GradeButtons(cubit: cubit),
        ] else
          AppButton(
            label: context.l10n.revealAyah,
            onPressed: cubit.revealCurrentAyah,
            icon: const Icon(Icons.visibility_rounded),
          ),
      ],
    );
  }
}

class _AyahCard extends StatelessWidget {
  const _AyahCard({required this.state, required this.cubit});
  final Tasmee3State state;
  final Tasmee3Cubit cubit;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return AppSurfaceCard(
      child: Center(
        child: state.isRevealed
            ? SingleChildScrollView(
                child: QuranAyahText(
                  text: state.currentAyahText ?? '',
                  fontScale: 1.1,
                )
                    .animate()
                    .fadeIn(duration: 300.ms)
                    .slideY(begin: 0.05, end: 0),
              )
            : SingleChildScrollView(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: 72.w,
                      height: 72.w,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Theme.of(context)
                            .colorScheme
                            .primaryContainer
                            .withValues(alpha: 0.6),
                      ),
                      child: Icon(
                        Icons.visibility_off_rounded,
                        size: 32.sp,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    ),
                    SizedBox(height: 16.h),
                    Text(
                      l10n.ayahNumbered(state.currentAyahNumber),
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                    ),
                    SizedBox(height: 8.h),
                    AppText(
                      l10n.speechRecitePrompt,
                      style: Theme.of(context).textTheme.bodyMedium,
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: AppSpacing.md),
                    if (state.evaluationReady &&
                        state.expectedWords.isNotEmpty) ...[
                      AppText(
                        l10n.ayahErrorsInText,
                        style: Theme.of(context).textTheme.titleSmall,
                        textAlign: TextAlign.center,
                      ),
                      SizedBox(height: AppSpacing.sm),
                      AyahDiffText(
                        words: state.expectedWords,
                        wordCorrect: state.expectedWordCorrect,
                      ),
                      SizedBox(height: AppSpacing.md),
                      AppText(
                        l10n.voiceAccuracy(state.spokenAccuracy),
                        style: Theme.of(context).textTheme.titleMedium,
                        textAlign: TextAlign.center,
                      ),
                    ] else ...[
                      FilledButton.icon(
                        onPressed: state.isListening
                            ? cubit.finishListeningAndEvaluate
                            : cubit.startListening,
                        icon: Icon(
                          state.isListening
                              ? Icons.check_circle_rounded
                              : Icons.mic_rounded,
                        ),
                        label: Text(
                          state.isListening
                              ? l10n.finishRecitation
                              : l10n.startVoiceRecitation,
                        ),
                      ),
                      SizedBox(height: 8.h),
                      AppText(
                        l10n.autoGradingHint,
                        style: Theme.of(context).textTheme.bodySmall,
                        textAlign: TextAlign.center,
                      ),
                    ],
                    if (state.speechError != null) ...[
                      SizedBox(height: 8.h),
                      AppText(
                        _speechErrorMessage(l10n, state.speechError!),
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: Theme.of(context).colorScheme.error,
                            ),
                        textAlign: TextAlign.center,
                      ),
                      if (state.speechError != 'microphone_permission_denied' &&
                          state.speechError != 'speech_not_available' &&
                          state.speechError != 'arabic_not_available') ...[
                        SizedBox(height: 8.h),
                        OutlinedButton.icon(
                          onPressed: cubit.startListening,
                          icon: const Icon(Icons.refresh_rounded),
                          label: Text(l10n.retryRecitation),
                        ),
                      ],
                    ],
                    if (state.isListening && state.spokenAccuracy > 0) ...[
                      SizedBox(height: AppSpacing.md),
                      AppText(
                        l10n.voiceAccuracy(state.spokenAccuracy),
                        style: Theme.of(context).textTheme.titleSmall,
                      ),
                    ],
                    if (state.currentAyahRecordingPath != null) ...[
                      SizedBox(height: AppSpacing.md),
                      FilledButton.tonalIcon(
                        onPressed: cubit.togglePlayUserRecording,
                        icon: Icon(
                          state.isPlayingUserRecording
                              ? Icons.stop_circle_rounded
                              : Icons.play_circle_rounded,
                        ),
                        label: Text(
                          state.isPlayingUserRecording
                              ? l10n.stopMyRecording
                              : l10n.playMyRecording,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
      ),
    );
  }
}

class _GradeButtons extends StatelessWidget {
  const _GradeButtons({required this.cubit});
  final Tasmee3Cubit cubit;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Row(
      children: [
        Expanded(
          child: _GradeBtn(
            label: l10n.iKnowIt,
            icon: Icons.check_circle_rounded,
            color: Colors.green,
            onTap: () => cubit.gradeAyah(AyahGrade.known),
          ),
        ),
        SizedBox(width: 6.w),
        Expanded(
          child: _GradeBtn(
            label: l10n.iHesitated,
            icon: Icons.warning_amber_rounded,
            color: Colors.orange,
            onTap: () => cubit.gradeAyah(AyahGrade.hesitant),
          ),
        ),
        SizedBox(width: 6.w),
        Expanded(
          child: _GradeBtn(
            label: l10n.iForgot,
            icon: Icons.cancel_rounded,
            color: Colors.redAccent,
            onTap: () => cubit.gradeAyah(AyahGrade.unknown),
          ),
        ),
      ],
    );
  }
}

class _GradeBtn extends StatelessWidget {
  const _GradeBtn({
    required this.label,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return FilledButton.tonal(
      onPressed: onTap,
      style: FilledButton.styleFrom(
        backgroundColor: color.withValues(alpha: 0.12),
        foregroundColor: color,
        padding: EdgeInsets.symmetric(vertical: 14.h),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
          side: BorderSide(color: color.withValues(alpha: 0.3)),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 22.sp),
          SizedBox(height: 4.h),
          Text(label, style: TextStyle(fontSize: 12.sp)),
        ],
      ),
    );
  }
}

// ─── شاشة النتيجة ────────────────────────────────────────────────────────────

class _SummaryScreen extends StatelessWidget {
  const _SummaryScreen({required this.state});
  final Tasmee3State state;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final cubit = context.read<Tasmee3Cubit>();
    final result = state.result!;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        ScoreSummaryCard(result: result).animate().fadeIn(duration: 400.ms),
        SizedBox(height: AppSpacing.md),
        AppSurfaceCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AppText(
                l10n.ayahsToReview,
                style: Theme.of(context).textTheme.titleSmall,
              ),
              SizedBox(height: AppSpacing.sm),
              if (result.unknownCount == 0 && result.hesitantCount == 0)
                AppText(
                  l10n.excellent,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Colors.green,
                      ),
                )
              else ...[
                ...state.ayahEvaluations.values
                    .where((e) => e.hasErrors)
                    .map(
                      (evaluation) => Padding(
                        padding: EdgeInsets.only(bottom: AppSpacing.md),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Row(
                              children: [
                                AppText(
                                  l10n.ayahNumbered(evaluation.ayahNumber),
                                  style: Theme.of(context)
                                      .textTheme
                                      .titleSmall
                                      ?.copyWith(fontWeight: FontWeight.w700),
                                ),
                                const Spacer(),
                                AppText(
                                  l10n.voiceAccuracy(evaluation.accuracyPercent),
                                  style: Theme.of(context).textTheme.bodySmall,
                                ),
                                SizedBox(width: 8.w),
                                FilledButton.tonalIcon(
                                  onPressed: () =>
                                      cubit.toggleReciterAyah(evaluation.ayahNumber),
                                  icon: const Icon(
                                    Icons.volume_up_rounded,
                                    size: 18,
                                  ),
                                  label: Text(l10n.listenReciterAyah),
                                  style: FilledButton.styleFrom(
                                    visualDensity: VisualDensity.compact,
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: AppSpacing.sm),
                            AyahDiffText(
                              words: evaluation.expectedWords,
                              wordCorrect: evaluation.expectedWordCorrect,
                              fontScale: 0.95,
                            ),
                          ],
                        ),
                      ),
                    ),
              ],
            ],
          ),
        ),
        const Spacer(),
        AppButton(
          label: l10n.retakeTest,
          onPressed: cubit.retryTest,
          icon: const Icon(Icons.replay_rounded),
        ),
        SizedBox(height: AppSpacing.sm),
        OutlinedButton.icon(
          onPressed: cubit.openHistory,
          icon: const Icon(Icons.history_rounded),
          label: Text(l10n.sessionHistory),
        ),
        SizedBox(height: AppSpacing.sm),
        TextButton(
          onPressed: cubit.backToSetup,
          child: Text(l10n.backToSetup),
        ),
      ],
    );
  }
}

// ─── شاشة السجل ──────────────────────────────────────────────────────────────

class _HistoryScreen extends StatelessWidget {
  const _HistoryScreen({required this.state});
  final Tasmee3State state;

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<Tasmee3Cubit>();
    final filteredHistory = state.filteredHistory;
    const filters = ['الكل', 'ممتاز', 'جيد جدًا', 'جيد', 'يحتاج مراجعة'];
    return Column(
      children: [
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: filters
                .map(
                  (f) => Padding(
                    padding: EdgeInsets.only(left: 6.w),
                    child: ChoiceChip(
                      label: Text(f),
                      selected: state.historyFilter == f,
                      onSelected: (_) => cubit.setHistoryFilter(f),
                    ),
                  ),
                )
                .toList(),
          ),
        ),
        SizedBox(height: AppSpacing.sm),
        Expanded(
          child: filteredHistory.isEmpty
              ? AppEmptyState(
                  title: context.l10n.noHistory,
                  subtitle: context.l10n.noHistorySubtitle,
                  icon: Icons.history_rounded,
                )
              : ListView.separated(
                  itemCount: filteredHistory.length,
                  separatorBuilder: (_, _) => SizedBox(height: 8.h),
                  itemBuilder: (context, index) {
                    final session = filteredHistory[index];
                    return SessionHistoryCard(
                      session: session,
                      onOpen: () => Navigator.of(context).push(
                        MaterialPageRoute<void>(
                          builder: (_) =>
                              Tasmee3SessionDetailsPage(session: session),
                        ),
                      ),
                    );
                  },
                ),
        ),
        SizedBox(height: AppSpacing.sm),
        AppButton(
          label: context.l10n.backToSetup,
          onPressed: cubit.backToSetup,
          icon: const Icon(Icons.add_rounded),
        ),
      ],
    );
  }
}

String _speechErrorMessage(dynamic l10n, String code) {
  return switch (code) {
    'microphone_permission_denied' => l10n.microphonePermissionRequired,
    'speech_not_available' => l10n.speechNotAvailable,
    'arabic_not_available' => l10n.arabicNotAvailable,
    'speech_timeout' => l10n.speechTimeout,
    'wrong_language' => l10n.wrongLanguage,
    _ => l10n.speechError,
  };
}
