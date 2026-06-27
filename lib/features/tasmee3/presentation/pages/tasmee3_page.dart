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
    final l10n = context.l10n;
    final progress = state.totalAyahs == 0
        ? 0.0
        : state.currentAyahIndex / state.totalAyahs;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            AppText(
              l10n.ayahProgress(
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
        Expanded(
          child: _AyahCard(state: state),
        ),
        if (state.speechError != null) ...[
          SizedBox(height: AppSpacing.sm),
          AppText(
            _speechErrorMessage(context, state.speechError),
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Theme.of(context).colorScheme.error,
                ),
            textAlign: TextAlign.center,
          ),
        ],
        SizedBox(height: AppSpacing.md),
        if (state.evaluationReady) ...[
          AppButton(
            label: state.isLastAyah ? l10n.testSummary : l10n.nextAyah,
            onPressed: cubit.confirmAndNextAyah,
            icon: Icon(
              state.isLastAyah
                  ? Icons.summarize_rounded
                  : Icons.arrow_forward_rounded,
            ),
          ),
          SizedBox(height: AppSpacing.sm),
          OutlinedButton.icon(
            onPressed: cubit.startListening,
            icon: const Icon(Icons.replay_rounded),
            label: Text(l10n.retryRecitation),
          ),
        ] else if (state.isListening)
          AppButton(
            label: l10n.finishRecitation,
            onPressed: cubit.finishListeningAndEvaluate,
            icon: const Icon(Icons.stop_circle_rounded),
          )
        else
          AppButton(
            label: l10n.startVoiceRecitation,
            onPressed: state.speechAvailable ? cubit.startListening : null,
            icon: const Icon(Icons.mic_rounded),
          ),
      ],
    );
  }

  String _speechErrorMessage(BuildContext context, String? code) {
    final l10n = context.l10n;
    return switch (code) {
      'microphone_permission_denied' => l10n.microphonePermissionRequired,
      'speech_not_available' => l10n.speechNotAvailable,
      'speech_timeout' => l10n.speechTimeout,
      'wrong_language' => l10n.wrongLanguage,
      _ => l10n.speechError,
    };
  }
}

class _AyahCard extends StatelessWidget {
  const _AyahCard({required this.state});
  final Tasmee3State state;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return AppSurfaceCard(
      child: Center(
        child: state.evaluationReady
            ? SingleChildScrollView(
                child: Column(
                  children: [
                    AppText(
                      l10n.ayahErrorsInText,
                      style: Theme.of(context).textTheme.bodySmall,
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: AppSpacing.sm),
                    AppText(
                      l10n.voiceAccuracy(state.spokenAccuracy),
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: AppSpacing.md),
                    AyahDiffText(
                      words: state.ayahWords,
                      wordCorrect: state.expectedWordCorrect,
                      fontScale: 1.05,
                    ),
                  ],
                ),
              )
            : SingleChildScrollView(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    if (state.isListening) ...[
                      Container(
                        width: 88.w,
                        height: 88.w,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Theme.of(context)
                              .colorScheme
                              .errorContainer
                              .withValues(alpha: 0.5),
                        ),
                        child: Icon(
                          Icons.mic_rounded,
                          size: 40.sp,
                          color: Theme.of(context).colorScheme.error,
                        ),
                      )
                          .animate(onPlay: (c) => c.repeat())
                          .scale(
                            begin: const Offset(0.92, 0.92),
                            end: const Offset(1.08, 1.08),
                            duration: 900.ms,
                          ),
                      SizedBox(height: 16.h),
                      AppText(
                        l10n.autoGradingActive,
                        style: Theme.of(context).textTheme.bodyMedium,
                        textAlign: TextAlign.center,
                      ),
                      if (state.spokenText.isNotEmpty) ...[
                        SizedBox(height: AppSpacing.md),
                        AppText(
                          state.spokenText,
                          style: Theme.of(context).textTheme.bodyLarge,
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ] else ...[
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
                      Icon(
                        Icons.mic_none_rounded,
                        size: 48.sp,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                      SizedBox(height: 8.h),
                      AppText(
                        l10n.hiddenAyah,
                        style: Theme.of(context).textTheme.bodySmall,
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ],
                ),
              ),
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
                    .where(
                      (e) =>
                          e.hasErrors ||
                          result.grades[e.ayahNumber] != AyahGrade.known,
                    )
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
