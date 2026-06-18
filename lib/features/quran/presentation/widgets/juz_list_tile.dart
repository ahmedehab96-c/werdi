import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:werdi/core/extensions/context_extensions.dart';
import 'package:werdi/core/widgets/app_animated_progress.dart';
import 'package:werdi/core/widgets/app_surface_card.dart';
import 'package:werdi/core/widgets/app_text.dart';
import 'package:werdi/features/quran/domain/models/juz_item.dart';

class JuzListTile extends StatelessWidget {
  const JuzListTile({required this.item, required this.onOpenTap, super.key});

  final JuzItem item;
  final VoidCallback onOpenTap;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return AppSurfaceCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 38.w,
                height: 38.w,
                decoration: BoxDecoration(
                  color: scheme.secondaryContainer,
                  borderRadius: BorderRadius.circular(12.r),
                ),
                alignment: Alignment.center,
                child: AppText(
                  item.number.toString(),
                  style: Theme.of(context).textTheme.labelLarge,
                ),
              ),
              SizedBox(width: 10.w),
              Expanded(
                child: AppText(
                  context.l10n.juzNumber(item.number),
                  style: Theme.of(
                    context,
                  ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700),
                ),
              ),
              TextButton.icon(
                onPressed: onOpenTap,
                icon: const Icon(Icons.menu_book_rounded),
                label: Text(context.l10n.open),
              ),
            ],
          ),
          SizedBox(height: 8.h),
          AppText(
            item.surahRangeText,
            style: Theme.of(
              context,
            ).textTheme.bodySmall?.copyWith(color: scheme.onSurfaceVariant),
          ),
          SizedBox(height: 10.h),
          AppAnimatedProgress(value: item.progress),
        ],
      ),
    ).animate().fadeIn(duration: 220.ms).slideY(begin: 0.05, end: 0);
  }
}
