import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:werdi/core/extensions/context_extensions.dart';
import 'package:werdi/core/widgets/app_button.dart';
import 'package:werdi/core/widgets/app_empty_state.dart';
import 'package:werdi/core/widgets/app_section_header.dart';
import 'package:werdi/core/widgets/app_surface_card.dart';
import 'package:werdi/core/widgets/app_text.dart';
import 'package:werdi/features/quran/domain/models/quran_translation_language.dart';
import 'package:werdi/features/quran/domain/models/surah_item.dart';
import 'package:werdi/features/quran/presentation/cubit/quran_cubit.dart';

class SurahTafsirLinksCard extends StatelessWidget {
  const SurahTafsirLinksCard({required this.surah, super.key});

  final SurahItem surah;

  @override
  Widget build(BuildContext context) {
    final verseUrl = context.read<QuranCubit>().getVerseWebUrl(
      surahNumber: surah.number,
      ayahNumber: 1,
    );
    return AppSurfaceCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AppSectionHeader(title: context.l10n.tafsirLinks),
          SizedBox(height: 6.h),
          ListTile(
            contentPadding: EdgeInsets.zero,
            leading: const Icon(Icons.language_rounded),
            title: const AppText('Quran.com'),
            subtitle: AppText(context.l10n.tafsirWithTranslation),
            onTap: () => launchUrl(
              Uri.parse(verseUrl),
              mode: LaunchMode.externalApplication,
            ),
          ),
          ListTile(
            contentPadding: EdgeInsets.zero,
            leading: const Icon(Icons.open_in_new_rounded),
            title: const AppText('Altafsir.com'),
            subtitle: AppText(context.l10n.classicTafsirLibrary),
            onTap: () => launchUrl(
              Uri.parse('https://www.altafsir.com'),
              mode: LaunchMode.externalApplication,
            ),
          ),
        ],
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
  static const Map<String, String> _tafsirSourceLabels = {
    'ar.waseet': 'التفسير الوسيط (مصر)',
    'ar.muyassar': 'التفسير الميسر',
    'ar.jalalayn': 'تفسير الجلالين',
    'ar.qurtubi': 'تفسير القرطبي',
    'ar.miqbas': 'تنوير المقباس',
    'ar.baghawi': 'تفسير البغوي',
  };

  @override
  void initState() {
    super.initState();
    _endAyah = widget.surah.verseCount > 5 ? 5 : widget.surah.verseCount;
  }

  @override
  Widget build(BuildContext context) {
    final quranState = context.watch<QuranCubit>().state;
    final cubit = context.read<QuranCubit>();
    final l10n = context.l10n;
    final selected = quranState.selectedTafsirSource;
    final sources = quranState.tafsirSources;
    final maxSelectable =
        widget.surah.verseCount > 20 ? 20 : widget.surah.verseCount;
    final ayahOptions = List<int>.generate(maxSelectable, (i) => i + 1);

    return AppSurfaceCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AppSectionHeader(title: l10n.tafsirAndTranslation),
          SizedBox(height: 8.h),
          SegmentedButton<int>(
            segments: [
              ButtonSegment(value: 0, label: Text(l10n.tafsir)),
              ButtonSegment(value: 1, label: Text(l10n.translation)),
            ],
            selected: {_tabIndex},
            onSelectionChanged: (v) => setState(() => _tabIndex = v.first),
          ),
          SizedBox(height: 8.h),
          if (_tabIndex == 0)
            DropdownButtonFormField<String>(
              initialValue: selected.isEmpty
                  ? (sources.isEmpty ? null : sources.first)
                  : selected,
              items: sources
                  .map(
                    (s) => DropdownMenuItem(
                      value: s,
                      child: Text(_tafsirSourceLabels[s] ?? s),
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
              },
              decoration: InputDecoration(
                labelText: l10n.tafsirSourceLabel,
                prefixIcon: const Icon(Icons.auto_stories_rounded),
              ),
            ),
          SizedBox(height: 10.h),
          Row(
            children: [
              Expanded(
                child: DropdownButtonFormField<int>(
                  initialValue: _startAyah,
                  items: ayahOptions
                      .map((n) =>
                          DropdownMenuItem(value: n, child: Text(l10n.fromN(n))))
                      .toList(),
                  onChanged: (v) {
                    if (v == null) return;
                    setState(() {
                      _startAyah = v;
                      if (_endAyah < _startAyah) _endAyah = _startAyah;
                    });
                  },
                  decoration: InputDecoration(labelText: l10n.rangeStart),
                ),
              ),
              SizedBox(width: 8.w),
              Expanded(
                child: DropdownButtonFormField<int>(
                  initialValue: _endAyah,
                  items: ayahOptions
                      .where((n) => n >= _startAyah)
                      .map((n) =>
                          DropdownMenuItem(value: n, child: Text(l10n.toN(n))))
                      .toList(),
                  onChanged: (v) {
                    if (v == null) return;
                    setState(() => _endAyah = v);
                  },
                  decoration: InputDecoration(labelText: l10n.rangeEnd),
                ),
              ),
            ],
          ),
          SizedBox(height: 8.h),
          if (_tabIndex == 0) ...[
            if (quranState.isLoadingTafsir)
              const Center(child: CircularProgressIndicator())
            else if (quranState.currentTafsir == null)
              AppEmptyState(
                title: l10n.noTafsir,
                subtitle: l10n.noTafsirSubtitle,
                icon: Icons.menu_book_rounded,
              )
            else
              AppSurfaceCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    AppText(
                      '${quranState.currentTafsir!.source} • ${quranState.currentTafsir!.ayahStart}-${quranState.currentTafsir!.ayahEnd}',
                      style: Theme.of(context).textTheme.titleSmall,
                    ),
                    SizedBox(height: 6.h),
                    AppText(quranState.currentTafsir!.text),
                  ],
                ),
              ),
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
                          padding: EdgeInsets.only(bottom: 6.h),
                          child: AppText(
                            l10n.translationLine(_startAyah + e.key, e.value),
                          ),
                        ),
                      )
                      .toList(),
                ),
              ),
            SizedBox(height: 8.h),
            DropdownButtonFormField<QuranTranslationLanguage>(
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
          SizedBox(height: 8.h),
          AppButton(
            label: _tabIndex == 0 ? l10n.refreshTafsir : l10n.refreshTranslation,
            onPressed: () async {
              if (_tabIndex == 0) {
                await cubit.loadTafsir(
                  surahNumber: widget.surah.number,
                  ayahStart: _startAyah,
                  ayahEnd: _endAyah,
                );
              } else {
                await cubit.loadTranslations(
                  surahNumber: widget.surah.number,
                  ayahStart: _startAyah,
                  ayahEnd: _endAyah,
                );
              }
            },
            variant: AppButtonVariant.outlined,
            icon: const Icon(Icons.refresh_rounded),
          ),
        ],
      ),
    );
  }
}
