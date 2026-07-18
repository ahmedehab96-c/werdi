import 'package:flutter/material.dart';
import 'package:werdi/core/theme/app_spacing.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:werdi/core/extensions/context_extensions.dart';
import 'package:werdi/core/widgets/app_empty_state.dart';
import 'package:werdi/core/widgets/app_section_header.dart';
import 'package:werdi/core/widgets/app_scaffold.dart';
import 'package:werdi/core/widgets/app_surface_card.dart';
import 'package:werdi/core/widgets/app_text.dart';
import 'package:werdi/core/widgets/arabic_search_highlight_text.dart';
import 'package:werdi/features/quran/presentation/cubit/quran_cubit.dart';
import 'package:werdi/features/quran/presentation/cubit/quran_state.dart';
import 'package:werdi/features/quran/presentation/pages/surah_details_page.dart';

class QuranSearchPage extends StatelessWidget {
  const QuranSearchPage({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final scheme = Theme.of(context).colorScheme;
    return AppScaffold(
      appBar: AppBar(title: Text(l10n.searchQuranTitle)),
      body: BlocBuilder<QuranCubit, QuranState>(
        builder: (context, state) {
          final cubit = context.read<QuranCubit>();
          return ListView(
            padding: const EdgeInsets.all(AppSpacing.md),
            children: [
              TextField(
                autofocus: true,
                onChanged: cubit.setSearchQuery,
                onSubmitted: cubit.addRecentSearch,
                decoration: InputDecoration(
                  hintText: l10n.searchQuranHint,
                  prefixIcon: const Icon(Icons.search_rounded),
                  suffixIcon: state.searchQuery.isNotEmpty
                      ? IconButton(
                          onPressed: () => cubit.setSearchQuery(''),
                          icon: const Icon(Icons.close_rounded),
                        )
                      : null,
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              if (state.searchQuery.trim().isEmpty) ...[
                AppSectionHeader(title: l10n.recentSearches),
                const SizedBox(height: AppSpacing.xs),
                if (state.recentSearches.isEmpty)
                  AppEmptyState(
                    title: l10n.noSearchHistory,
                    subtitle: l10n.noSearchHistorySubtitle,
                    icon: Icons.search_off_rounded,
                  )
                else
                  Wrap(
                    spacing: AppSpacing.xs,
                    runSpacing: AppSpacing.xs,
                    children: state.recentSearches
                        .map(
                          (item) => ActionChip(
                            label: Text(item),
                            onPressed: () {
                              cubit.setSearchQuery(item);
                              cubit.addRecentSearch(item);
                            },
                          ),
                        )
                        .toList(),
                  ),
              ] else ...[
                AppSectionHeader(title: l10n.ayahResults),
                const SizedBox(height: AppSpacing.xs),
                if (state.ayahSearchHits.isEmpty)
                  AppEmptyState(
                    title: l10n.noAyahResults,
                    subtitle: l10n.noAyahResultsSubtitle,
                    icon: Icons.menu_book_rounded,
                  )
                else
                  ...state.ayahSearchHits.take(20).map(
                        (hit) => Padding(
                          padding: const EdgeInsets.only(bottom: AppSpacing.xs),
                          child: AppSurfaceCard(
                            onTap: () {
                              final surah =
                                  state.surahByNumber(hit.surahNumber);
                              if (surah == null) return;
                              Navigator.of(context).push(
                                MaterialPageRoute<void>(
                                  builder: (_) => BlocProvider.value(
                                    value: context.read<QuranCubit>(),
                                    child: SurahDetailsPage(
                                      surah: surah,
                                      initialAyahNumber: hit.ayahNumber,
                                      initialSearchQuery: state.searchQuery,
                                      centerInitialAyah: true,
                                      startInFocusMode:
                                          state.openSearchResultsInFocusMode,
                                    ),
                                  ),
                                ),
                              );
                            },
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                AppText(
                                  '${hit.surahNameArabic} • ${l10n.ayahNumbered(hit.ayahNumber)}',
                                ),
                                const SizedBox(height: AppSpacing.xxs),
                                ArabicSearchHighlightText(
                                  text: hit.text,
                                  query: state.searchQuery,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                const SizedBox(height: AppSpacing.sm),
                AppSectionHeader(title: l10n.surahResults),
                const SizedBox(height: AppSpacing.xs),
                if (state.searchSurahResults.isEmpty)
                  AppEmptyState(
                    title: l10n.noMatchingResults,
                    subtitle: l10n.noResultsSubtitle,
                    icon: Icons.filter_alt_off_rounded,
                  )
                else
                  ...state.searchSurahResults.take(12).map(
                        (surah) => Padding(
                          padding: const EdgeInsets.only(bottom: AppSpacing.xs),
                          child: AppSurfaceCard(
                            child: Row(
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      AppText(surah.nameArabic),
                                      AppText(
                                        '${surah.nameEnglish} • ${l10n.ayahUnit(surah.verseCount)}',
                                        style: Theme.of(context)
                                            .textTheme
                                            .bodySmall,
                                      ),
                                    ],
                                  ),
                                ),
                                Icon(
                                  Directionality.of(context) ==
                                          TextDirection.rtl
                                      ? Icons.chevron_left_rounded
                                      : Icons.chevron_right_rounded,
                                  size: 18,
                                  color: scheme.onSurfaceVariant,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                const SizedBox(height: AppSpacing.sm),
                AppSectionHeader(title: l10n.juzResults),
                const SizedBox(height: AppSpacing.xs),
                if (state.searchJuzResults.isEmpty)
                  AppEmptyState(
                    title: l10n.noJuzResults,
                    subtitle: l10n.noJuzResultsSubtitle,
                    icon: Icons.filter_alt_off_rounded,
                  )
                else
                  ...state.searchJuzResults.take(8).map(
                        (juz) => Padding(
                          padding: const EdgeInsets.only(bottom: AppSpacing.xs),
                          child: AppSurfaceCard(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                AppText(l10n.juzNumber(juz.number)),
                                AppText(
                                  juz.surahRangeText,
                                  style: Theme.of(context).textTheme.bodySmall,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                const SizedBox(height: AppSpacing.sm),
                AppSurfaceCard(
                  child: Row(
                    children: [
                      Icon(Icons.api_rounded, color: scheme.primary),
                      const SizedBox(width: AppSpacing.sm),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            AppText(l10n.searchApiReady),
                            AppText(
                              l10n.searchApiReadySubtitle,
                              style: Theme.of(context).textTheme.bodySmall,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          );
        },
      ),
    );
  }
}
