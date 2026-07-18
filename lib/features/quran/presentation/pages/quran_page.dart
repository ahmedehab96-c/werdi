import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:quran/quran.dart' as quran_pkg;
import 'package:werdi/core/di/app_injector.dart';
import 'package:werdi/core/extensions/context_extensions.dart';
import 'package:werdi/core/responsive/responsive_utils.dart';
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
    final l10n = context.l10n;

    return AppScaffold(
      appBar: AppBar(
        title: Text(l10n.quranTitle),
        actions: [
          IconButton(
            tooltip: l10n.searchQuranTitle,
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
      body: BlocBuilder<QuranCubit, QuranState>(
        builder: (context, state) {
          final cubit = context.read<QuranCubit>();
          if (state.surahs.isEmpty) {
            return AppLoadingState(message: l10n.loadingQuran);
          }

          final compact = ResponsiveHelper.isSmallPhone(context);

          return Column(
            children: [
              SizedBox(height: AppSpacing.sm),
              LayoutBuilder(
                builder: (context, constraints) {
                  final button = SegmentedButton<int>(
                    segments: [
                      ButtonSegment(
                        value: 0,
                        label: Text(l10n.surahTab),
                        icon: compact
                            ? const Icon(Icons.menu_book_outlined, size: 18)
                            : null,
                      ),
                      ButtonSegment(
                        value: 1,
                        label: Text(l10n.juzTab),
                        icon: compact
                            ? const Icon(Icons.view_day_outlined, size: 18)
                            : null,
                      ),
                      ButtonSegment(
                        value: 2,
                        label: Text(l10n.bookmarks),
                        icon: compact
                            ? const Icon(Icons.bookmark_outline, size: 18)
                            : null,
                      ),
                    ],
                    selected: {state.selectedTab},
                    onSelectionChanged: (v) => cubit.setSelectedTab(v.first),
                    showSelectedIcon: false,
                  );
                  if (constraints.maxWidth < 340) {
                    return FittedBox(
                      fit: BoxFit.scaleDown,
                      child: SizedBox(width: 340, child: button),
                    );
                  }
                  return button;
                },
              ),
              if (state.selectedTab == 0) ...[
                SizedBox(height: AppSpacing.sm),
                QuranFilterChips(
                  selected: state.filter,
                  onChanged: cubit.setFilter,
                ),
              ],
              SizedBox(height: AppSpacing.sm),
              Expanded(
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 200),
                  child: switch (state.selectedTab) {
                    0 => _SurahList(key: const ValueKey(0), state: state),
                    1 => _JuzList(key: const ValueKey(1), state: state),
                    _ => _BookmarksTab(key: const ValueKey(2), state: state),
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _SurahList extends StatelessWidget {
  const _SurahList({required this.state, super.key});

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
      itemCount: filteredSurahs.length,
      separatorBuilder: (_, _) => SizedBox(height: AppSpacing.xs),
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
  const _JuzList({required this.state, super.key});

  final QuranState state;

  void _openJuz(BuildContext context, int juzNumber) {
    final juzSurahs = quran_pkg.getSurahAndVersesFromJuz(juzNumber);
    final surah = state.surahByNumber(juzSurahs.keys.first);
    if (surah == null) return;
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => BlocProvider.value(
          value: context.read<QuranCubit>(),
          child: SurahDetailsPage(surah: surah),
        ),
      ),
    );
  }

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
      builder: (context, constraints) {
        if (constraints.maxWidth <= 700) {
          return ListView.separated(
            itemCount: filteredJuz.length,
            separatorBuilder: (_, _) => SizedBox(height: AppSpacing.xs),
            itemBuilder: (context, index) => JuzListTile(
              item: filteredJuz[index],
              onOpenTap: () => _openJuz(context, filteredJuz[index].number),
            ),
          );
        }
        return GridView.builder(
          gridDelegate: ResponsiveHelper.adaptiveGridDelegate(context),
          itemCount: filteredJuz.length,
          itemBuilder: (context, index) => JuzListTile(
            item: filteredJuz[index],
            onOpenTap: () => _openJuz(context, filteredJuz[index].number),
          ),
        );
      },
    );
  }
}

class _BookmarksTab extends StatelessWidget {
  const _BookmarksTab({required this.state, super.key});

  final QuranState state;

  @override
  Widget build(BuildContext context) {
    return ListView(
      children: [
        AppSurfaceCard(
          onTap: () {
            Navigator.of(context).push(
              MaterialPageRoute<void>(
                builder: (_) => BookmarksPage(state: state),
              ),
            );
          },
          child: Row(
            children: [
              const Icon(Icons.bookmarks_rounded),
              SizedBox(width: AppSpacing.sm),
              Expanded(child: AppText(context.l10n.viewAllBookmarks)),
              AppText(
                '${state.bookmarkedSurahIds.length}',
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
