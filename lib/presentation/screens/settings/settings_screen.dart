import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/constants/app_strings.dart';
import '../../../core/services/background_task_service.dart';
import '../../../core/services/bluetooth_service.dart';
import '../../../core/services/notification_service.dart';
import '../../../core/services/permission_service.dart';
import '../../../data/repositories/settings_repository.dart';
import '../../blocs/theme/theme_cubit.dart';

/// Settings screen.
///
/// Groups: Appearance, Notifications, Language, Account, About.
/// Theme, notifications, and language are persisted via [SettingsRepository].
class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  late final SettingsRepository _settingsRepo;
  late bool _notificationsEnabled;
  late String _language;
  final BluetoothService _bluetoothService = const BluetoothService();
  BluetoothStatus _bluetoothStatus = BluetoothStatus.unavailable;
  bool _bluetoothChecked = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _settingsRepo = RepositoryProvider.of<SettingsRepository>(context);
    _notificationsEnabled = _settingsRepo.getNotificationsEnabled();
    _language = _settingsRepo.getLanguage();
    if (!_bluetoothChecked) {
      _checkBluetooth();
    }
  }

  Future<void> _checkBluetooth() async {
    _bluetoothChecked = true;
    final status = await _bluetoothService.checkStatus();
    if (mounted) {
      setState(() => _bluetoothStatus = status);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
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
            value: _notificationsEnabled,
            onChanged: (value) async {
              setState(() {
                _notificationsEnabled = value;
              });
              await _settingsRepo.setNotificationsEnabled(value);

              if (value) {
                // Re-enable: request permission and restart background tasks.
                await NotificationService.instance.requestPermission();
                await BackgroundTaskService.instance.registerPeriodicFetch();
              } else {
                // Disable: cancel all pending notifications and background tasks.
                await NotificationService.instance.cancelAll();
                await BackgroundTaskService.instance.cancelAll();
              }
            },
          ),

          const Divider(),

          // ── Language Section ──
          _SectionHeader(title: AppStrings.language),
          ListTile(
            leading: const Icon(Icons.language_rounded),
            title: const Text(AppStrings.language),
            subtitle: Text(_language, style: theme.textTheme.bodySmall),
            trailing: const Icon(Icons.chevron_right_rounded),
            onTap: () => _showLanguagePicker(context),
          ),

          const Divider(),

          // ── Device Features Section ──
          _SectionHeader(title: AppStrings.deviceFeatures),

          // Bluetooth status
          ListTile(
            leading: const Icon(Icons.bluetooth_rounded),
            title: const Text(AppStrings.bluetooth),
            trailing: _BluetoothChip(status: _bluetoothStatus),
            onTap: () => _onBluetoothTap(),
          ),

          // NFC conceptual
          ListTile(
            leading: const Icon(Icons.nfc_rounded),
            title: const Text(AppStrings.nfc),
            trailing: Chip(
              label: Text(
                AppStrings.nfcConceptual,
                style: TextStyle(
                  fontSize: 11,
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                ),
              ),
              visualDensity: VisualDensity.compact,
            ),
            onTap: () => _showNfcDialog(context),
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

  void _showLanguagePicker(BuildContext context) {
    showDialog<String>(
      context: context,
      builder: (context) {
        return SimpleDialog(
          title: const Text('Select Language'),
          children: ['English', 'French', 'Arabic'].map((lang) {
            return SimpleDialogOption(
              onPressed: () => Navigator.pop(context, lang),
              child: Text(lang),
            );
          }).toList(),
        );
      },
    ).then((selected) {
      if (selected != null && selected != _language) {
        setState(() {
          _language = selected;
        });
        _settingsRepo.setLanguage(selected);
      }
    });
  }

  Future<void> _onBluetoothTap() async {
    if (_bluetoothStatus != BluetoothStatus.available) {
      final status = await _bluetoothService.requestPermission();
      if (!mounted) return;
      setState(() => _bluetoothStatus = status);
    }
    if (!mounted) return;
    _showBluetoothDialog(context);
  }

  void _showBluetoothDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Row(
            children: [
              Icon(Icons.bluetooth_rounded),
              SizedBox(width: 8),
              Text(AppStrings.bluetooth),
            ],
          ),
          content: Text(
            _bluetoothStatus == BluetoothStatus.permissionDenied
                ? '${AppStrings.bluetoothDescription}\n\n${AppStrings.permissionPermanentlyDenied}'
                : AppStrings.bluetoothDescription,
          ),
          actions: [
            if (_bluetoothStatus == BluetoothStatus.permissionDenied)
              TextButton(
                onPressed: () {
                  Navigator.pop(dialogContext);
                  const PermissionService().openSettings();
                },
                child: const Text(AppStrings.openSettings),
              ),
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }

  void _showNfcDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Row(
            children: [
              Icon(Icons.nfc_rounded),
              SizedBox(width: 8),
              Text(AppStrings.nfc),
            ],
          ),
          content: const Text(AppStrings.nfcDescription),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }
}

// ═══════════════════════════════════════════════════════════════════
// BLUETOOTH STATUS CHIP
// ═══════════════════════════════════════════════════════════════════

class _BluetoothChip extends StatelessWidget {
  final BluetoothStatus status;

  const _BluetoothChip({required this.status});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final (label, color) = switch (status) {
      BluetoothStatus.available => (
        AppStrings.bluetoothAvailable,
        Colors.green,
      ),
      BluetoothStatus.unavailable => (
        AppStrings.bluetoothUnavailable,
        theme.colorScheme.onSurface.withValues(alpha: 0.4),
      ),
      BluetoothStatus.permissionDenied => (
        AppStrings.permissionDeniedTitle,
        theme.colorScheme.error,
      ),
    };

    return Chip(
      label: Text(label, style: TextStyle(fontSize: 11, color: color)),
      visualDensity: VisualDensity.compact,
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
