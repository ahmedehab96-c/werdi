import 'package:flutter/material.dart';
import 'package:werdi/core/extensions/context_extensions.dart';
import 'package:werdi/core/responsive/responsive_utils.dart';
import 'package:werdi/core/widgets/app_surface_card.dart';
import 'package:werdi/core/widgets/app_text.dart';
import 'package:werdi/features/quran/domain/models/surah_item.dart';

/// Compact surah row: number, Arabic name, verse count, bookmark.
class SurahListTile extends StatelessWidget {
  const SurahListTile({
    required this.item,
    required this.isBookmarked,
    required this.onBookmarkTap,
    required this.onTap,
    super.key,
  });

  final SurahItem item;
  final bool isBookmarked;
  final VoidCallback onBookmarkTap;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final size = ResponsiveUtils.responsiveWidth(context, 36).clamp(32.0, 42.0);

    return AppSurfaceCard(
      onTap: onTap,
      padding: EdgeInsetsDirectional.only(
        start: ResponsiveUtils.responsiveSpacing(context, 12),
        end: ResponsiveUtils.responsiveSpacing(context, 4),
        top: ResponsiveUtils.responsiveSpacing(context, 8),
        bottom: ResponsiveUtils.responsiveSpacing(context, 8),
      ),
      child: Row(
        children: [
          Container(
            width: size,
            height: size,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: scheme.primaryContainer.withValues(alpha: 0.65),
              borderRadius: BorderRadius.circular(
                ResponsiveUtils.responsiveRadius(context, 10),
              ),
            ),
            child: AppText(
              '${item.number}',
              style: Theme.of(context).textTheme.labelLarge?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
            ),
          ),
          SizedBox(width: ResponsiveUtils.responsiveSpacing(context, 12)),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AppText(
                  item.nameArabic,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                ),
                AppText(
                  context.l10n.ayahUnit(item.verseCount),
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: scheme.onSurfaceVariant,
                      ),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: onBookmarkTap,
            icon: Icon(
              isBookmarked
                  ? Icons.bookmark_rounded
                  : Icons.bookmark_border_rounded,
              color: isBookmarked ? scheme.primary : scheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}
