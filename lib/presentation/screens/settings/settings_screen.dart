import 'package:flutter/material.dart';
import '../../../core/constants/app_strings.dart';
import '../../blocs/theme/theme_cubit.dart';

/// Settings screen.
///
/// Groups: Appearance, Notifications, Language, Account, About.
/// Theme toggle is functional from Sprint 1. Other settings become
/// functional in later sprints (notifications in Sprint 5, auth in Sprint 6).
class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    // Access the ThemeCubit provided above in the widget tree
    final themeCubit = ThemeCubit.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text(AppStrings.settingsTitle)),
      body: ListView(
        padding: const EdgeInsets.symmetric(vertical: 8),
        children: [
          // ── Appearance Section ──
          _SectionHeader(title: AppStrings.appearance),

          // Theme mode selector — Light / Dark / System
          ValueListenableBuilder<ThemeMode>(
            valueListenable: themeCubit,
            builder: (context, themeMode, _) {
              return Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.palette_rounded,
                          color: theme.colorScheme.onSurface,
                        ),
                        const SizedBox(width: 16),
                        Text(
                          'Theme',
                          style: theme.textTheme.bodyLarge?.copyWith(
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    // Segmented button for Light / Dark / System
                    SizedBox(
                      width: double.infinity,
                      child: SegmentedButton<ThemeMode>(
                        segments: const [
                          ButtonSegment<ThemeMode>(
                            value: ThemeMode.light,
                            icon: Icon(Icons.light_mode_rounded),
                            label: Text('Light'),
                            tooltip: 'Light theme',
                          ),
                          ButtonSegment<ThemeMode>(
                            value: ThemeMode.dark,
                            icon: Icon(Icons.dark_mode_rounded),
                            label: Text('Dark'),
                            tooltip: 'Dark theme',
                          ),
                          ButtonSegment<ThemeMode>(
                            value: ThemeMode.system,
                            icon: Icon(Icons.settings_brightness_rounded),
                            label: Text('System'),
                            tooltip: 'Follow system theme',
                          ),
                        ],
                        selected: {themeMode},
                        onSelectionChanged: (selected) {
                          themeCubit.setTheme(selected.first);
                        },
                        showSelectedIcon: false,
                        style: ButtonStyle(
                          visualDensity: VisualDensity.comfortable,
                          tapTargetSize: MaterialTapTargetSize.padded,
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),

          const Divider(),

          // ── Notifications Section ──
          _SectionHeader(title: AppStrings.notifications),
          SwitchListTile(
            secondary: const Icon(Icons.notifications_rounded),
            title: const Text(AppStrings.enableNotifications),
            subtitle: Text(
              'Receive class reminders & alerts',
              style: theme.textTheme.bodySmall,
            ),
            value: true, // Placeholder — will be wired in Sprint 5
            onChanged: (value) {
              // TODO: Persist to SharedPreferences in Sprint 3
            },
          ),

          const Divider(),

          // ── Language Section ──
          _SectionHeader(title: AppStrings.language),
          ListTile(
            leading: const Icon(Icons.language_rounded),
            title: const Text(AppStrings.language),
            subtitle: Text('English', style: theme.textTheme.bodySmall),
            trailing: const Icon(Icons.chevron_right_rounded),
            onTap: () {
              // TODO: Language picker in an optional extension
            },
          ),

          const Divider(),

          // ── Account Section ──
          _SectionHeader(title: AppStrings.account),
          ListTile(
            leading: Icon(Icons.logout_rounded, color: theme.colorScheme.error),
            title: Text(
              AppStrings.logout,
              style: TextStyle(color: theme.colorScheme.error),
            ),
            onTap: () {
              // TODO: Implement logout in Sprint 6
            },
          ),

          const Divider(),

          // ── About Section ──
          _SectionHeader(title: AppStrings.about),
          ListTile(
            leading: const Icon(Icons.info_outline_rounded),
            title: const Text(AppStrings.appName),
            subtitle: Text(
              AppStrings.version,
              style: theme.textTheme.bodySmall,
            ),
          ),
        ],
      ),
    );
  }
}

/// A simple section header used in the settings list.
class _SectionHeader extends StatelessWidget {
  final String title;

  const _SectionHeader({required this.title});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 4),
      child: Text(
        title.toUpperCase(),
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
          color: Theme.of(context).colorScheme.primary,
          fontWeight: FontWeight.w700,
          letterSpacing: 1.2,
        ),
      ),
    );
  }
}
