import 'package:flutter/material.dart';

import '../../../data/repositories/settings_repository.dart';

/// Manages the app's theme mode (light / dark / system) using [ValueNotifier].
///
/// Persists the selected theme to [SharedPreferences] via [SettingsRepository].
class ThemeCubit extends ValueNotifier<ThemeMode> {
  final SettingsRepository _settingsRepository;

  ThemeCubit(this._settingsRepository)
    : super(_settingsRepository.getThemeMode());

  /// Set a specific theme mode and persist it.
  void setTheme(ThemeMode mode) {
    value = mode;
    _settingsRepository.setThemeMode(mode);
  }

  /// Cycle through: system → light → dark → system …
  void cycleTheme() {
    switch (value) {
      case ThemeMode.system:
        setTheme(ThemeMode.light);
      case ThemeMode.light:
        setTheme(ThemeMode.dark);
      case ThemeMode.dark:
        setTheme(ThemeMode.system);
    }
  }

  /// Whether the current mode is dark.
  bool get isDark => value == ThemeMode.dark;

  /// Whether the current mode follows the system setting.
  bool get isSystem => value == ThemeMode.system;

  /// Human-readable label for the current mode.
  String get label => switch (value) {
    ThemeMode.light => 'Light',
    ThemeMode.dark => 'Dark',
    ThemeMode.system => 'System',
  };

  /// Convenience accessor to get the [ThemeCubit] from the widget tree.
  ///
  /// Requires that an [InheritedThemeCubit] ancestor exists.
  static ThemeCubit of(BuildContext context) {
    final inherited = context
        .dependOnInheritedWidgetOfExactType<InheritedThemeCubit>();
    assert(inherited != null, 'No InheritedThemeCubit found in context');
    return inherited!.cubit;
  }
}

/// [InheritedWidget] that provides [ThemeCubit] down the tree.
class InheritedThemeCubit extends InheritedWidget {
  final ThemeCubit cubit;

  const InheritedThemeCubit({
    super.key,
    required this.cubit,
    required super.child,
  });

  @override
  bool updateShouldNotify(InheritedThemeCubit oldWidget) {
    return cubit != oldWidget.cubit;
  }
}
