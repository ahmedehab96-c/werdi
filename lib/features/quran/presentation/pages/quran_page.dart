import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:quran/quran.dart' as quran_pkg;
import 'package:werdi/core/di/app_injector.dart';
import 'package:werdi/core/extensions/context_extensions.dart';
import 'package:werdi/core/theme/app_spacing.dart';
import 'package:werdi/core/widgets/app_empty_state.dart';
import 'package:werdi/core/widgets/app_loading_state.dart';
import 'package:werdi/core/widgets/app_scaffold.dart';
import 'package:werdi/core/widgets/app_surface_card.dart';
import 'package:werdi/core/widgets/app_text.dart';
import 'package:werdi/features/quran/presentation/cubit/quran_cubit.dart';
import 'package:werdi/features/quran/presentation/cubit/quran_state.dart';
import 'package:werdi/features/quran/presentation/pages/bookmarks_page.dart';
import 'package:werdi/features/quran/presentation/pages/quran_search_page.dart';
import 'package:werdi/features/quran/presentation/pages/surah_details_page.dart';
import 'package:werdi/features/quran/presentation/widgets/juz_list_tile.dart';
import 'package:werdi/features/quran/presentation/widgets/quran_filter_chips.dart';
import 'package:werdi/features/quran/presentation/widgets/surah_list_tile.dart';

class QuranPage extends StatelessWidget {
  const QuranPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => QuranCubit(
        repository: AppInjector.quranRepository,
        tafsirRepository: AppInjector.quranTafsirRepository,
        preferences: AppInjector.appPreferences,
        mp3QuranRecitersApi: AppInjector.mp3QuranRecitersApi,
        bookmarkRepository: AppInjector.bookmarkRepository,
      )..initialize(),
      child: const _QuranView(),
    );
  }
}

class _QuranView extends StatelessWidget {
  const _QuranView();

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      appBar: AppBar(
        title: Text(context.l10n.quranTitle),
        actions: [
          IconButton(
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute<void>(
                  builder: (_) => BlocProvider.value(
                    value: context.read<QuranCubit>(),
                    child: const QuranSearchPage(),
                  ),
                ),
              );
            },
            icon: const Icon(Icons.search_rounded),
          ),
        ],
      ),
      body: Padding(
        padding: EdgeInsets.all(AppSpacing.md),
        child: BlocBuilder<QuranCubit, QuranState>(
          builder: (context, state) {
            final cubit = context.read<QuranCubit>();
            if (state.isLoading) {
              return AppLoadingState(message: context.l10n.loadingQuran);
            }
            return Column(
              children: [
                _LastReadAndBookmarksCard(state: state),
                SizedBox(height: AppSpacing.md),
                TextField(
                  onChanged: cubit.setQuery,
                  decoration: InputDecoration(
                    hintText: context.l10n.searchSurahOrJuzHint,
                    prefixIcon: const Icon(Icons.search_rounded),
                  ),
                ),
                SizedBox(height: AppSpacing.sm),
                QuranFilterChips(
                  selected: state.filter,
                  onChanged: cubit.setFilter,
                ),
                SizedBox(height: AppSpacing.sm),
                _SegmentedTabs(
                  selected: state.selectedTab,
                  onChanged: cubit.setSelectedTab,
                ),
                SizedBox(height: AppSpacing.sm),
                Expanded(
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 260),
                    child: switch (state.selectedTab) {
                      0 => _SurahList(state: state),
                      1 => _JuzList(state: state),
                      _ => _BookmarksTab(state: state),
                    },
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _LastReadAndBookmarksCard extends StatelessWidget {
  const _LastReadAndBookmarksCard({required this.state});

  final QuranState state;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return AppSurfaceCard(
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AppText(
                  context.l10n.lastRead,
                  style: Theme.of(context).textTheme.titleSmall,
                ),
                const SizedBox(height: 4),
                AppText(
                  state.lastReadPlaceholder.isEmpty
                      ? '—'
                      : state.lastReadPlaceholder,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              color: scheme.primaryContainer,
              borderRadius: BorderRadius.circular(14),
            ),
            child: AppText(
              context.l10n.bookmarksCount(state.bookmarkedSurahIds.length),
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ),
        ],
      ),
    );
  }
}

class _SurahList extends StatelessWidget {
  const _SurahList({required this.state});

  final QuranState state;

  @override
  Widget build(BuildContext context) {
    final filteredSurahs = state.filteredSurahs;
    if (filteredSurahs.isEmpty) {
      return AppEmptyState(
        title: context.l10n.noMatchingResults,
        subtitle: context.l10n.noMatchingResultsSubtitle,
        icon: Icons.search_off_rounded,
      );
    }
    return ListView.separated(
      key: const ValueKey<String>('surahList'),
      itemCount: filteredSurahs.length,
      separatorBuilder: (_, _) => SizedBox(height: AppSpacing.sm),
      itemBuilder: (context, index) {
        final item = filteredSurahs[index];
        return SurahListTile(
          item: item,
          isBookmarked: state.bookmarkedSurahIds.contains(item.number),
          onBookmarkTap: () =>
              context.read<QuranCubit>().toggleBookmark(item.number),
          onTap: () {
            Navigator.of(context).push(
              MaterialPageRoute<void>(
                builder: (_) => BlocProvider.value(
                  value: context.read<QuranCubit>(),
                  child: SurahDetailsPage(surah: item),
                ),
              ),
            );
          },
        );
      },
    );
  }
}

class _JuzList extends StatelessWidget {
  const _JuzList({required this.state});

  final QuranState state;

  @override
  Widget build(BuildContext context) {
    final filteredJuz = state.filteredJuz;
    if (filteredJuz.isEmpty) {
      return AppEmptyState(
        title: context.l10n.noMatchingResults,
        subtitle: context.l10n.noMatchingJuzSubtitle,
        icon: Icons.filter_alt_off_rounded,
      );
    }
    return LayoutBuilder(
      key: const ValueKey<String>('juzList'),
      builder: (context, constraints) {
        final isWide = constraints.maxWidth > 700;
        if (!isWide) {
          return ListView.separated(
            itemCount: filteredJuz.length,
            separatorBuilder: (_, _) => SizedBox(height: AppSpacing.sm),
            itemBuilder: (context, index) =>
                JuzListTile(
                  item: filteredJuz[index],
                  onOpenTap: () {
                    final juzSurahs = quran_pkg.getSurahAndVersesFromJuz(
                      filteredJuz[index].number,
                    );
                    final firstSurahNumber = juzSurahs.keys.first;
                    final surah = state.surahByNumber(firstSurahNumber);
                    if (surah == null) return;
                    Navigator.of(context).push(
                      MaterialPageRoute<void>(
                        builder: (_) => BlocProvider.value(
                          value: context.read<QuranCubit>(),
                          child: SurahDetailsPage(surah: surah),
                        ),
                      ),
                    );
                  },
                ),
          );
        }
        return GridView.builder(
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: constraints.maxWidth > 1100 ? 3 : 2,
            crossAxisSpacing: 12.w,
            mainAxisSpacing: 12.h,
            childAspectRatio: 2,
          ),
          itemCount: filteredJuz.length,
          itemBuilder: (context, index) =>
              JuzListTile(
                  item: filteredJuz[index],
                  onOpenTap: () {
                    final juzSurahs = quran_pkg.getSurahAndVersesFromJuz(
                      filteredJuz[index].number,
                    );
                    final firstSurahNumber = juzSurahs.keys.first;
                    final surah = state.surahByNumber(firstSurahNumber);
                    if (surah == null) return;
                    Navigator.of(context).push(
                      MaterialPageRoute<void>(
                        builder: (_) => BlocProvider.value(
                          value: context.read<QuranCubit>(),
                          child: SurahDetailsPage(surah: surah),
                        ),
                      ),
                    );
                  },
                ),
        );
      },
    );
  }
}

class _BookmarksTab extends StatelessWidget {
  const _BookmarksTab({required this.state});

  final QuranState state;

  @override
  Widget build(BuildContext context) {
    return ListView(
      key: const ValueKey<String>('bookmarksTab'),
      children: [
        AppSurfaceCard(
          child: ListTile(
            contentPadding: EdgeInsets.zero,
            leading: const Icon(Icons.bookmarks_rounded),
            title: AppText(context.l10n.viewAllBookmarks),
            subtitle: AppText(context.l10n.viewAllBookmarksSubtitle),
            trailing: Icon(
              Directionality.of(context) == TextDirection.rtl
                  ? Icons.chevron_left_rounded
                  : Icons.chevron_right_rounded,
              size: 18,
            ),
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute<void>(
                  builder: (_) => BookmarksPage(state: state),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

class _SegmentedTabs extends StatelessWidget {
  const _SegmentedTabs({required this.selected, required this.onChanged});

  final int selected;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return LayoutBuilder(
      builder: (context, constraints) {
        final compact = constraints.maxWidth < 360;
        return SegmentedButton<int>(
          showSelectedIcon: false,
          style: ButtonStyle(
            visualDensity: compact ? VisualDensity.compact : null,
          ),
          segments: [
            ButtonSegment<int>(
              value: 0,
              icon: const Icon(Icons.menu_book_rounded),
              label: Text(l10n.surahTab),
            ),
            ButtonSegment<int>(
              value: 1,
              icon: const Icon(Icons.grid_view_rounded),
              label: Text(l10n.juzTab),
            ),
            ButtonSegment<int>(
              value: 2,
              icon: const Icon(Icons.bookmark_rounded),
              label: Text(l10n.bookmarks),
            ),
          ],
          selected: {selected},
          onSelectionChanged: (selection) => onChanged(selection.first),
        );
      },
    );
  }
}
