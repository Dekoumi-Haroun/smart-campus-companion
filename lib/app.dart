import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'core/constants/app_strings.dart';
import 'core/constants/app_routes.dart';
import 'core/theme/app_theme.dart';
import 'core/router.dart';
import 'data/datasources/local/announcement_local_dao.dart';
import 'data/datasources/local/event_local_dao.dart';
import 'data/datasources/local/local_database.dart';
import 'data/datasources/local/timetable_local_dao.dart';
import 'data/datasources/local/secure_storage_service.dart';
import 'data/datasources/remote/api_client.dart';
import 'data/repositories/announcement_repository_impl.dart';
import 'data/repositories/event_repository_impl.dart';
import 'data/repositories/settings_repository.dart';
import 'data/repositories/timetable_repository_impl.dart';
import 'presentation/blocs/announcement/announcement_bloc.dart';
import 'presentation/blocs/announcement/announcement_event.dart';
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
  late final AnnouncementBloc _announcementBloc;
  late final EventBloc _eventBloc;
  late final TimetableBloc _timetableBloc;

  @override
  void initState() {
    super.initState();
    _themeCubit = ThemeCubit(widget.settingsRepository);
    _secureStorageService = SecureStorageService();
    _apiClient = ApiClient();

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
  }

  @override
  void dispose() {
    _connectivityCubit.close();
    _announcementBloc.close();
    _eventBloc.close();
    _timetableBloc.close();
    _themeCubit.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider.value(value: _connectivityCubit),
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
        ),
      ),
    );
  }
}
