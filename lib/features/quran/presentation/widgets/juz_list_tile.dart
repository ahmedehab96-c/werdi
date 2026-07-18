import 'package:flutter/material.dart';
import 'package:werdi/core/extensions/context_extensions.dart';
import 'package:werdi/core/responsive/responsive_utils.dart';
import 'package:werdi/core/widgets/app_surface_card.dart';
import 'package:werdi/core/widgets/app_text.dart';
import 'package:werdi/features/quran/domain/models/juz_item.dart';

/// Compact juz row: number, title, range, open.
class JuzListTile extends StatelessWidget {
  const JuzListTile({required this.item, required this.onOpenTap, super.key});

  final JuzItem item;
  final VoidCallback onOpenTap;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final size = ResponsiveUtils.responsiveWidth(context, 36).clamp(32.0, 42.0);

    return AppSurfaceCard(
      onTap: onOpenTap,
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
              color: scheme.secondaryContainer.withValues(alpha: 0.7),
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
                  context.l10n.juzNumber(item.number),
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                ),
                AppText(
                  item.surahRangeText,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: scheme.onSurfaceVariant,
                      ),
                ),
              ],
            ),
          ),
          Icon(Icons.chevron_right_rounded, color: scheme.onSurfaceVariant),
          SizedBox(width: ResponsiveUtils.responsiveSpacing(context, 4)),
        ],
      ),
    );
  }
}
