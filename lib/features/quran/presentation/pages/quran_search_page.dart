import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:werdi/core/utils/arabic_text_normalizer.dart';
import 'package:werdi/core/extensions/context_extensions.dart';
import 'package:werdi/core/widgets/app_empty_state.dart';
import 'package:werdi/core/widgets/app_section_header.dart';
import 'package:werdi/core/widgets/app_scaffold.dart';
import 'package:werdi/core/widgets/app_surface_card.dart';
import 'package:werdi/core/widgets/app_text.dart';
import 'package:werdi/features/quran/presentation/cubit/quran_cubit.dart';
import 'package:werdi/features/quran/presentation/cubit/quran_state.dart';
import 'package:werdi/features/quran/presentation/pages/surah_details_page.dart';

class QuranSearchPage extends StatelessWidget {
  const QuranSearchPage({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return AppScaffold(
      appBar: AppBar(title: Text(l10n.searchQuranTitle)),
      body: BlocBuilder<QuranCubit, QuranState>(
        builder: (context, state) {
          final cubit = context.read<QuranCubit>();
          return ListView(
            padding: EdgeInsets.all(16.w),
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
              SizedBox(height: 16.h),
              if (state.searchQuery.trim().isEmpty) ...[
                AppSectionHeader(title: l10n.recentSearches),
                SizedBox(height: 8.h),
                if (state.recentSearches.isEmpty)
                  AppEmptyState(
                    title: l10n.noSearchHistory,
                    subtitle: l10n.noSearchHistorySubtitle,
                    icon: Icons.search_off_rounded,
                  )
                else
                  Wrap(
                    spacing: 8.w,
                    runSpacing: 8.h,
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
                SizedBox(height: 8.h),
                if (state.ayahSearchHits.isEmpty)
                  AppEmptyState(
                    title: l10n.noAyahResults,
                    subtitle: l10n.noAyahResultsSubtitle,
                    icon: Icons.menu_book_rounded,
                  )
                else
                  ...state.ayahSearchHits.take(20).map(
                        (hit) => AppSurfaceCard(
                          child: ListTile(
                            contentPadding: EdgeInsets.zero,
                            title: AppText(
                              '${hit.surahNameArabic} • ${l10n.ayahNumbered(hit.ayahNumber)}',
                            ),
                            subtitle: _HighlightedAyahText(
                              text: hit.text,
                              query: state.searchQuery,
                            ),
                            onTap: () {
                              final surah = state.surahByNumber(hit.surahNumber);
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
                          ),
                        ),
                      ),
                SizedBox(height: 14.h),
                AppSectionHeader(title: l10n.surahResults),
                SizedBox(height: 8.h),
                if (state.searchSurahResults.isEmpty)
                  AppEmptyState(
                    title: l10n.noMatchingResults,
                    subtitle: l10n.noResultsSubtitle,
                    icon: Icons.filter_alt_off_rounded,
                  )
                else
                  ...state.searchSurahResults
                      .take(12)
                      .map(
                        (surah) => AppSurfaceCard(
                          child: ListTile(
                            contentPadding: EdgeInsets.zero,
                            title: AppText(surah.nameArabic),
                            subtitle: AppText(
                              '${surah.nameEnglish} • ${l10n.ayahUnit(surah.verseCount)}',
                            ),
                            trailing: Icon(
                              Directionality.of(context) == TextDirection.rtl
                                  ? Icons.chevron_left_rounded
                                  : Icons.chevron_right_rounded,
                              size: 18,
                            ),
                          ),
                        ),
                      ),
                SizedBox(height: 14.h),
                AppSectionHeader(title: l10n.juzResults),
                SizedBox(height: 8.h),
                if (state.searchJuzResults.isEmpty)
                  AppEmptyState(
                    title: l10n.noJuzResults,
                    subtitle: l10n.noJuzResultsSubtitle,
                    icon: Icons.filter_alt_off_rounded,
                  )
                else
                  ...state.searchJuzResults
                      .take(8)
                      .map(
                        (juz) => AppSurfaceCard(
                          child: ListTile(
                            contentPadding: EdgeInsets.zero,
                            title: AppText(l10n.juzNumber(juz.number)),
                            subtitle: AppText(juz.surahRangeText),
                          ),
                        ),
                      ),
                SizedBox(height: 12.h),
                AppSurfaceCard(
                  child: ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: const Icon(Icons.api_rounded),
                    title: AppText(l10n.searchApiReady),
                    subtitle: AppText(l10n.searchApiReadySubtitle),
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

class _HighlightedAyahText extends StatelessWidget {
  const _HighlightedAyahText({
    required this.text,
    required this.query,
  });

  final String text;
  final String query;

  @override
  Widget build(BuildContext context) {
    final trimmedQuery = query.trim();
    if (trimmedQuery.isEmpty) {
      return AppText(text);
    }

    final normalizedQuery = ArabicTextNormalizer.normalize(trimmedQuery);
    if (normalizedQuery.isEmpty) {
      return AppText(text);
    }

    final style = Theme.of(context).textTheme.bodyMedium;
    final highlightStyle = style?.copyWith(
      color: Theme.of(context).colorScheme.primary,
      fontWeight: FontWeight.w700,
    );

    final words = text.split(RegExp(r'\s+'));
    final spans = <InlineSpan>[];
    for (var i = 0; i < words.length; i++) {
      final token = words[i];
      final normalizedToken = ArabicTextNormalizer.normalize(token);
      final isMatch = normalizedToken.contains(normalizedQuery);
      spans.add(TextSpan(text: token, style: isMatch ? highlightStyle : style));
      if (i != words.length - 1) {
        spans.add(TextSpan(text: ' ', style: style));
      }
    }

    return Text.rich(
      TextSpan(children: spans),
      textDirection: TextDirection.rtl,
    );
  }
}
