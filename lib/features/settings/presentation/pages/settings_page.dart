import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:werdi/app/state/locale_cubit.dart';
import 'package:werdi/app/state/theme_cubit.dart';
import 'package:werdi/core/di/app_injector.dart';
import 'package:werdi/core/theme/app_spacing.dart';
import 'package:werdi/core/widgets/app_scaffold.dart';
import 'package:werdi/core/widgets/app_setting_tile.dart';
import 'package:werdi/core/widgets/app_text.dart';
import 'package:werdi/features/settings/presentation/cubit/settings_cubit.dart';
import 'package:werdi/features/settings/presentation/cubit/settings_state.dart';
import 'package:werdi/core/extensions/context_extensions.dart';
import 'package:werdi/routes/app_routes.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => SettingsCubit(
        reminderService: AppInjector.reminderService,
        preferences: AppInjector.appPreferences,
      )..load(),
      child: const _SettingsView(),
    );
  }
}

class _SettingsView extends StatelessWidget {
  const _SettingsView();

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return AppScaffold(
      appBar: AppBar(title: Text(l10n.settingsTitle)),
      body: BlocBuilder<SettingsCubit, SettingsState>(
        builder: (context, settingsState) {
          final themeMode = context.watch<ThemeCubit>().state;
          final locale = context.watch<LocaleCubit>().state;
          final settingsCubit = context.read<SettingsCubit>();
          final themeCubit = context.read<ThemeCubit>();
          final localeCubit = context.read<LocaleCubit>();
          final isDark = themeMode == ThemeMode.dark;

          return ListView(
            padding: EdgeInsets.all(AppSpacing.md),
            children: [
              AppSettingTile(
                title: l10n.darkMode,
                subtitle: l10n.darkModeSubtitle,
                leading: const Icon(Icons.dark_mode_rounded),
                trailing: Switch(
                  value: isDark,
                  onChanged: (value) {
                    themeCubit.setTheme(
                      value ? ThemeMode.dark : ThemeMode.light,
                    );
                  },
                ),
              ),
              SizedBox(height: AppSpacing.sm),
              AppSettingTile(
                title: l10n.language,
                subtitle: locale.languageCode == 'ar' ? 'العربية' : 'English',
                leading: const Icon(Icons.language_rounded),
                trailing: DropdownButton<String>(
                  value: locale.languageCode,
                  underline: const SizedBox.shrink(),
                  items: const [
                    DropdownMenuItem(value: 'ar', child: Text('العربية')),
                    DropdownMenuItem(value: 'en', child: Text('English')),
                  ],
                  onChanged: (value) {
                    if (value == null) return;
                    localeCubit.setLocale(value);
                  },
                ),
              ),
              SizedBox(height: AppSpacing.sm),
              AppSettingTile(
                title: l10n.fontSize,
                subtitle: l10n.fontSizeSubtitle,
                leading: const Icon(Icons.format_size_rounded),
                trailing: LayoutBuilder(
                  builder: (context, constraints) {
                    final width = constraints.maxWidth < 340 ? 80.0 : 120.0;
                    return SizedBox(
                      width: width,
                      child: Slider(
                        value: settingsState.fontScale,
                        min: 0.9,
                        max: 1.2,
                        divisions: 3,
                        onChanged: settingsCubit.setFontScale,
                      ),
                    );
                  },
                ),
              ),
              SizedBox(height: AppSpacing.sm),
              AppSettingTile(
                title: l10n.notificationsTitle,
                subtitle: l10n.notificationsSubtitle,
                leading: const Icon(Icons.notifications_active_rounded),
                trailing: const Icon(Icons.chevron_right_rounded),
                onTap: () {
                  context.pushNamed(AppRoutes.notifications);
                },
              ),
              SizedBox(height: AppSpacing.sm),
              AppSettingTile(
                title: l10n.searchFocusModeTitle,
                subtitle: l10n.searchFocusModeSubtitle,
                leading: const Icon(Icons.fullscreen_rounded),
                trailing: Switch(
                  value: settingsState.openSearchResultsInFocusMode,
                  onChanged: settingsCubit.setSearchFocusMode,
                ),
              ),
              SizedBox(height: AppSpacing.sm),
              AppSettingTile(
                title: l10n.unifiedReadingPrefsTitle,
                subtitle: l10n.unifiedReadingPrefsSubtitle,
                leading: const Icon(Icons.tune_rounded),
                trailing: Switch(
                  value: settingsState.useUnifiedReadingPreferences,
                  onChanged: settingsCubit.setUnifiedReadingPreferences,
                ),
              ),
              SizedBox(height: AppSpacing.md),
              AppText(
                l10n.notificationsDescription,
                style: Theme.of(context).textTheme.bodySmall,
              ),
              if (settingsState.remindersEnabled) ...[
                SizedBox(height: AppSpacing.xs),
                AppText(
                  l10n.notificationsTimeHint(
                    settingsState.reminderHour.toString().padLeft(2, '0'),
                    settingsState.reminderMinute.toString().padLeft(2, '0'),
                  ),
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ],
          );
        },
      ),
    );
  }
}
