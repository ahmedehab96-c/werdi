import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:werdi/app/state/locale_cubit.dart';
import 'package:werdi/app/state/theme_cubit.dart';
import 'package:werdi/core/constants/app_constants.dart';
import 'package:werdi/core/di/app_injector.dart';
import 'package:werdi/core/extensions/context_extensions.dart';
import 'package:werdi/core/responsive/responsive.dart';
import 'package:werdi/core/theme/app_spacing.dart';
import 'package:werdi/core/widgets/app_scaffold.dart';
import 'package:werdi/core/widgets/app_setting_tile.dart';
import 'package:werdi/core/widgets/app_surface_card.dart';
import 'package:werdi/core/widgets/app_text.dart';
import 'package:werdi/features/settings/presentation/cubit/settings_cubit.dart';
import 'package:werdi/features/settings/presentation/cubit/settings_state.dart';
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

          return ListView(
            padding: EdgeInsets.all(AppSpacing.md),
            children: [
              AppSurfaceCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    AppText(
                      l10n.themeModeTitle,
                      style: Theme.of(context).textTheme.titleSmall,
                    ),
                    SizedBox(height: AppSpacing.xs),
                    AppText(
                      l10n.themeModeSubtitle,
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                    SizedBox(height: AppSpacing.sm),
                    _ThemeModeSelector(
                      selected: themeMode,
                      onChanged: themeCubit.setTheme,
                    ),
                  ],
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
                title: l10n.offlineRecitationsTitle,
                subtitle: l10n.offlineRecitationsSubtitle,
                leading: const Icon(Icons.download_for_offline_rounded),
                trailing: const Icon(Icons.chevron_right_rounded),
                onTap: () {
                  context.pushNamed(AppRoutes.offlineRecitations);
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
              SizedBox(height: AppSpacing.sm),
              AppSettingTile(
                title: locale.languageCode == 'ar'
                    ? 'سياسة الخصوصية'
                    : 'Privacy policy',
                subtitle: locale.languageCode == 'ar'
                    ? 'كيف نتعامل مع بياناتك'
                    : 'How we handle your data',
                leading: const Icon(Icons.privacy_tip_outlined),
                trailing: const Icon(Icons.open_in_new_rounded),
                onTap: () async {
                  final uri = Uri.parse(AppConstants.privacyPolicyUrl);
                  if (await canLaunchUrl(uri)) {
                    await launchUrl(uri, mode: LaunchMode.externalApplication);
                  }
                },
              ),
              SizedBox(height: AppSpacing.sm),
              AppSettingTile(
                title: locale.languageCode == 'ar'
                    ? 'إصدار التطبيق'
                    : 'App version',
                subtitle: AppConstants.appVersionLabel,
                leading: const Icon(Icons.info_outline_rounded),
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

class _ThemeModeSelector extends StatelessWidget {
  const _ThemeModeSelector({
    required this.selected,
    required this.onChanged,
  });

  final ThemeMode selected;
  final ValueChanged<ThemeMode> onChanged;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final compact = context.isCompactScreen;

    if (compact) {
      return SegmentedButton<ThemeMode>(
        showSelectedIcon: false,
        segments: [
          ButtonSegment(
            value: ThemeMode.light,
            icon: const Icon(Icons.light_mode_rounded),
            label: Text(l10n.themeLight),
          ),
          ButtonSegment(
            value: ThemeMode.dark,
            icon: const Icon(Icons.dark_mode_rounded),
            label: Text(l10n.themeDark),
          ),
          ButtonSegment(
            value: ThemeMode.system,
            icon: const Icon(Icons.brightness_auto_rounded),
            label: Text(l10n.themeSystem),
          ),
        ],
        selected: {selected},
        onSelectionChanged: (values) => onChanged(values.first),
      );
    }

    return Wrap(
      spacing: AppSpacing.sm,
      runSpacing: AppSpacing.sm,
      children: [
        _ThemeChoiceChip(
          icon: Icons.light_mode_rounded,
          label: l10n.themeLight,
          selected: selected == ThemeMode.light,
          onTap: () => onChanged(ThemeMode.light),
        ),
        _ThemeChoiceChip(
          icon: Icons.dark_mode_rounded,
          label: l10n.themeDark,
          selected: selected == ThemeMode.dark,
          onTap: () => onChanged(ThemeMode.dark),
        ),
        _ThemeChoiceChip(
          icon: Icons.brightness_auto_rounded,
          label: l10n.themeSystem,
          selected: selected == ThemeMode.system,
          onTap: () => onChanged(ThemeMode.system),
        ),
      ],
    );
  }
}

class _ThemeChoiceChip extends StatelessWidget {
  const _ThemeChoiceChip({
    required this.icon,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Material(
      color: selected ? colors.primaryContainer : colors.surfaceContainerHighest,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: Responsive.valueFor(
              context,
              compact: 12,
              medium: 16,
            ),
            vertical: 12,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                size: 20,
                color: selected ? colors.primary : colors.onSurfaceVariant,
              ),
              SizedBox(width: AppSpacing.xs),
              Text(
                label,
                style: Theme.of(context).textTheme.labelLarge?.copyWith(
                      color: selected ? colors.primary : null,
                      fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                    ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
