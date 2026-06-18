import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:werdi/core/di/app_injector.dart';
import 'package:werdi/core/extensions/context_extensions.dart';
import 'package:werdi/core/theme/app_spacing.dart';
import 'package:werdi/core/widgets/app_scaffold.dart';
import 'package:werdi/core/widgets/app_setting_tile.dart';
import 'package:werdi/core/widgets/app_text.dart';
import 'package:werdi/features/settings/presentation/cubit/settings_cubit.dart';
import 'package:werdi/features/settings/presentation/cubit/settings_state.dart';

class NotificationsPage extends StatelessWidget {
  const NotificationsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => SettingsCubit(
        reminderService: AppInjector.reminderService,
        preferences: AppInjector.appPreferences,
      )..load(),
      child: const _NotificationsView(),
    );
  }
}

class _NotificationsView extends StatelessWidget {
  const _NotificationsView();

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return AppScaffold(
      appBar: AppBar(title: Text(l10n.notificationsTitle)),
      body: BlocBuilder<SettingsCubit, SettingsState>(
        builder: (context, state) {
          final cubit = context.read<SettingsCubit>();
          final timeLabel = _formatTime(
            context,
            hour: state.reminderHour,
            minute: state.reminderMinute,
          );
          return ListView(
            padding: EdgeInsets.all(AppSpacing.md),
            children: [
              AppSettingTile(
                title: l10n.reminders,
                subtitle: l10n.remindersSubtitle,
                leading: const Icon(Icons.notifications_active_rounded),
                trailing: Switch(
                  value: state.remindersEnabled,
                  onChanged: cubit.setRemindersEnabled,
                ),
              ),
              SizedBox(height: AppSpacing.sm),
              AppSettingTile(
                title: l10n.notificationsTimeTitle,
                subtitle: l10n.notificationsTimeSubtitle(timeLabel),
                leading: const Icon(Icons.schedule_rounded),
                trailing: const Icon(Icons.chevron_right_rounded),
                onTap: () async {
                  final selected = await showTimePicker(
                    context: context,
                    initialTime: TimeOfDay(
                      hour: state.reminderHour,
                      minute: state.reminderMinute,
                    ),
                  );
                  if (selected == null) return;
                  await cubit.setReminderTime(
                    hour: selected.hour,
                    minute: selected.minute,
                  );
                },
              ),
              SizedBox(height: AppSpacing.md),
              AppText(
                l10n.notificationsDescription,
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ],
          );
        },
      ),
    );
  }

  String _formatTime(
    BuildContext context, {
    required int hour,
    required int minute,
  }) {
    final tod = TimeOfDay(hour: hour, minute: minute);
    return MaterialLocalizations.of(context).formatTimeOfDay(tod);
  }
}
