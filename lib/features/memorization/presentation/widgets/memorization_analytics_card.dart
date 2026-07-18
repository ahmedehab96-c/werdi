import 'package:flutter/material.dart';
import 'package:werdi/core/extensions/context_extensions.dart';
import 'package:werdi/core/theme/app_spacing.dart';
import 'package:werdi/core/widgets/app_surface_card.dart';
import 'package:werdi/core/widgets/app_text.dart';
import 'package:werdi/features/memorization/domain/services/memorization_analytics_service.dart';

class MemorizationAnalyticsCard extends StatelessWidget {
  const MemorizationAnalyticsCard({
    required this.snapshot,
    super.key,
  });

  final MemorizationAnalyticsSnapshot snapshot;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);

    return AppSurfaceCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AppText(
            l10n.memorizationAnalyticsTitle,
            style: theme.textTheme.titleSmall,
          ),
          SizedBox(height: AppSpacing.sm),
          Row(
            children: [
              Expanded(
                child: _MetricTile(
                  label: l10n.todayMemorizedShort,
                  value: '${snapshot.todayAyahs}',
                ),
              ),
              SizedBox(width: AppSpacing.xs),
              Expanded(
                child: _MetricTile(
                  label: l10n.weekMemorizedShort,
                  value: '${snapshot.weekAyahs}',
                ),
              ),
            ],
          ),
          SizedBox(height: AppSpacing.xs),
          Row(
            children: [
              Expanded(
                child: _MetricTile(
                  label: l10n.difficultAyahsShort,
                  value: '${snapshot.difficultItems}',
                ),
              ),
              SizedBox(width: AppSpacing.xs),
              Expanded(
                child: _MetricTile(
                  label: l10n.reviewsThisWeekShort,
                  value: '${snapshot.reviewedThisWeek}',
                ),
              ),
            ],
          ),
          SizedBox(height: AppSpacing.sm),
          AppText(
            l10n.weeklyPaceHint(snapshot.weekAverage.toStringAsFixed(1)),
            style: theme.textTheme.bodySmall,
          ),
          SizedBox(height: AppSpacing.sm),
          SizedBox(
            height: 56,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                for (var i = 0; i < snapshot.last7Days.length; i++)
                  Expanded(
                    child: Padding(
                      padding: EdgeInsets.only(
                        right: i == snapshot.last7Days.length - 1 ? 0 : 4,
                      ),
                      child: _DayBar(
                        count: snapshot.last7Days[i],
                        maxCount: snapshot.last7Days.fold<int>(
                          1,
                          (max, value) => value > max ? value : max,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _MetricTile extends StatelessWidget {
  const _MetricTile({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(AppSpacing.sm),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AppText(
            value,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w800,
                ),
          ),
          AppText(
            label,
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ],
      ),
    );
  }
}

class _DayBar extends StatelessWidget {
  const _DayBar({required this.count, required this.maxCount});

  final int count;
  final int maxCount;

  @override
  Widget build(BuildContext context) {
    final fraction = count / maxCount;
    return Align(
      alignment: Alignment.bottomCenter,
      child: Container(
        height: 48 * fraction.clamp(0.08, 1.0),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.75),
          borderRadius: BorderRadius.circular(6),
        ),
      ),
    );
  }
}
