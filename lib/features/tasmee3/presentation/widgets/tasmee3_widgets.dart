import 'package:flutter/material.dart';
import 'package:werdi/core/extensions/context_extensions.dart';
import 'package:werdi/core/theme/app_spacing.dart';
import 'package:werdi/core/widgets/app_animated_progress.dart';
import 'package:werdi/core/widgets/app_status_chip.dart';
import 'package:werdi/core/widgets/app_surface_card.dart';
import 'package:werdi/core/widgets/app_text.dart';
import 'package:werdi/features/tasmee3/domain/models/ayah_range.dart';
import 'package:werdi/features/tasmee3/domain/models/tasmee3_result.dart';
import 'package:werdi/features/tasmee3/domain/models/tasmee3_session.dart';

class ResultStatusChip extends StatelessWidget {
  const ResultStatusChip({required this.status, super.key});

  final Tasmee3StatusLabel status;

  @override
  Widget build(BuildContext context) {
    final color = switch (status) {
      Tasmee3StatusLabel.excellent => Colors.green,
      Tasmee3StatusLabel.veryGood => Colors.teal,
      Tasmee3StatusLabel.good => Colors.orange,
      Tasmee3StatusLabel.needsImprovement => Colors.redAccent,
    };
    return AppStatusChip(
      label: status.text,
      foreground: color,
      background: color.withValues(alpha: 0.16),
    );
  }
}

class ScoreSummaryCard extends StatelessWidget {
  const ScoreSummaryCard({required this.result, super.key});

  final Tasmee3Result result;

  @override
  Widget build(BuildContext context) {
    return AppSurfaceCard(
      child: Column(
        children: [
          Text(
            '${result.score}%',
            style: Theme.of(context).textTheme.displaySmall?.copyWith(
                  fontWeight: FontWeight.w800,
                ),
          ),
          SizedBox(height: AppSpacing.sm),
          ResultStatusChip(status: result.status),
          SizedBox(height: AppSpacing.md),
          AppAnimatedProgress(
            value: result.total == 0 ? 0 : result.knownCount / result.total,
            minHeight: 8,
            borderRadius: 20,
          ),
          SizedBox(height: AppSpacing.md),
          Row(
            children: [
              Expanded(
                child: _StatBubble(
                  icon: Icons.check_circle_rounded,
                  color: Colors.green,
                  label: context.l10n.bubbleKnown,
                  count: result.knownCount,
                ),
              ),
              Expanded(
                child: _StatBubble(
                  icon: Icons.warning_amber_rounded,
                  color: Colors.orange,
                  label: context.l10n.bubbleHesitant,
                  count: result.hesitantCount,
                ),
              ),
              Expanded(
                child: _StatBubble(
                  icon: Icons.cancel_rounded,
                  color: Colors.redAccent,
                  label: context.l10n.bubbleUnknown,
                  count: result.unknownCount,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _StatBubble extends StatelessWidget {
  const _StatBubble({
    required this.icon,
    required this.color,
    required this.label,
    required this.count,
  });

  final IconData icon;
  final Color color;
  final String label;
  final int count;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(icon, color: color, size: 22),
        const SizedBox(height: AppSpacing.xxs),
        Text(
          '$count',
          style: Theme.of(context)
              .textTheme
              .titleMedium
              ?.copyWith(fontWeight: FontWeight.w700, color: color),
        ),
        AppText(
          label,
          textAlign: TextAlign.center,
          maxLines: 1,
          style: Theme.of(context).textTheme.bodySmall,
        ),
      ],
    );
  }
}

class AyahRangeSelector extends StatelessWidget {
  const AyahRangeSelector({
    required this.value,
    required this.onChanged,
    super.key,
  });

  final AyahRange value;
  final ValueChanged<AyahRange> onChanged;

  static const _options = [
    AyahRange(start: 1, end: 5),
    AyahRange(start: 1, end: 10),
    AyahRange(start: 11, end: 20),
    AyahRange(start: 21, end: 30),
  ];

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: AppSpacing.xs,
      runSpacing: AppSpacing.xs,
      children: _options
          .map(
            (range) => ChoiceChip(
              label: Text(range.label),
              selected: value == range,
              onSelected: (_) => onChanged(range),
            ),
          )
          .toList(),
    );
  }
}

class SessionHistoryCard extends StatelessWidget {
  const SessionHistoryCard({
    required this.session,
    required this.onOpen,
    super.key,
  });

  final Tasmee3Session session;
  final VoidCallback onOpen;

  @override
  Widget build(BuildContext context) {
    final score = session.result.score;
    final scoreColor = score >= 90
        ? Colors.green
        : score >= 75
            ? Colors.teal
            : score >= 50
                ? Colors.orange
                : Colors.redAccent;
    return AppSurfaceCard(
      onTap: onOpen,
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: scoreColor.withValues(alpha: 0.12),
            ),
            alignment: Alignment.center,
            child: Text(
              '$score%',
              style: Theme.of(context).textTheme.labelMedium?.copyWith(
                    color: scoreColor,
                    fontWeight: FontWeight.w700,
                  ),
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AppText(
                  '${session.surahName} • ${session.ayahRange.label}',
                  maxLines: 2,
                ),
                AppText(
                  session.date.toLocal().toString().split(' ').first,
                  maxLines: 1,
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
          ),
          Icon(
            Directionality.of(context) == TextDirection.rtl
                ? Icons.chevron_left_rounded
                : Icons.chevron_right_rounded,
          ),
        ],
      ),
    );
  }
}
