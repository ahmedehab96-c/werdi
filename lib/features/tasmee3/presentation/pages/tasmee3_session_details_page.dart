import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
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
        padding: EdgeInsets.all(16.w),
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
                SizedBox(height: 4.h),
                AppText(
                  '${session.ayahRange.label} • ${session.date.toLocal().toString().split(' ').first}',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
                SizedBox(height: 10.h),
                ResultStatusChip(status: result.status),
              ],
            ),
          ),
          SizedBox(height: 10.h),
          ScoreSummaryCard(result: result),
          SizedBox(height: 10.h),
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
                    padding: EdgeInsets.symmetric(vertical: 4.h),
                    child: Row(
                      children: [
                        Icon(
                          _gradeIcon(e.value),
                          size: 18.sp,
                          color: _gradeColor(e.value),
                        ),
                        SizedBox(width: 8.w),
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
          SizedBox(height: 16.h),
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
