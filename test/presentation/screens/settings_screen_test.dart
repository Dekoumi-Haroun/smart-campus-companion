import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:smart_campus/core/constants/app_strings.dart';
import 'package:smart_campus/data/repositories/settings_repository.dart';
import 'package:smart_campus/domain/entities/auth_user.dart';
import 'package:smart_campus/domain/repositories/auth_repository.dart';
import 'package:smart_campus/presentation/blocs/announcement/announcement_bloc.dart';
import 'package:smart_campus/presentation/blocs/announcement/announcement_event.dart';
import 'package:smart_campus/presentation/blocs/announcement/announcement_state.dart';
import 'package:smart_campus/presentation/blocs/auth/auth_cubit.dart';
import 'package:smart_campus/presentation/blocs/event/event_bloc.dart';
import 'package:smart_campus/presentation/blocs/event/event_event.dart';
import 'package:smart_campus/presentation/blocs/event/event_state.dart';
import 'package:smart_campus/presentation/blocs/theme/theme_cubit.dart';
import 'package:smart_campus/presentation/blocs/timetable/timetable_bloc.dart';
import 'package:smart_campus/presentation/blocs/timetable/timetable_event.dart';
import 'package:smart_campus/presentation/blocs/timetable/timetable_state.dart';
import 'package:smart_campus/presentation/screens/settings/settings_screen.dart';

class FakeAuthRepository implements AuthRepository {
  @override
  Future<AuthUser> login(String email, String password) async =>
      throw UnimplementedError();
  @override
  Future<AuthUser?> getStoredSession() async => null;
  @override
  Future<bool> isSessionValid() async => false;
  @override
  Future<void> logout() async {}
}

// SettingsScreen reads EventBloc inside didChangeDependencies (for its
// CacheMetricsService photoPathsProvider), and dispatches to all three
// content blocs from the Clear Cache flow. We stub them with MockBloc
// so the widget tree resolves without touching the real repositories.
class _MockEventBloc extends MockBloc<EventEvent, EventState>
    implements EventBloc {}

class _MockAnnouncementBloc
    extends MockBloc<AnnouncementEvent, AnnouncementState>
    implements AnnouncementBloc {}

class _MockTimetableBloc extends MockBloc<TimetableEvent, TimetableState>
    implements TimetableBloc {}

void main() {
  late SettingsRepository settingsRepo;
  late ThemeCubit themeCubit;
  late AuthCubit authCubit;
  late _MockEventBloc eventBloc;
  late _MockAnnouncementBloc announcementBloc;
  late _MockTimetableBloc timetableBloc;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    settingsRepo = SettingsRepository();
    await settingsRepo.init();
    themeCubit = ThemeCubit(settingsRepo);
    authCubit = AuthCubit(
      authRepository: FakeAuthRepository(),
      settingsRepository: settingsRepo,
    );

    eventBloc = _MockEventBloc();
    announcementBloc = _MockAnnouncementBloc();
    timetableBloc = _MockTimetableBloc();
    when(() => eventBloc.state).thenReturn(const EventInitial());
    when(() => announcementBloc.state).thenReturn(const AnnouncementInitial());
    when(() => timetableBloc.state).thenReturn(const TimetableInitial());
  });

  tearDown(() {
    authCubit.close();
    themeCubit.dispose();
  });

  Widget buildSettingsScreen() {
    return MultiBlocProvider(
      providers: [
        BlocProvider<AuthCubit>.value(value: authCubit),
        BlocProvider<EventBloc>.value(value: eventBloc),
        BlocProvider<AnnouncementBloc>.value(value: announcementBloc),
        BlocProvider<TimetableBloc>.value(value: timetableBloc),
      ],
      child: RepositoryProvider.value(
        value: settingsRepo,
        child: InheritedThemeCubit(
          cubit: themeCubit,
          child: ValueListenableBuilder<ThemeMode>(
            valueListenable: themeCubit,
            builder: (context, themeMode, _) {
              return MaterialApp(
                themeMode: themeMode,
                theme: ThemeData.light(),
                darkTheme: ThemeData.dark(),
                home: const SettingsScreen(),
              );
            },
          ),
        ),
      ),
    );
  }

  group('SettingsScreen', () {
    testWidgets('renders visible section headers', (tester) async {
      await tester.pumpWidget(buildSettingsScreen());
      await tester.pump();

      // Top sections are visible without scrolling.
      expect(find.text('APPEARANCE'), findsOneWidget);
      expect(find.text('NOTIFICATIONS'), findsOneWidget);
      expect(find.text('LANGUAGE'), findsOneWidget);
    });

    testWidgets('theme segmented button shows system by default', (
      tester,
    ) async {
      await tester.pumpWidget(buildSettingsScreen());
      await tester.pump();

      expect(find.text('Light'), findsOneWidget);
      expect(find.text('Dark'), findsOneWidget);
      expect(find.text('System'), findsOneWidget);
      expect(themeCubit.value, ThemeMode.system);
    });

    testWidgets('tapping Dark segment changes theme mode', (tester) async {
      await tester.pumpWidget(buildSettingsScreen());
      await tester.pump();

      await tester.tap(find.text('Dark'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      expect(themeCubit.value, ThemeMode.dark);
    });

    testWidgets('tapping Light segment changes theme mode', (tester) async {
      await tester.pumpWidget(buildSettingsScreen());
      await tester.pump();

      await tester.tap(find.text('Light'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      expect(themeCubit.value, ThemeMode.light);
    });

    testWidgets('theme persists after rebuild via SettingsRepository', (
      tester,
    ) async {
      await tester.pumpWidget(buildSettingsScreen());
      await tester.pump();

      await tester.tap(find.text('Dark'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      // Verify the setting was persisted.
      expect(settingsRepo.getThemeMode(), ThemeMode.dark);

      // A new ThemeCubit from the same repo should read dark.
      final newCubit = ThemeCubit(settingsRepo);
      expect(newCubit.value, ThemeMode.dark);
      newCubit.dispose();
    });

    testWidgets('logout button is visible after scrolling', (tester) async {
      await tester.pumpWidget(buildSettingsScreen());
      await tester.pump();

      await tester.scrollUntilVisible(
        find.text(AppStrings.logout),
        200,
        scrollable: find.byType(Scrollable).first,
      );

      expect(find.text(AppStrings.logout), findsOneWidget);
    });

    testWidgets('biometric toggle is visible in Account section', (
      tester,
    ) async {
      await tester.pumpWidget(buildSettingsScreen());
      await tester.pump();

      await tester.scrollUntilVisible(
        find.text(AppStrings.enableBiometric),
        200,
        scrollable: find.byType(Scrollable).first,
      );

      expect(find.text(AppStrings.enableBiometric), findsOneWidget);
    });
  });
}
