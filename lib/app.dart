import 'package:flutter/material.dart';
import 'core/constants/app_strings.dart';
import 'core/constants/app_routes.dart';
import 'core/theme/app_theme.dart';
import 'core/router.dart';
import 'presentation/blocs/theme/theme_cubit.dart';

/// Root widget of the SmartCampus app.
///
/// Responsibilities:
/// 1. Provide the [ThemeCubit] to the entire widget tree.
/// 2. Configure [MaterialApp] with theming, routing, and accessibility.
///
/// The [ThemeCubit] lives here so every screen can read and toggle the theme.
class App extends StatefulWidget {
  const App({super.key});

  @override
  State<App> createState() => _AppState();
}

class _AppState extends State<App> {
  final _themeCubit = ThemeCubit();

  @override
  void dispose() {
    _themeCubit.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return InheritedThemeCubit(
      cubit: _themeCubit,
      child: ValueListenableBuilder<ThemeMode>(
        valueListenable: _themeCubit,
        builder: (context, themeMode, _) {
          return MaterialApp(
            // ── Identity ──
            title: AppStrings.appName,
            debugShowCheckedModeBanner: false,

            // ── Theming ──
            theme: AppTheme.light,
            darkTheme: AppTheme.dark,
            themeMode: themeMode,

            // ── Routing ──
            initialRoute: AppRoutes.home,
            onGenerateRoute: AppRouter.generateRoute,
          );
        },
      ),
    );
  }
}
