import 'package:flutter/material.dart';
import 'package:werdi/core/theme/app_spacing.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:werdi/core/extensions/context_extensions.dart';
import 'package:werdi/core/widgets/app_status_chip.dart';
import 'package:werdi/core/widgets/app_button.dart';
import 'package:werdi/core/widgets/app_empty_state.dart';
import 'package:werdi/core/widgets/app_section_header.dart';
import 'package:werdi/core/widgets/app_surface_card.dart';
import 'package:werdi/core/widgets/app_text.dart';
import 'package:werdi/features/quran/domain/constants/tafsir_sources.dart';
import 'package:werdi/features/quran/domain/models/quran_translation_language.dart';
import 'package:werdi/features/quran/domain/models/surah_item.dart';
import 'package:werdi/features/quran/presentation/cubit/quran_cubit.dart';

class SurahTafsirLinksCard extends StatelessWidget {
  const SurahTafsirLinksCard({
    required this.surah,
    this.ayahNumber = 1,
    super.key,
  });

  final SurahItem surah;
  final int ayahNumber;

  @override
  Widget build(BuildContext context) {
    final verseUrl = context.read<QuranCubit>().getVerseWebUrl(
      surahNumber: surah.number,
      ayahNumber: ayahNumber,
    );
    final altafsirUrl =
        'https://www.altafsir.com/tafseer.asp?tMadhNo=1&tSoraNo=${surah.number}&tAyahNo=$ayahNumber&tDisplay=yes&LanguageId=1';

    return AppSurfaceCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AppSectionHeader(title: context.l10n.tafsirLinks),
          const SizedBox(height: AppSpacing.xxs),
          _TafsirLinkRow(
            icon: Icons.language_rounded,
            title: 'Quran.com',
            subtitle: context.l10n.tafsirWithTranslation,
            onTap: () => launchUrl(
              Uri.parse(verseUrl),
              mode: LaunchMode.externalApplication,
            ),
          ),
          _TafsirLinkRow(
            icon: Icons.open_in_new_rounded,
            title: 'Altafsir.com',
            subtitle: context.l10n.classicTafsirLibrary,
            onTap: () => launchUrl(
              Uri.parse(altafsirUrl),
              mode: LaunchMode.externalApplication,
            ),
          ),
        ],
      ),
    );
  }
}

class _TafsirLinkRow extends StatelessWidget {
  const _TafsirLinkRow({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: AppSpacing.xs),
        child: Row(
          children: [
            Icon(icon, color: scheme.primary),
            const SizedBox(width: AppSpacing.sm),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  AppText(title, style: Theme.of(context).textTheme.titleSmall),
                  AppText(
                    subtitle,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: scheme.onSurfaceVariant,
                        ),
                  ),
                ],
              ),
            ),
            Icon(Icons.open_in_new_rounded, size: 18, color: scheme.onSurfaceVariant),
          ],
        ),
      ),
    );
  }
}

class SurahTafsirPreviewCard extends StatefulWidget {
  const SurahTafsirPreviewCard({required this.surah, super.key});

  final SurahItem surah;

  @override
  State<SurahTafsirPreviewCard> createState() => _SurahTafsirPreviewCardState();
}

class _SurahTafsirPreviewCardState extends State<SurahTafsirPreviewCard> {
  int _tabIndex = 0;
  int _startAyah = 1;
  int _endAyah = 5;
  bool _autoLoaded = false;

  @override
  void initState() {
    super.initState();
    _resetRangeForSurah(widget.surah);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _tryAutoLoad();
      _refreshOfflineStatus();
    });
  }

  @override
  void didUpdateWidget(covariant SurahTafsirPreviewCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.surah.number != widget.surah.number) {
      _resetRangeForSurah(widget.surah);
      _autoLoaded = false;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _tryAutoLoad();
        _refreshOfflineStatus();
      });
    }
  }

  void _refreshOfflineStatus() {
    if (!mounted) return;
    context.read<QuranCubit>().refreshSurahTafsirOfflineStatus(
          surahNumber: widget.surah.number,
          verseCount: widget.surah.verseCount,
        );
  }

  void _resetRangeForSurah(SurahItem surah) {
    _startAyah = 1;
    _endAyah = surah.verseCount > 5 ? 5 : surah.verseCount;
  }

  void _tryAutoLoad() {
    if (!mounted || _autoLoaded) return;
    final cubit = context.read<QuranCubit>();
    final quranState = cubit.state;
    if (quranState.selectedTafsirSource.isEmpty) return;
    _autoLoaded = true;
    if (_tabIndex == 0) {
      cubit.loadTafsir(
        surahNumber: widget.surah.number,
        ayahStart: _startAyah,
        ayahEnd: _endAyah,
      );
    } else {
      cubit.loadTranslations(
        surahNumber: widget.surah.number,
        ayahStart: _startAyah,
        ayahEnd: _endAyah,
      );
    }
  }

  void _reloadActiveTab() {
    final cubit = context.read<QuranCubit>();
    if (_tabIndex == 0) {
      cubit.loadTafsir(
        surahNumber: widget.surah.number,
        ayahStart: _startAyah,
        ayahEnd: _endAyah,
      );
    } else {
      cubit.loadTranslations(
        surahNumber: widget.surah.number,
        ayahStart: _startAyah,
        ayahEnd: _endAyah,
      );
    }
  }

  Future<void> _downloadOfflineTafsir() async {
    final cubit = context.read<QuranCubit>();
    final selected = cubit.state.selectedTafsirSource;
    if (selected.isEmpty) return;
    final completed = await cubit.downloadTafsirOfflineForSurah(
      surahNumber: widget.surah.number,
      verseCount: widget.surah.verseCount,
      source: selected,
    );
    if (!mounted) return;
    final messenger = ScaffoldMessenger.of(context);
    if (completed) {
      messenger.showSnackBar(
        SnackBar(content: Text(context.l10n.tafsirOfflineReady)),
      );
      return;
    }
    if (!cubit.state.isDownloadingTafsirOffline) {
      messenger.showSnackBar(
        SnackBar(content: Text(context.l10n.tafsirDownloadCancelled)),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final quranState = context.watch<QuranCubit>().state;
    final cubit = context.read<QuranCubit>();
    final l10n = context.l10n;
    final selected = quranState.selectedTafsirSource;
    final sources = quranState.tafsirSources;
    final ayahOptions =
        List<int>.generate(widget.surah.verseCount, (i) => i + 1);
    final tafsir = quranState.currentTafsir;
    final tafsirMatchesSurah =
        tafsir == null || tafsir.surahNumber == widget.surah.number;
    final tafsirSourceValue = selected.isEmpty
        ? (sources.isEmpty ? null : sources.first)
        : (sources.contains(selected) ? selected : sources.firstOrNull);
    final isTafsirOfflineReady = quranState.isSurahTafsirOfflineReady(
      surahNumber: widget.surah.number,
      source: selected,
    );

    if (!_autoLoaded &&
        selected.isNotEmpty &&
        quranState.tafsirSources.isNotEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _tryAutoLoad());
    }

    return AppSurfaceCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AppSectionHeader(title: l10n.tafsirAndTranslation),
          if (_tabIndex == 0 && isTafsirOfflineReady) ...[
            const SizedBox(height: AppSpacing.xs),
            AppStatusChip(
              label: l10n.tafsirOfflineCachedBadge,
              foreground: Theme.of(context).colorScheme.primary,
              background: Theme.of(context).colorScheme.primaryContainer,
            ),
          ],
          const SizedBox(height: AppSpacing.xs),
          SegmentedButton<int>(
            segments: [
              ButtonSegment(value: 0, label: Text(l10n.tafsir)),
              ButtonSegment(value: 1, label: Text(l10n.translation)),
            ],
            selected: {_tabIndex},
            onSelectionChanged: (v) {
              setState(() => _tabIndex = v.first);
              _reloadActiveTab();
            },
          ),
          const SizedBox(height: AppSpacing.xs),
          if (_tabIndex == 0)
            DropdownButtonFormField<String>(
              key: ValueKey('tafsir_source_$tafsirSourceValue'),
              initialValue: tafsirSourceValue,
              isExpanded: true,
              items: sources
                  .map(
                    (s) => DropdownMenuItem(
                      value: s,
                      child: Text(
                        TafsirSources.labelFor(s),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  )
                  .toList(),
              onChanged: (v) {
                if (v == null) return;
                cubit.loadTafsir(
                  surahNumber: widget.surah.number,
                  ayahStart: _startAyah,
                  ayahEnd: _endAyah,
                  source: v,
                );
                _refreshOfflineStatus();
              },
              decoration: InputDecoration(
                labelText: l10n.tafsirSourceLabel,
                prefixIcon: const Icon(Icons.auto_stories_rounded),
              ),
            ),
          const SizedBox(height: AppSpacing.sm),
          Row(
            children: [
              Expanded(
                child: DropdownButtonFormField<int>(
                  key: ValueKey('tafsir_start_$_startAyah'),
                  initialValue: _startAyah,
                  isExpanded: true,
                  items: ayahOptions
                      .map((n) => DropdownMenuItem(
                            value: n,
                            child: Text(l10n.fromN(n)),
                          ))
                      .toList(),
                  onChanged: (v) {
                    if (v == null) return;
                    setState(() {
                      _startAyah = v;
                      if (_endAyah < _startAyah) _endAyah = _startAyah;
                    });
                    _reloadActiveTab();
                  },
                  decoration: InputDecoration(labelText: l10n.rangeStart),
                ),
              ),
              const SizedBox(width: AppSpacing.xs),
              Expanded(
                child: DropdownButtonFormField<int>(
                  key: ValueKey('tafsir_end_${_startAyah}_$_endAyah'),
                  initialValue: _endAyah,
                  isExpanded: true,
                  items: ayahOptions
                      .where((n) => n >= _startAyah)
                      .map((n) => DropdownMenuItem(
                            value: n,
                            child: Text(l10n.toN(n)),
                          ))
                      .toList(),
                  onChanged: (v) {
                    if (v == null) return;
                    setState(() => _endAyah = v);
                    _reloadActiveTab();
                  },
                  decoration: InputDecoration(labelText: l10n.rangeEnd),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.xs),
          if (_tabIndex == 0) ...[
            if (quranState.isLoadingTafsir)
              const Center(child: CircularProgressIndicator())
            else if (!tafsirMatchesSurah || tafsir == null)
              AppEmptyState(
                title: l10n.noTafsir,
                subtitle: l10n.noTafsirSubtitle,
                icon: Icons.menu_book_rounded,
              )
            else ...[
              if (tafsir.isOfflineFallback)
                Padding(
                  padding: const EdgeInsets.only(bottom: AppSpacing.xs),
                  child: Material(
                    color: Theme.of(context)
                        .colorScheme
                        .errorContainer
                        .withValues(alpha: 0.5),
                    borderRadius: BorderRadius.circular(12),
                    child: Padding(
                      padding: const EdgeInsets.all(AppSpacing.sm),
                      child: Row(
                        children: [
                          Icon(
                            Icons.wifi_off_rounded,
                            size: 18,
                            color: Theme.of(context).colorScheme.error,
                          ),
                          const SizedBox(width: AppSpacing.xs),
                          Expanded(
                            child: AppText(
                              l10n.tafsirOfflineFallback,
                              style: Theme.of(context).textTheme.bodySmall,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              AppSurfaceCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    AppText(
                      '${tafsir.source} • ${tafsir.ayahStart}-${tafsir.ayahEnd}',
                      style: Theme.of(context).textTheme.titleSmall,
                    ),
                    const SizedBox(height: AppSpacing.xxs),
                    AppText(tafsir.text),
                  ],
                ),
              ),
            ],
          ] else ...[
            if (quranState.isLoadingTranslations)
              const Center(child: CircularProgressIndicator())
            else if (quranState.translationLines.isEmpty)
              AppEmptyState(
                title: l10n.noTranslation,
                subtitle: l10n.noTranslationSubtitle,
                icon: Icons.translate_rounded,
              )
            else
              AppSurfaceCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: quranState.translationLines
                      .asMap()
                      .entries
                      .map(
                        (e) => Padding(
                          padding: const EdgeInsets.only(bottom: AppSpacing.xxs),
                          child: AppText(
                            l10n.translationLine(_startAyah + e.key, e.value),
                          ),
                        ),
                      )
                      .toList(),
                ),
              ),
            const SizedBox(height: AppSpacing.xs),
            DropdownButtonFormField<QuranTranslationLanguage>(
              key: ValueKey(
                'translation_${quranState.selectedTranslationLanguage.name}',
              ),
              initialValue: quranState.selectedTranslationLanguage,
              items: quranState.translationLanguages
                  .map(
                    (lang) => DropdownMenuItem<QuranTranslationLanguage>(
                      value: lang,
                      child: Text(lang.label),
                    ),
                  )
                  .toList(),
              onChanged: (v) {
                if (v == null) return;
                cubit.loadTranslations(
                  surahNumber: widget.surah.number,
                  ayahStart: _startAyah,
                  ayahEnd: _endAyah,
                  language: v,
                );
              },
              decoration: InputDecoration(
                labelText: l10n.translationLanguage,
                prefixIcon: const Icon(Icons.translate_rounded),
              ),
            ),
          ],
          const SizedBox(height: AppSpacing.xs),
          if (_tabIndex == 0) ...[
            if (!isTafsirOfflineReady)
              AppButton(
                label: l10n.downloadTafsirOffline,
                onPressed: quranState.isDownloadingTafsirOffline
                    ? null
                    : _downloadOfflineTafsir,
                variant: AppButtonVariant.outlined,
                icon: quranState.isDownloadingTafsirOffline
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.download_rounded),
              ),
            if (quranState.isDownloadingTafsirOffline) ...[
              const SizedBox(height: AppSpacing.xs),
              AppText(
                l10n.downloadingTafsirProgress(
                  quranState.tafsirDownloadCurrentAyah,
                  quranState.tafsirDownloadTotalAyahs,
                ),
                style: Theme.of(context).textTheme.bodySmall,
              ),
              const SizedBox(height: AppSpacing.xs),
              AppButton(
                label: l10n.cancelTafsirDownload,
                onPressed: () => cubit.cancelTafsirOfflineDownload(),
                variant: AppButtonVariant.outlined,
                icon: const Icon(Icons.close_rounded),
              ),
            ],
            const SizedBox(height: AppSpacing.xs),
          ],
          AppButton(
            label:
                _tabIndex == 0 ? l10n.refreshTafsir : l10n.refreshTranslation,
            onPressed: _reloadActiveTab,
            variant: AppButtonVariant.outlined,
            icon: const Icon(Icons.refresh_rounded),
          ),
        ],
      ),
    );
  }
}
