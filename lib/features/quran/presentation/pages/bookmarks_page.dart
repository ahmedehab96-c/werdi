import 'package:flutter/material.dart';
import 'package:werdi/core/theme/app_spacing.dart';
import 'package:werdi/core/extensions/context_extensions.dart';
import 'package:werdi/core/widgets/app_empty_state.dart';
import 'package:werdi/core/widgets/app_section_header.dart';
import 'package:werdi/core/widgets/app_scaffold.dart';
import 'package:werdi/core/widgets/app_surface_card.dart';
import 'package:werdi/core/widgets/app_text.dart';
import 'package:werdi/features/quran/presentation/cubit/quran_state.dart';

class BookmarksPage extends StatelessWidget {
  const BookmarksPage({required this.state, super.key});

  final QuranState state;

  @override
  Widget build(BuildContext context) {
    final hasAny =
        state.bookmarkedSurahIds.isNotEmpty ||
        state.bookmarkedAyahs.isNotEmpty ||
        state.lastMemorizedPositions.isNotEmpty;
    final l10n = context.l10n;
    final scheme = Theme.of(context).colorScheme;
    return AppScaffold(
      appBar: AppBar(title: Text(l10n.bookmarks)),
      body: ListView(
        padding: const EdgeInsets.all(AppSpacing.md),
        children: [
          if (!hasAny)
            AppEmptyState(
              title: l10n.noBookmarks,
              subtitle: l10n.noBookmarksSubtitle,
              icon: Icons.bookmark_border_rounded,
            )
          else ...[
            AppSectionHeader(title: l10n.savedSurahs),
            const SizedBox(height: AppSpacing.xs),
            ...state.bookmarkedSurahIds.map(
              (id) => Padding(
                padding: const EdgeInsets.only(bottom: AppSpacing.xs),
                child: AppSurfaceCard(
                  child: Row(
                    children: [
                      Icon(Icons.menu_book_rounded, color: scheme.primary),
                      const SizedBox(width: AppSpacing.sm),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            AppText(l10n.surahNumber(id)),
                            AppText(
                              l10n.savedToBookmarks,
                              style: Theme.of(context).textTheme.bodySmall,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            AppSectionHeader(title: l10n.savedAyahs),
            const SizedBox(height: AppSpacing.xs),
            ...state.bookmarkedAyahs.map(
              (ayah) => Padding(
                padding: const EdgeInsets.only(bottom: AppSpacing.xs),
                child: AppSurfaceCard(
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            AppText(
                              '${ayah.surahNameArabic} • ${l10n.ayahNumbered(ayah.ayahNumber)}',
                            ),
                            AppText(
                              ayah.previewText,
                              style: Theme.of(context).textTheme.bodySmall,
                            ),
                          ],
                        ),
                      ),
                      Icon(
                        Directionality.of(context) == TextDirection.rtl
                            ? Icons.chevron_left_rounded
                            : Icons.chevron_right_rounded,
                        color: scheme.onSurfaceVariant,
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            AppSectionHeader(title: l10n.lastPositions),
            const SizedBox(height: AppSpacing.xs),
            ...state.lastMemorizedPositions.map(
              (item) => Padding(
                padding: const EdgeInsets.only(bottom: AppSpacing.xs),
                child: AppSurfaceCard(
                  child: Row(
                    children: [
                      Icon(Icons.flag_rounded, color: scheme.primary),
                      const SizedBox(width: AppSpacing.sm),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            AppText(item.surahNameArabic),
                            AppText(
                              l10n.fromAyahToAyah(item.fromAyah, item.toAyah),
                              style: Theme.of(context).textTheme.bodySmall,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
