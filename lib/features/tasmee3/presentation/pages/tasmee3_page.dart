import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:werdi/core/di/app_injector.dart';
import 'package:werdi/core/responsive/responsive_helper.dart';
import 'package:werdi/core/theme/app_spacing.dart';
import 'package:werdi/core/widgets/app_button.dart';
import 'package:werdi/core/widgets/app_empty_state.dart';
import 'package:werdi/core/widgets/app_loading_state.dart';
import 'package:werdi/core/widgets/app_scaffold.dart';
import 'package:werdi/core/widgets/app_scrollable_body.dart';
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
        progressRepository: AppInjector.userProgressGateway,
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
              : Column(
                  children: [
                    Expanded(
                      child: Padding(
                        padding: EdgeInsets.all(AppSpacing.md),
                        child: switch (state.status) {
                          Tasmee3FlowStatus.setup =>
                            _SetupScreen(state: state),
                          Tasmee3FlowStatus.testing =>
                            Tasmee3TestingScreen(state: state),
                          Tasmee3FlowStatus.summary =>
                            Tasmee3SummaryScreen(state: state),
                          Tasmee3FlowStatus.history =>
                            _HistoryScreen(state: state),
                        },
                      ),
                    ),
                  ],
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
    return AppScrollableBody(
      footer: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SizedBox(height: AppSpacing.sm),
          AppSurfaceCard(
            child: Row(
              children: [
                const Icon(Icons.info_outline_rounded, size: 18),
                const SizedBox(width: AppSpacing.xs),
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
      ),
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

class Tasmee3TestingScreen extends StatelessWidget {
  const Tasmee3TestingScreen({required this.state, super.key});
  final Tasmee3State state;

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<Tasmee3Cubit>();
    final l10n = context.l10n;

    final actions = <Widget>[
      if (state.evaluationReady) ...[
        AppButton(
          label: l10n.testSummary,
          onPressed: cubit.confirmAndNextAyah,
          icon: const Icon(Icons.summarize_rounded),
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
      else if (state.spokenText.trim().isNotEmpty && !state.evaluationReady)
        AppButton(
          label: l10n.finishRecitation,
          onPressed: cubit.finishListeningAndEvaluate,
          icon: const Icon(Icons.check_circle_outline_rounded),
        )
      else
        AppButton(
          label: l10n.startVoiceRecitation,
          onPressed: state.speechAvailable ? cubit.startListening : null,
          icon: const Icon(Icons.mic_rounded),
        ),
    ];

    return AppScrollableBody(
      footer: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
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
          ...actions,
        ],
      ),
      children: [
        Row(
          children: [
            AppText(
              l10n.ayahCount(state.totalAyahs),
              style: Theme.of(context).textTheme.bodySmall,
            ),
            const Spacer(),
            Flexible(
              child: AppText(
                '${state.selectedSurah}  ${state.selectedRange.label}',
                style: Theme.of(context).textTheme.bodySmall,
                textAlign: TextAlign.end,
              ),
            ),
          ],
        ),
        SizedBox(height: AppSpacing.md),
        _AyahCard(state: state),
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
      child: state.evaluationReady
          ? Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
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
                ...state.ayahEvaluations.values.map(
                  (evaluation) => Padding(
                    padding: EdgeInsets.only(bottom: AppSpacing.md),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        AppText(
                          l10n.ayahNumbered(evaluation.ayahNumber),
                          style: Theme.of(context)
                              .textTheme
                              .titleSmall
                              ?.copyWith(fontWeight: FontWeight.w700),
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
            )
          : Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (state.isListening) ...[
                  Builder(
                    builder: (context) {
                      final size = ResponsiveHelper.adaptiveWidth(context, 88)
                          .clamp(64.0, 96.0);
                      final icon = ResponsiveHelper.adaptiveIcon(context, 40)
                          .clamp(28.0, 44.0);
                      return Container(
                        width: size,
                        height: size,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Theme.of(context)
                              .colorScheme
                              .errorContainer
                              .withValues(alpha: 0.5),
                        ),
                        child: Icon(
                          Icons.mic_rounded,
                          size: icon,
                          color: Theme.of(context).colorScheme.error,
                        ),
                      )
                          .animate(onPlay: (c) => c.repeat())
                          .scale(
                            begin: const Offset(0.92, 0.92),
                            end: const Offset(1.08, 1.08),
                            duration: 900.ms,
                          );
                    },
                  ),
                  SizedBox(height: AppSpacing.md),
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
                  Builder(
                    builder: (context) {
                      final size = ResponsiveHelper.adaptiveWidth(context, 72)
                          .clamp(56.0, 88.0);
                      final icon = ResponsiveHelper.adaptiveIcon(context, 32)
                          .clamp(24.0, 36.0);
                      return Container(
                        width: size,
                        height: size,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Theme.of(context)
                              .colorScheme
                              .primaryContainer
                              .withValues(alpha: 0.6),
                        ),
                        child: Icon(
                          Icons.visibility_off_rounded,
                          size: icon,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                      );
                    },
                  ),
                  SizedBox(height: AppSpacing.md),
                  Text(
                    '${state.selectedRange.label} • ${l10n.ayahCount(state.totalAyahs)}',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: AppSpacing.xs),
                  AppText(
                    l10n.blockRecitePrompt,
                    style: Theme.of(context).textTheme.bodyMedium,
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: AppSpacing.md),
                  Icon(
                    Icons.mic_none_rounded,
                    size: ResponsiveHelper.adaptiveIcon(context, 48)
                        .clamp(36.0, 52.0),
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ],
              ],
            ),
    );
  }
}

// ─── شاشة النتيجة ────────────────────────────────────────────────────────────

class Tasmee3SummaryScreen extends StatelessWidget {
  const Tasmee3SummaryScreen({required this.state, super.key});
  final Tasmee3State state;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final cubit = context.read<Tasmee3Cubit>();
    final result = state.result!;
    final evaluations = state.ayahEvaluations.values
        .where(
          (e) =>
              e.hasErrors || result.grades[e.ayahNumber] != AyahGrade.known,
        )
        .toList();

    return CustomScrollView(
      physics: const BouncingScrollPhysics(),
      slivers: [
        SliverToBoxAdapter(
          child: ScoreSummaryCard(result: result).animate().fadeIn(duration: 400.ms),
        ),
        SliverToBoxAdapter(child: SizedBox(height: AppSpacing.md)),
        SliverToBoxAdapter(
          child: AppSurfaceCard(
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
                  ),
              ],
            ),
          ),
        ),
        if (evaluations.isNotEmpty) ...[
          SliverToBoxAdapter(child: SizedBox(height: AppSpacing.sm)),
          SliverList.separated(
            itemCount: evaluations.length,
            separatorBuilder: (_, _) => SizedBox(height: AppSpacing.sm),
            itemBuilder: (context, index) {
              final evaluation = evaluations[index];
              return AppSurfaceCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Wrap(
                      spacing: AppSpacing.xs,
                      runSpacing: AppSpacing.xs,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children: [
                        AppText(
                          l10n.ayahNumbered(evaluation.ayahNumber),
                          style: Theme.of(context)
                              .textTheme
                              .titleSmall
                              ?.copyWith(fontWeight: FontWeight.w700),
                        ),
                        AppText(
                          l10n.voiceAccuracy(evaluation.accuracyPercent),
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                        FilledButton.tonalIcon(
                          onPressed: () =>
                              cubit.toggleReciterAyah(evaluation.ayahNumber),
                          icon: const Icon(Icons.volume_up_rounded, size: 18),
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
              );
            },
          ),
        ],
        SliverToBoxAdapter(child: SizedBox(height: AppSpacing.lg)),
        SliverToBoxAdapter(
          child: AppButton(
            label: l10n.retakeTest,
            onPressed: cubit.retryTest,
            icon: const Icon(Icons.replay_rounded),
          ),
        ),
        SliverToBoxAdapter(child: SizedBox(height: AppSpacing.sm)),
        SliverToBoxAdapter(
          child: OutlinedButton.icon(
            onPressed: cubit.openHistory,
            icon: const Icon(Icons.history_rounded),
            label: Text(l10n.sessionHistory),
          ),
        ),
        SliverToBoxAdapter(child: SizedBox(height: AppSpacing.sm)),
        SliverToBoxAdapter(
          child: TextButton(
            onPressed: cubit.backToSetup,
            child: Text(l10n.backToSetup),
          ),
        ),
        SliverToBoxAdapter(child: SizedBox(height: AppSpacing.md)),
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
                    padding: const EdgeInsets.only(left: AppSpacing.xxs),
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
                  separatorBuilder: (_, _) => const SizedBox(height: AppSpacing.xs),
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
