import 'package:flutter/material.dart';
import 'package:werdi/core/extensions/context_extensions.dart';
import 'package:werdi/core/theme/app_spacing.dart';
import 'package:werdi/core/widgets/app_button.dart';
import 'package:werdi/core/widgets/app_scaffold.dart';
import 'package:werdi/core/widgets/app_surface_card.dart';
import 'package:werdi/core/widgets/app_text.dart';
import 'package:werdi/features/tasmee3/domain/models/tasmee3_result.dart';
import 'package:werdi/features/tasmee3/domain/models/tasmee3_session.dart';
import 'package:werdi/features/tasmee3/presentation/widgets/tasmee3_widgets.dart';

class Tasmee3SessionDetailsPage extends StatelessWidget {
  const Tasmee3SessionDetailsPage({required this.session, super.key});

  final Tasmee3Session session;

  @override
  Widget build(BuildContext context) {
    final result = session.result;
    final l10n = context.l10n;
    return AppScaffold(
      appBar: AppBar(title: Text(l10n.sessionDetails)),
      body: ListView(
        padding: const EdgeInsets.all(AppSpacing.md),
        children: [
          AppSurfaceCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AppText(
                  l10n.surahNamed(session.surahName),
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                ),
                const SizedBox(height: AppSpacing.xxs),
                AppText(
                  '${session.ayahRange.label} • ${session.date.toLocal().toString().split(' ').first}',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
                const SizedBox(height: AppSpacing.sm),
                ResultStatusChip(status: result.status),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          ScoreSummaryCard(result: result),
          const SizedBox(height: AppSpacing.sm),
          AppSurfaceCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AppText(
                  l10n.ayahBreakdown,
                  style: Theme.of(context).textTheme.titleSmall,
                ),
                SizedBox(height: AppSpacing.sm),
                ...result.grades.entries.map(
                  (e) => Padding(
                    padding: const EdgeInsets.symmetric(vertical: AppSpacing.xxs),
                    child: Row(
                      children: [
                        Icon(
                          _gradeIcon(e.value),
                          size: 18,
                          color: _gradeColor(e.value),
                        ),
                        const SizedBox(width: AppSpacing.xs),
                        AppText(l10n.ayahNumbered(e.key)),
                        const Spacer(),
                        AppText(
                          e.value.label,
                          style:
                              Theme.of(context).textTheme.bodySmall?.copyWith(
                                    color: _gradeColor(e.value),
                                  ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          AppButton(
            label: l10n.back,
            onPressed: () => Navigator.of(context).pop(),
            variant: AppButtonVariant.outlined,
          ),
        ],
      ),
    );
  }

  IconData _gradeIcon(AyahGrade grade) => switch (grade) {
        AyahGrade.known => Icons.check_circle_rounded,
        AyahGrade.hesitant => Icons.warning_amber_rounded,
        AyahGrade.unknown => Icons.cancel_rounded,
      };

  Color _gradeColor(AyahGrade grade) => switch (grade) {
        AyahGrade.known => Colors.green,
        AyahGrade.hesitant => Colors.orange,
        AyahGrade.unknown => Colors.redAccent,
      };
}
