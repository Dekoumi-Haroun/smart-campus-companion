import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/constants/app_routes.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/services/background_task_service.dart';
import '../../../core/services/biometric_service.dart';
import '../../../core/services/bluetooth_service.dart';
import '../../../core/services/cache_metrics_service.dart';
import '../../../core/services/feature_permission_service.dart';
import '../../../core/services/notification_service.dart';
import '../../../core/services/permission_service.dart';
import '../../../data/repositories/settings_repository.dart';
import '../../blocs/announcement/announcement_bloc.dart';
import '../../blocs/announcement/announcement_event.dart';
import '../../blocs/auth/auth_cubit.dart';
import '../../blocs/auth/auth_state.dart';
import '../../blocs/event/event_bloc.dart';
import '../../blocs/event/event_event.dart';
import '../../blocs/event/event_state.dart';
import '../../blocs/locale/locale_cubit.dart';
import '../../blocs/theme/theme_cubit.dart';
import '../../blocs/timetable/timetable_bloc.dart';
import '../../blocs/timetable/timetable_event.dart';
import 'widgets/permissions_section.dart';
import 'widgets/storage_section.dart';

/// Settings screen.
///
/// Groups: Admin Panel (conditional, pinned to top), Appearance,
/// Notifications, Language, Device Features, Storage & Data, Permissions,
/// Account, About.
///
/// Theme / notifications / language / biometric / Bluetooth-opt-in are
/// persisted via [SettingsRepository]. The Storage card reads live cache
/// metrics from SQLite; the Permissions card reads live status from
/// `permission_handler`.
class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen>
    with WidgetsBindingObserver {
  late SettingsRepository _settingsRepo;
  late bool _notificationsEnabled;
  late String _language;
  late bool _biometricEnabled;
  late bool _bluetoothEnabled;

  final BluetoothService _bluetoothService = const BluetoothService();
  final BiometricService _biometricService = BiometricService();
  final PermissionService _permissionService = const PermissionService();

  late CacheMetricsService _cacheMetrics;
  late FeaturePermissionService _featureService;

  // The Notifications and Bluetooth switches — and OS-level settings
  // changes the user may make while the app is backgrounded — mutate
  // the same flags the Permissions card reads. We drive refreshes via
  // this key so the card re-queries without being torn down (which
  // would wipe the currently-expanded row).
  final GlobalKey<PermissionsSectionState> _permissionsKey = GlobalKey();
  bool _didInit = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // On resume the user may have flipped an OS-level permission from
    // system settings — re-read without rebuilding the widget tree.
    if (state == AppLifecycleState.resumed && mounted) {
      _permissionsKey.currentState?.refreshExternally();
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_didInit) return;
    _didInit = true;

    _settingsRepo = RepositoryProvider.of<SettingsRepository>(context);
    _notificationsEnabled = _settingsRepo.getNotificationsEnabled();
    _language = _settingsRepo.getLanguage();
    _biometricEnabled = _settingsRepo.getBiometricEnabled();
    _bluetoothEnabled = _settingsRepo.getBluetoothEnabled();

    // Photos live outside SQLite — feed the service a provider that
    // reads current EventBloc state so the Images bucket is always
    // accurate without extra caching.
    final eventBloc = context.read<EventBloc>();
    _cacheMetrics = CacheMetricsService(
      settings: _settingsRepo,
      photoPathsProvider: () {
        final state = eventBloc.state;
        if (state is! EventLoaded) return const <String>[];
        return state.events
            .where((e) => e.photoPath != null)
            .map((e) => e.photoPath!)
            .toList();
      },
    );
    _featureService = FeaturePermissionService(
      settings: _settingsRepo,
      permissions: _permissionService,
      bluetooth: _bluetoothService,
    );
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
          // ───────────────────────────── Admin ──────────────────────────────
          // Pinned to the top so admins land directly on the entry point
          // to manage announcements, events, and timetable. Collapses to
          // zero height for non-admin users.
          BlocBuilder<AuthCubit, AuthState>(
            builder: (context, authState) {
              if (authState is! AuthAuthenticated || !authState.user.isAdmin) {
                return const SizedBox.shrink();
              }
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _SectionHeader(title: AppStrings.adminPanel),
                  ListTile(
                    leading: Icon(
                      Icons.admin_panel_settings_rounded,
                      color: theme.colorScheme.primary,
                    ),
                    title: Text(
                      AppStrings.adminPanel,
                      style: TextStyle(
                        color: theme.colorScheme.primary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    subtitle: Text(
                      'Manage announcements, events & timetable',
                      style: theme.textTheme.bodySmall,
                    ),
                    trailing: const Icon(Icons.chevron_right_rounded),
                    onTap: () =>
                        Navigator.pushNamed(context, AppRoutes.adminDashboard),
                  ),
                  const Divider(),
                ],
              );
            },
          ),

          // ─────────────────────────── Appearance ───────────────────────────
          _SectionHeader(title: AppStrings.appearance),
          _ThemeSelector(themeCubit: themeCubit),

          const Divider(),

          // ────────────────────────── Notifications ─────────────────────────
          _SectionHeader(title: AppStrings.notifications),
          SwitchListTile(
            secondary: const Icon(Icons.notifications_rounded),
            title: const Text(AppStrings.enableNotifications),
            subtitle: Text(
              'Receive class reminders & alerts',
              style: theme.textTheme.bodySmall,
            ),
            value: _notificationsEnabled,
            onChanged: _onNotificationsChanged,
          ),

          const Divider(),

          // ──────────────────────────── Language ────────────────────────────
          _SectionHeader(title: AppStrings.language),
          ListTile(
            leading: const Icon(Icons.language_rounded),
            title: const Text(AppStrings.language),
            subtitle: Text(_language, style: theme.textTheme.bodySmall),
            trailing: const Icon(Icons.chevron_right_rounded),
            onTap: () => _showLanguagePicker(context),
          ),

          const Divider(),

          // ─────────────────────── Device Features ──────────────────────────
          _SectionHeader(title: AppStrings.deviceFeatures),
          SwitchListTile(
            secondary: const Icon(Icons.bluetooth_rounded),
            title: const Text(AppStrings.bluetooth),
            subtitle: Text(
              AppStrings.bluetoothEnabledSubtitle,
              style: theme.textTheme.bodySmall,
            ),
            value: _bluetoothEnabled,
            onChanged: _onBluetoothToggle,
          ),
          ListTile(
            leading: const Icon(Icons.nfc_rounded),
            title: const Text(AppStrings.nfc),
            subtitle: Text(
              AppStrings.nfcConceptual,
              style: theme.textTheme.bodySmall,
            ),
            trailing: const Icon(Icons.info_outline_rounded),
            onTap: () => _showNfcDialog(context),
          ),

          const Divider(),

          // ─────────────────────── Storage & Data ───────────────────────────
          _SectionHeader(title: AppStrings.storageAndData),
          StorageSection(
            service: _cacheMetrics,
            onCacheCleared: _refetchAllData,
          ),

          const Divider(),

          // ─────────────────────────── Permissions ──────────────────────────
          _SectionHeader(title: AppStrings.permissionsSection),
          PermissionsSection(
            key: _permissionsKey,
            service: _featureService,
            onChanged: _onFeatureChanged,
          ),

          const Divider(),

          // ─────────────────────────── Account ──────────────────────────────
          _SectionHeader(title: AppStrings.account),
          SwitchListTile(
            secondary: const Icon(Icons.fingerprint_rounded),
            title: const Text(AppStrings.enableBiometric),
            subtitle: Text(
              AppStrings.biometricLoginDescription,
              style: theme.textTheme.bodySmall,
            ),
            value: _biometricEnabled,
            onChanged: _onBiometricToggle,
          ),
          ListTile(
            leading: Icon(Icons.logout_rounded, color: theme.colorScheme.error),
            title: Text(
              AppStrings.logout,
              style: TextStyle(color: theme.colorScheme.error),
            ),
            onTap: () => _showLogoutDialog(context),
          ),

          const Divider(),

          // ──────────────────────────── About ───────────────────────────────
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

  // ══════════════════════════ Handlers ══════════════════════════════════════

  /// The permissions card changed something — re-read the flags that
  /// drive the adjacent Notifications/Bluetooth switches so they stay
  /// consistent with whatever the user just did in the expanded row.
  ///
  /// We deliberately do NOT refresh the Permissions card here: it has
  /// already re-queried internally as part of its own action handler,
  /// and rebuilding it from the outside would collapse the row the
  /// user just interacted with.
  void _onFeatureChanged() {
    if (!mounted) return;
    setState(() {
      _notificationsEnabled = _settingsRepo.getNotificationsEnabled();
      _bluetoothEnabled = _settingsRepo.getBluetoothEnabled();
    });
  }

  Future<void> _onNotificationsChanged(bool value) async {
    setState(() => _notificationsEnabled = value);
    await _settingsRepo.setNotificationsEnabled(value);

    if (value) {
      // Stamp the sticky "has been prompted" flag so the Permissions
      // card can differentiate Denied from Not Requested afterwards.
      await _settingsRepo.setNotificationsRequested(true);
      await NotificationService.instance.requestPermission();
      await BackgroundTaskService.instance.registerPeriodicFetch();
    } else {
      await NotificationService.instance.cancelAll();
      await BackgroundTaskService.instance.cancelAll();
    }
    if (!mounted) return;
    _permissionsKey.currentState?.refreshExternally();
  }

  /// Bluetooth toggle:
  ///   - OFF→ON:  stamp "requested once" *then* prompt. If not granted,
  ///              revert the switch and surface the reason (settings
  ///              link for permanentlyDenied, snackbar otherwise).
  ///   - ON→OFF:  no prompt — just flip the app-level opt-in off.
  Future<void> _onBluetoothToggle(bool value) async {
    final messenger = ScaffoldMessenger.of(context);

    if (!value) {
      setState(() => _bluetoothEnabled = false);
      await _settingsRepo.setBluetoothEnabled(false);
      messenger.showSnackBar(
        const SnackBar(
          content: Text(AppStrings.bluetoothDeactivated),
          behavior: SnackBarBehavior.floating,
          duration: Duration(seconds: 2),
        ),
      );
      if (!mounted) return;
      _permissionsKey.currentState?.refreshExternally();
      return;
    }

    // Turning ON — mark as "has been prompted at least once" so the
    // Permissions row transitions from "Not Requested" → "Granted/Denied".
    await _settingsRepo.setBluetoothRequested(true);
    final status = await _bluetoothService.requestPermission();
    if (!mounted) return;

    switch (status) {
      case BluetoothStatus.available:
        setState(() => _bluetoothEnabled = true);
        await _settingsRepo.setBluetoothEnabled(true);
        messenger.showSnackBar(
          const SnackBar(
            content: Text(AppStrings.bluetoothActivated),
            behavior: SnackBarBehavior.floating,
            duration: Duration(seconds: 2),
          ),
        );
      case BluetoothStatus.permissionDenied:
        setState(() => _bluetoothEnabled = false);
        await _settingsRepo.setBluetoothEnabled(false);
        if (!mounted) return;
        _showBluetoothDeniedDialog();
      case BluetoothStatus.unavailable:
        setState(() => _bluetoothEnabled = false);
        await _settingsRepo.setBluetoothEnabled(false);
        messenger.showSnackBar(
          const SnackBar(
            content: Text(AppStrings.bluetoothUnavailable),
            behavior: SnackBarBehavior.floating,
            duration: Duration(seconds: 2),
          ),
        );
    }
    if (!mounted) return;
    _permissionsKey.currentState?.refreshExternally();
  }

  Future<void> _onBiometricToggle(bool value) async {
    final messenger = ScaffoldMessenger.of(context);
    if (value) {
      final available = await _biometricService.isAvailable();
      if (!available) {
        if (!mounted) return;
        messenger.showSnackBar(
          const SnackBar(
            content: Text(AppStrings.biometricNotAvailable),
            behavior: SnackBarBehavior.floating,
          ),
        );
        return;
      }
    }
    setState(() => _biometricEnabled = value);
    await _settingsRepo.setBiometricEnabled(value);
  }

  /// After Clear Cache, trigger fresh fetches on each bloc so the app
  /// shows real data again instead of empty lists.
  void _refetchAllData() {
    if (!mounted) return;
    context.read<AnnouncementBloc>().add(const FetchAnnouncements());
    context.read<EventBloc>().add(const FetchEvents());
    context.read<TimetableBloc>().add(const FetchTimetable());
  }

  // ══════════════════════════ Dialogs ═══════════════════════════════════════

  void _showLanguagePicker(BuildContext context) {
    final localeCubit = LocaleCubit.of(context);
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
      if (!mounted) return;
      if (selected != null && selected != _language) {
        setState(() => _language = selected);
        localeCubit.setLanguage(selected);
      }
    });
  }

  void _showBluetoothDeniedDialog() {
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
          content: const Text(AppStrings.bluetoothDeniedBody),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext);
                _permissionService.openSettings();
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

  void _showLogoutDialog(BuildContext context) {
    final theme = Theme.of(context);
    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          title: const Text(AppStrings.logoutConfirmTitle),
          content: const Text(AppStrings.logoutConfirmMessage),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text(AppStrings.cancel),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(ctx);
                context.read<AuthCubit>().logout();
              },
              child: Text(
                AppStrings.logout,
                style: TextStyle(color: theme.colorScheme.error),
              ),
            ),
          ],
        );
      },
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// THEME SELECTOR (extracted so the build() above stays readable)
// ═══════════════════════════════════════════════════════════════════════════

class _ThemeSelector extends StatelessWidget {
  final ThemeCubit themeCubit;

  const _ThemeSelector({required this.themeCubit});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return ValueListenableBuilder<ThemeMode>(
      valueListenable: themeCubit,
      builder: (context, themeMode, _) {
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
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
                  onSelectionChanged: (selected) =>
                      themeCubit.setTheme(selected.first),
                  showSelectedIcon: false,
                  style: const ButtonStyle(
                    visualDensity: VisualDensity.comfortable,
                    tapTargetSize: MaterialTapTargetSize.padded,
                  ),
                ),
              ),
            ],
          ),
        );
      },
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
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 6),
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
