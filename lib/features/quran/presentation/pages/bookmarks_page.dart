import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
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
    return AppScaffold(
      appBar: AppBar(title: Text(l10n.bookmarks)),
      body: ListView(
        padding: EdgeInsets.all(16.w),
        children: [
          if (!hasAny)
            AppEmptyState(
              title: l10n.noBookmarks,
              subtitle: l10n.noBookmarksSubtitle,
              icon: Icons.bookmark_border_rounded,
            )
          else ...[
            AppSectionHeader(title: l10n.savedSurahs),
            SizedBox(height: 8.h),
            ...state.bookmarkedSurahIds.map(
              (id) => AppSurfaceCard(
                child: ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: const Icon(Icons.menu_book_rounded),
                  title: AppText(l10n.surahNumber(id)),
                  subtitle: AppText(l10n.savedToBookmarks),
                ),
              ),
            ),
            SizedBox(height: 10.h),
            AppSectionHeader(title: l10n.savedAyahs),
            SizedBox(height: 8.h),
            ...state.bookmarkedAyahs.map(
              (ayah) => AppSurfaceCard(
                child: ListTile(
                  contentPadding: EdgeInsets.zero,
                  title: AppText(
                    '${ayah.surahNameArabic} • ${l10n.ayahNumbered(ayah.ayahNumber)}',
                  ),
                  subtitle: AppText(ayah.previewText),
                  trailing: Icon(
                    Directionality.of(context) == TextDirection.rtl
                        ? Icons.chevron_left_rounded
                        : Icons.chevron_right_rounded,
                  ),
                ),
              ),
            ),
            SizedBox(height: 10.h),
            AppSectionHeader(title: l10n.lastPositions),
            SizedBox(height: 8.h),
            ...state.lastMemorizedPositions.map(
              (item) => AppSurfaceCard(
                child: ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: const Icon(Icons.flag_rounded),
                  title: AppText(item.surahNameArabic),
                  subtitle: AppText(
                    l10n.fromAyahToAyah(item.fromAyah, item.toAyah),
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
