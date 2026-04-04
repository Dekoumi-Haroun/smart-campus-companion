import 'package:flutter/material.dart';

/// Manages the app's theme mode (light / dark / system) using [ValueNotifier].
///
/// We use [ValueNotifier] in Sprint 1 to avoid adding BLoC as a dependency
/// before it's needed. This will be upgraded to a full Cubit in Sprint 2
/// when we add flutter_bloc for data state management.
///
/// The [ThemeCubit] is placed at the top of the widget tree (in [App])
/// and accessed by descendants via [ThemeCubit.of(context)].
class ThemeCubit extends ValueNotifier<ThemeMode> {
  ThemeCubit() : super(ThemeMode.system);

  /// Set a specific theme mode.
  void setTheme(ThemeMode mode) {
    value = mode;
  }

  /// Cycle through: system → light → dark → system …
  void cycleTheme() {
    switch (value) {
      case ThemeMode.system:
        value = ThemeMode.light;
      case ThemeMode.light:
        value = ThemeMode.dark;
      case ThemeMode.dark:
        value = ThemeMode.system;
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
    final inherited =
        context.dependOnInheritedWidgetOfExactType<InheritedThemeCubit>();
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
