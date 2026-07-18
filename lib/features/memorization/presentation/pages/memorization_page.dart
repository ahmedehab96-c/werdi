import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:werdi/core/di/app_injector.dart';
import 'package:werdi/core/extensions/context_extensions.dart';
import 'package:werdi/core/responsive/responsive.dart';
import 'package:werdi/core/theme/app_spacing.dart';
import 'package:werdi/core/widgets/app_button.dart';
import 'package:werdi/core/widgets/app_loading_state.dart';
import 'package:werdi/core/widgets/app_scaffold.dart';
import 'package:werdi/core/widgets/app_scrollable_body.dart';
import 'package:werdi/core/widgets/app_surface_card.dart';
import 'package:werdi/core/widgets/quran_ayah_text.dart';
import 'package:werdi/core/widgets/app_text.dart';
import 'package:werdi/features/memorization/presentation/cubit/memorization_cubit.dart';
import 'package:werdi/features/memorization/presentation/cubit/memorization_state.dart';
import 'package:werdi/features/memorization/presentation/widgets/memorization_test_session.dart';

class MemorizationPage extends StatelessWidget {
  const MemorizationPage({this.initialSurahNumber, super.key});

  final int? initialSurahNumber;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => MemorizationCubit(
        repository: AppInjector.memorizationGateway,
        quranRepository: AppInjector.quranRepository,
        audioRepository: AppInjector.audioRepository,
        progressRepository: AppInjector.userProgressGateway,
        reviewRepository: AppInjector.reviewGateway,
        preferences: AppInjector.appPreferences,
        initialSurahNumber: initialSurahNumber,
      ),
      child: const _MemorizationView(),
    );
  }
}

class _MemorizationView extends StatelessWidget {
  const _MemorizationView();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<MemorizationCubit, MemorizationState>(
      builder: (context, state) {
        return AppScaffold(
          appBar: AppBar(
            title: Text(state.phase == MemorizationPhase.session
                ? '${context.l10n.memorizationTitle} • ${state.selectedSurahName}'
                : context.l10n.memorizationTitle),
            leading: state.phase != MemorizationPhase.setup
                ? IconButton(
                    icon: const Icon(Icons.arrow_back_rounded),
                    onPressed: () =>
                        context.read<MemorizationCubit>().backToSetup(),
                  )
                : null,
            actions: state.phase == MemorizationPhase.session
                ? [
                    IconButton(
                      tooltip: state.showAyahText
                          ? context.l10n.hideText
                          : context.l10n.showText,
                      icon: Icon(
                        state.showAyahText
                            ? Icons.visibility_off_rounded
                            : Icons.visibility_rounded,
                      ),
                      onPressed: () =>
                          context.read<MemorizationCubit>().toggleShowText(),
                    ),
                  ]
                : null,
          ),
          body: switch (state.phase) {
            MemorizationPhase.loading =>
              AppLoadingState(message: context.l10n.preparingSession),
            MemorizationPhase.setup => _SetupScreen(state: state),
            MemorizationPhase.session => _SessionScreen(state: state),
            MemorizationPhase.testSession =>
              MemorizationTestSession(memState: state),
          },
        );
      },
    );
  }
}

class _SetupScreen extends StatelessWidget {
  const _SetupScreen({required this.state});
  final MemorizationState state;

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<MemorizationCubit>();
    final l10n = context.l10n;
    final surahs = state.availableSurahs;

    return AppScrollableBody(
      padding: EdgeInsets.symmetric(vertical: AppSpacing.md),
      footer: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SizedBox(height: AppSpacing.sm),
          AppButton(
            label: l10n.startSession,
            onPressed: cubit.startSession,
            icon: const Icon(Icons.menu_book_rounded),
          ),
          TextButton(
            onPressed: cubit.startTestSession,
            child: Text(l10n.startVoiceRecitation),
          ),
        ],
      ),
      children: [
        AppSurfaceCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              DropdownButtonFormField<int>(
                initialValue: surahs.any((s) => s.number == state.selectedSurahNumber)
                    ? state.selectedSurahNumber
                    : (surahs.isNotEmpty ? surahs.first.number : null),
                isExpanded: true,
                decoration: InputDecoration(
                  labelText: l10n.surah,
                  border: const OutlineInputBorder(),
                ),
                items: surahs
                    .map((s) => DropdownMenuItem(
                          value: s.number,
                          child: Text('${s.number}. ${s.nameArabic}'),
                        ))
                    .toList(),
                onChanged: surahs.isEmpty
                    ? null
                    : (v) {
                        if (v != null) cubit.selectSurah(v);
                      },
              ),
              SizedBox(height: AppSpacing.sm),
              Row(
                children: [
                  Expanded(
                    child: _RangeDropdown(
                      label: l10n.fromAyah,
                      value: state.ayahStart,
                      max: state.selectedVerseCount,
                      onChanged: (v) => cubit.setAyahRange(v, state.ayahEnd),
                    ),
                  ),
                  SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: _RangeDropdown(
                      label: l10n.toAyah,
                      value: state.ayahEnd,
                      max: state.selectedVerseCount,
                      min: state.ayahStart,
                      onChanged: (v) => cubit.setAyahRange(state.ayahStart, v),
                    ),
                  ),
                ],
              ),
              SizedBox(height: AppSpacing.xs),
              AppText(
                l10n.ayahCount(state.ayahEnd - state.ayahStart + 1),
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
              ),
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
    required this.max,
    required this.onChanged,
    this.min = 1,
  });

  final String label;
  final int value;
  final int max;
  final int min;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    if (max < min) {
      return DropdownButtonFormField<int>(
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
        ),
        items: const [],
        onChanged: null,
      );
    }
    final clamped = value.clamp(min, max);
    return DropdownButtonFormField<int>(
      initialValue: clamped,
      decoration: InputDecoration(
        labelText: label,
        border: const OutlineInputBorder(),
      ),
      items: List.generate(
        max - min + 1,
        (i) {
          final n = min + i;
          return DropdownMenuItem(value: n, child: Text('$n'));
        },
      ),
      onChanged: (v) {
        if (v != null) onChanged(v);
      },
    );
  }
}

class _SessionScreen extends StatelessWidget {
  const _SessionScreen({required this.state});
  final MemorizationState state;

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<MemorizationCubit>();
    final ayah = state.currentAyah;
    final l10n = context.l10n;
    if (ayah == null) {
      return AppLoadingState(message: l10n.loadingAyahs);
    }

    final isMemorized = state.memorizedAyahNumbers.contains(ayah.number);
    final isDifficult = state.difficultAyahNumbers.contains(ayah.number);
    final scheme = Theme.of(context).colorScheme;

    return AppScrollableBody(
      padding: EdgeInsets.symmetric(vertical: AppSpacing.md),
      footer: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SizedBox(height: AppSpacing.sm),
          AppButton(
            label: isMemorized ? l10n.memorizedDone : l10n.markMemorized,
            onPressed: cubit.toggleMemorized,
            icon: Icon(isMemorized
                ? Icons.check_circle_rounded
                : Icons.check_circle_outline),
          ),
          TextButton.icon(
            onPressed: cubit.toggleDifficult,
            icon: Icon(
              isDifficult ? Icons.flag_rounded : Icons.outlined_flag_rounded,
            ),
            label: Text(
              isDifficult ? l10n.markedDifficult : l10n.markDifficult,
            ),
          ),
        ],
      ),
      children: [
        AppSurfaceCard(
          child: Column(
            children: [
              Row(
                children: [
                  Expanded(
                    child: AppText(
                      '${l10n.ayah} ${ayah.number}/${state.ayahEnd}',
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                    ),
                  ),
                  AppText(
                    '${state.currentIndex + 1}/${state.ayahs.length}',
                    style: Theme.of(context).textTheme.labelLarge?.copyWith(
                          color: scheme.primary,
                          fontWeight: FontWeight.w700,
                        ),
                  ),
                ],
              ),
              SizedBox(height: AppSpacing.sm),
              LinearProgressIndicator(
                value: state.ayahs.isEmpty
                    ? 0
                    : (state.currentIndex + 1) / state.ayahs.length,
                borderRadius: BorderRadius.circular(4),
              ),
              SizedBox(height: AppSpacing.md),
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 250),
                child: state.showAyahText
                    ? QuranAyahText(
                        key: const ValueKey('visible'),
                        text: ayah.text,
                        fontScale: 1.1 * Responsive.ayahFontScale(context),
                      )
                    : GestureDetector(
                        key: const ValueKey('hidden'),
                        onTap: () =>
                            context.read<MemorizationCubit>().toggleShowText(),
                        child: Container(
                          width: double.infinity,
                          padding:
                              EdgeInsets.symmetric(vertical: AppSpacing.lg),
                          decoration: BoxDecoration(
                            color: scheme.surfaceContainerHighest
                                .withValues(alpha: 0.5),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Column(
                            children: [
                              Icon(
                                Icons.visibility_rounded,
                                color: scheme.onSurfaceVariant,
                              ),
                              SizedBox(height: AppSpacing.xs),
                              AppText(
                                l10n.tapToReveal,
                                style: Theme.of(context)
                                    .textTheme
                                    .bodyMedium
                                    ?.copyWith(
                                      color: scheme.onSurfaceVariant,
                                    ),
                              ),
                            ],
                          ),
                        ),
                      ),
              ),
            ],
          ),
        ),
        SizedBox(height: AppSpacing.sm),
        AppSurfaceCard(
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  IconButton(
                    onPressed: state.isFirstAyah ? null : cubit.previousAyah,
                    icon: const Icon(Icons.skip_previous_rounded),
                  ),
                  IconButton(
                    onPressed: cubit.togglePlay,
                    icon: Icon(
                      state.isPlaying
                          ? Icons.pause_circle_filled_rounded
                          : Icons.play_circle_fill_rounded,
                      size: 40,
                      color: scheme.primary,
                    ),
                  ),
                  IconButton(
                    onPressed: state.isLastAyah ? null : cubit.nextAyah,
                    icon: const Icon(Icons.skip_next_rounded),
                  ),
                ],
              ),
              SizedBox(height: AppSpacing.xs),
              Row(
                children: [
                  Expanded(
                    child: DropdownButtonFormField<double>(
                      initialValue: state.playbackSpeed,
                      isExpanded: true,
                      decoration: InputDecoration(
                        labelText: l10n.playbackSpeed,
                        border: const OutlineInputBorder(),
                        isDense: true,
                      ),
                      items: const [
                        DropdownMenuItem(value: 0.75, child: Text('0.75x')),
                        DropdownMenuItem(value: 1.0, child: Text('1x')),
                        DropdownMenuItem(value: 1.25, child: Text('1.25x')),
                      ],
                      onChanged: (v) {
                        if (v != null) cubit.setPlaybackSpeed(v);
                      },
                    ),
                  ),
                  SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: InputDecorator(
                      decoration: InputDecoration(
                        labelText: l10n.repeatAyah,
                        border: const OutlineInputBorder(),
                        isDense: true,
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                      ),
                      child: SegmentedButton<int>(
                        segments: const [
                          ButtonSegment(value: 1, label: Text('1')),
                          ButtonSegment(value: 3, label: Text('3')),
                          ButtonSegment(value: 5, label: Text('5')),
                        ],
                        selected: {state.repeatCount},
                        onSelectionChanged: (v) =>
                            cubit.setRepeatCount(v.first),
                        showSelectedIcon: false,
                        style: const ButtonStyle(
                          visualDensity: VisualDensity.compact,
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}
