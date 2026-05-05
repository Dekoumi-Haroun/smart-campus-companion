import 'package:flutter/material.dart';

import '../../../data/repositories/settings_repository.dart';

/// Manages the app's locale (language) using [ValueNotifier].
///
/// Persists the selected language to [SharedPreferences] via [SettingsRepository].
class LocaleCubit extends ValueNotifier<Locale> {
  final SettingsRepository _settingsRepository;

  LocaleCubit(this._settingsRepository)
    : super(_localeFromString(_settingsRepository.getLanguage()));

  void setLanguage(String lang) {
    _settingsRepository.setLanguage(lang);
    value = _localeFromString(lang);
  }

  static Locale _localeFromString(String lang) => switch (lang) {
    'French' => const Locale('fr'),
    'Arabic' => const Locale('ar'),
    _ => const Locale('en'),
  };

  /// Convenience accessor — requires an [InheritedLocaleCubit] ancestor.
  static LocaleCubit of(BuildContext context) {
    final inherited = context
        .dependOnInheritedWidgetOfExactType<InheritedLocaleCubit>();
    assert(inherited != null, 'No InheritedLocaleCubit found in context');
    return inherited!.cubit;
  }
}

/// [InheritedWidget] that provides [LocaleCubit] down the tree.
class InheritedLocaleCubit extends InheritedWidget {
  final LocaleCubit cubit;

  const InheritedLocaleCubit({
    super.key,
    required this.cubit,
    required super.child,
  });

  @override
  bool updateShouldNotify(InheritedLocaleCubit oldWidget) =>
      cubit != oldWidget.cubit;
}
