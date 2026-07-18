import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:quran/quran.dart' as quran_pkg;
import 'package:werdi/core/di/app_injector.dart';
import 'package:werdi/core/extensions/context_extensions.dart';
import 'package:werdi/core/theme/app_spacing.dart';
import 'package:werdi/core/widgets/app_animated_progress.dart';
import 'package:werdi/core/widgets/app_scaffold.dart';
import 'package:werdi/core/widgets/app_surface_card.dart';
import 'package:werdi/core/widgets/app_text.dart';
import 'package:werdi/features/quran/domain/models/quran_audio_reciter.dart';
import 'package:werdi/features/quran/presentation/cubit/offline_recitations_cubit.dart';
import 'package:werdi/features/quran/presentation/cubit/offline_recitations_state.dart';

class OfflineRecitationsPage extends StatelessWidget {
  const OfflineRecitationsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => OfflineRecitationsCubit(
        downloadService: AppInjector.recitationDownloadService,
        storage: AppInjector.recitationOfflineStorage,
      )..load(),
      child: const _OfflineRecitationsView(),
    );
  }
}

class _OfflineRecitationsView extends StatelessWidget {
  const _OfflineRecitationsView();

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return AppScaffold(
      appBar: AppBar(title: Text(l10n.offlineRecitationsTitle)),
      body: BlocBuilder<OfflineRecitationsCubit, OfflineRecitationsState>(
        builder: (context, state) {
          final cubit = context.read<OfflineRecitationsCubit>();
          final reciter = state.selectedReciter;
          final verseCount = quran_pkg.getVerseCount(state.selectedSurahNumber);
          final progress = state.progress;
          final progressFraction = progress?.fraction ?? 0;

          return ListView(
            padding: EdgeInsets.all(AppSpacing.md),
            children: [
              AppText(
                l10n.offlineRecitationsSubtitle,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              SizedBox(height: AppSpacing.md),
              AppSurfaceCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    AppText(
                      l10n.selectReciter,
                      style: Theme.of(context).textTheme.titleSmall,
                    ),
                    SizedBox(height: AppSpacing.xs),
                    DropdownButtonFormField<QuranAudioReciter>(
                      key: ValueKey(reciter?.persistenceKey),
                      initialValue: reciter,
                      isExpanded: true,
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                        isDense: true,
                      ),
                      items: [
                        for (final item in state.reciters)
                          DropdownMenuItem(
                            value: item,
                            child: Text(
                              item.name,
                              overflow: TextOverflow.ellipsis,
                              maxLines: 1,
                            ),
                          ),
                      ],
                      onChanged: state.isDownloading
                          ? null
                          : (value) {
                              if (value == null) return;
                              cubit.selectReciter(value);
                            },
                    ),
                    SizedBox(height: AppSpacing.md),
                    AppText(
                      l10n.selectSurah,
                      style: Theme.of(context).textTheme.titleSmall,
                    ),
                    SizedBox(height: AppSpacing.xs),
                    DropdownButtonFormField<int>(
                      key: ValueKey(state.selectedSurahNumber),
                      initialValue: state.selectedSurahNumber,
                      isExpanded: true,
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                        isDense: true,
                      ),
                      items: [
                        for (var n = 1; n <= 114; n++)
                          DropdownMenuItem(
                            value: n,
                            child: Text(
                              '$n — ${quran_pkg.getSurahNameArabic(n)}',
                              overflow: TextOverflow.ellipsis,
                              maxLines: 1,
                            ),
                          ),
                      ],
                      onChanged: state.isDownloading
                          ? null
                          : (value) {
                              if (value == null) return;
                              cubit.selectSurah(value);
                            },
                    ),
                    SizedBox(height: AppSpacing.md),
                    _DownloadStatusChip(status: state.downloadStatus),
                    if (state.isDownloading && progress != null) ...[
                      SizedBox(height: AppSpacing.md),
                      AppText(
                        l10n.downloadingAyah(
                          progress.currentAyah,
                          verseCount,
                        ),
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                      SizedBox(height: AppSpacing.xs),
                      AppAnimatedProgress(value: progressFraction),
                      SizedBox(height: AppSpacing.xs),
                      AppText(
                        '${(progressFraction * 100).round()}%',
                        style: Theme.of(context).textTheme.labelSmall,
                        textAlign: TextAlign.center,
                      ),
                    ],
                    if (state.errorMessage != null) ...[
                      SizedBox(height: AppSpacing.sm),
                      AppText(
                        l10n.surahDownloadFailed,
                        style: Theme.of(context)
                            .textTheme
                            .bodySmall
                            ?.copyWith(color: Theme.of(context).colorScheme.error),
                      ),
                    ],
                  ],
                ),
              ),
              SizedBox(height: AppSpacing.md),
              FilledButton.icon(
                onPressed: state.isDownloading || reciter == null
                    ? null
                    : cubit.downloadSelectedSurah,
                icon: const Icon(Icons.download_rounded),
                label: Text(l10n.downloadSurah),
              ),
              SizedBox(height: AppSpacing.sm),
              OutlinedButton.icon(
                onPressed: state.isDownloading ||
                        reciter == null ||
                        state.downloadStatus != SurahDownloadStatus.downloaded
                    ? null
                    : cubit.deleteSelectedSurah,
                icon: const Icon(Icons.delete_outline_rounded),
                label: Text(l10n.deleteDownloadedSurah),
              ),
              SizedBox(height: AppSpacing.md),
              AppText(
                l10n.offlineRecitationsHint,
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ],
          );
        },
      ),
    );
  }
}

class _DownloadStatusChip extends StatelessWidget {
  const _DownloadStatusChip({required this.status});

  final SurahDownloadStatus status;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final colors = Theme.of(context).colorScheme;

    late final String label;
    late final IconData icon;
    late final Color background;
    late final Color foreground;

    switch (status) {
      case SurahDownloadStatus.downloaded:
        label = l10n.surahDownloadComplete;
        icon = Icons.offline_pin_rounded;
        background = colors.primaryContainer;
        foreground = colors.onPrimaryContainer;
      case SurahDownloadStatus.notDownloaded:
        label = l10n.surahNotDownloaded;
        icon = Icons.cloud_download_outlined;
        background = colors.surfaceContainerHighest;
        foreground = colors.onSurfaceVariant;
      case SurahDownloadStatus.unknown:
        label = '…';
        icon = Icons.hourglass_empty_rounded;
        background = colors.surfaceContainerHighest;
        foreground = colors.onSurfaceVariant;
    }

    return Align(
      alignment: AlignmentDirectional.centerStart,
      child: Chip(
        avatar: Icon(icon, size: 18, color: foreground),
        label: Text(label),
        backgroundColor: background,
        labelStyle: TextStyle(color: foreground, fontWeight: FontWeight.w600),
      ),
    );
  }
}
