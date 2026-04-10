import 'dart:developer' as developer;

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'core/constants/app_strings.dart';
import 'core/constants/app_routes.dart';
import 'core/theme/app_theme.dart';
import 'core/router.dart';
import 'core/services/app_lifecycle_observer.dart';
import 'core/services/notification_service.dart';
import 'data/datasources/local/announcement_local_dao.dart';
import 'data/datasources/local/event_local_dao.dart';
import 'data/datasources/local/local_database.dart';
import 'data/datasources/local/timetable_local_dao.dart';
import 'data/datasources/local/secure_storage_service.dart';
import 'data/datasources/remote/api_client.dart';
import 'data/repositories/announcement_repository_impl.dart';
import 'data/repositories/auth_repository_impl.dart';
import 'data/repositories/event_repository_impl.dart';
import 'data/repositories/settings_repository.dart';
import 'data/repositories/timetable_repository_impl.dart';
import 'presentation/blocs/announcement/announcement_bloc.dart';
import 'presentation/blocs/announcement/announcement_event.dart';
import 'presentation/blocs/auth/auth_cubit.dart';
import 'presentation/blocs/auth/auth_state.dart';
import 'presentation/blocs/event/event_bloc.dart';
import 'presentation/blocs/event/event_event.dart';
import 'presentation/blocs/timetable/timetable_bloc.dart';
import 'presentation/blocs/timetable/timetable_event.dart';
import 'presentation/blocs/connectivity/connectivity_cubit.dart';
import 'presentation/blocs/theme/theme_cubit.dart';

/// Root widget of the SmartCampus app.
///
/// Responsibilities:
/// 1. Provide the [ThemeCubit] to the entire widget tree.
/// 2. Provide data BLoCs (Announcement, Event, Timetable) via [MultiBlocProvider].
/// 3. Configure [MaterialApp] with theming, routing, and accessibility.
/// 4. Manage [AppLifecycleObserver] for background/foreground transitions.
/// 5. Handle notification deep linking.
class App extends StatefulWidget {
  final SettingsRepository settingsRepository;

  const App({super.key, required this.settingsRepository});

  @override
  State<App> createState() => _AppState();
}

class _AppState extends State<App> {
  late final ThemeCubit _themeCubit;
  final _connectivityCubit = ConnectivityCubit();
  late final SecureStorageService _secureStorageService;
  late final ApiClient _apiClient;
  late final AuthCubit _authCubit;
  late final AnnouncementBloc _announcementBloc;
  late final EventBloc _eventBloc;
  late final TimetableBloc _timetableBloc;
  late final AppLifecycleObserver _lifecycleObserver;

  /// Navigator key for deep link navigation from notification taps.
  final _navigatorKey = GlobalKey<NavigatorState>();

  @override
  void initState() {
    super.initState();
    _themeCubit = ThemeCubit(widget.settingsRepository);
    _secureStorageService = SecureStorageService();
    _apiClient = ApiClient();

    // Initialize auth.
    final authRepository = AuthRepositoryImpl(
      apiClient: _apiClient,
      secureStorage: _secureStorageService,
    );
    _authCubit = AuthCubit(
      authRepository: authRepository,
      settingsRepository: widget.settingsRepository,
    )..checkAuthStatus();

    final localDb = LocalDatabase.instance;
    final announcementDao = AnnouncementLocalDao(localDb);
    final eventDao = EventLocalDao(localDb);
    final timetableDao = TimetableLocalDao(localDb);

    _announcementBloc = AnnouncementBloc(
      repository: AnnouncementRepositoryImpl(
        apiClient: _apiClient,
        localDao: announcementDao,
      ),
    )..add(const FetchAnnouncements());

    _eventBloc = EventBloc(
      repository: EventRepositoryImpl(
        apiClient: _apiClient,
        localDao: eventDao,
      ),
    )..add(const FetchEvents());

    _timetableBloc = TimetableBloc(
      repository: TimetableRepositoryImpl(
        apiClient: _apiClient,
        localDao: timetableDao,
      ),
    )..add(const FetchTimetable());

    // Set up lifecycle observer.
    _lifecycleObserver = AppLifecycleObserver(
      announcementBloc: _announcementBloc,
      authCubit: _authCubit,
    );
    WidgetsBinding.instance.addObserver(_lifecycleObserver);
    _lifecycleObserver.markDataFresh();

    // Wire notification tap handler for deep linking.
    NotificationService.instance.onNotificationTap = _handleNotificationTap;
  }

  void _handleNotificationTap(String? payload) {
    if (payload == null) return;
    developer.log('Deep link from notification: $payload', name: 'DeepLink');

    final navigator = _navigatorKey.currentState;
    if (navigator == null) return;

    if (payload.startsWith('timetable:')) {
      final itemId = payload.replaceFirst('timetable:', '');
      navigator.pushNamed(AppRoutes.timetableDetail, arguments: itemId);
    } else if (payload == 'announcements') {
      // Navigate to main shell and switch to announcements tab.
      navigator.pushNamed(
        AppRoutes.home,
        arguments: 1, // Announcements tab index
      );
    }
  }

  @override
  void dispose() {
    _lifecycleObserver.dispose();
    _connectivityCubit.close();
    _authCubit.close();
    _announcementBloc.close();
    _eventBloc.close();
    _timetableBloc.close();
    _themeCubit.dispose();
    NotificationService.instance.onNotificationTap = null;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider.value(value: _connectivityCubit),
        BlocProvider.value(value: _authCubit),
        BlocProvider.value(value: _announcementBloc),
        BlocProvider.value(value: _eventBloc),
        BlocProvider.value(value: _timetableBloc),
      ],
      child: MultiRepositoryProvider(
        providers: [
          RepositoryProvider.value(value: widget.settingsRepository),
          RepositoryProvider.value(value: _secureStorageService),
        ],
        child: InheritedThemeCubit(
          cubit: _themeCubit,
          child: ValueListenableBuilder<ThemeMode>(
            valueListenable: _themeCubit,
            builder: (context, themeMode, _) {
              return BlocBuilder<AuthCubit, AuthState>(
                builder: (context, authState) {
                  // Show loading splash while checking stored session.
                  if (authState is AuthUnknown) {
                    return MaterialApp(
                      title: AppStrings.appName,
                      debugShowCheckedModeBanner: false,
                      theme: AppTheme.light,
                      darkTheme: AppTheme.dark,
                      themeMode: themeMode,
                      home: const Scaffold(
                        body: Center(child: CircularProgressIndicator()),
                      ),
                    );
                  }

                  final String initialRoute;
                  if (authState is AuthAuthenticated) {
                    initialRoute = AppRoutes.home;
                  } else if (authState is AuthBiometricRequired) {
                    initialRoute = AppRoutes.biometricPrompt;
                  } else {
                    initialRoute = AppRoutes.login;
                  }

                  return MaterialApp(
                    // Force rebuild when auth state changes route.
                    key: ValueKey(initialRoute),

                    // ── Identity ──
                    title: AppStrings.appName,
                    debugShowCheckedModeBanner: false,

                    // ── Theming ──
                    theme: AppTheme.light,
                    darkTheme: AppTheme.dark,
                    themeMode: themeMode,

                    // ── Routing ──
                    navigatorKey: _navigatorKey,
                    initialRoute: initialRoute,
                    onGenerateRoute: AppRouter.generateRoute,
                  );
                },
              );
            },
          ),
        ),
      ),
    );
  }
}
