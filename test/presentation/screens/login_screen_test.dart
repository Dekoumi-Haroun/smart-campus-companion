import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:smart_campus/core/constants/app_strings.dart';
import 'package:smart_campus/data/repositories/settings_repository.dart';
import 'package:smart_campus/domain/entities/auth_user.dart';
import 'package:smart_campus/domain/repositories/auth_repository.dart';
import 'package:smart_campus/presentation/blocs/auth/auth_cubit.dart';
import 'package:smart_campus/presentation/blocs/auth/auth_state.dart';
import 'package:smart_campus/presentation/screens/auth/login_screen.dart';

/// Fake auth repository that can be configured per test.
class FakeAuthRepository implements AuthRepository {
  bool loginShouldFail = false;

  @override
  Future<AuthUser> login(String email, String password) async {
    if (loginShouldFail) {
      throw Exception('Invalid credentials');
    }
    return AuthUser(
      email: email,
      displayName: 'Test',
      token: 'tok',
      tokenIssuedAt: DateTime.now(),
    );
  }

  @override
  Future<AuthUser?> getStoredSession() async => null;
  @override
  Future<bool> isSessionValid() async => false;
  @override
  Future<void> logout() async {}
}

void main() {
  late AuthCubit authCubit;
  late FakeAuthRepository fakeRepo;
  late SettingsRepository settingsRepo;

  setUp(() async {
    fakeRepo = FakeAuthRepository();
    SharedPreferences.setMockInitialValues({});
    settingsRepo = SettingsRepository();
    await settingsRepo.init();
    authCubit = AuthCubit(
      authRepository: fakeRepo,
      settingsRepository: settingsRepo,
    );
  });

  tearDown(() {
    authCubit.close();
  });

  Widget buildLoginScreen() {
    return MaterialApp(
      home: BlocProvider.value(value: authCubit, child: const LoginScreen()),
    );
  }

  group('LoginScreen', () {
    testWidgets('shows validation errors for empty fields', (tester) async {
      await tester.pumpWidget(buildLoginScreen());

      // Tap Sign In without entering anything.
      await tester.tap(find.text(AppStrings.loginButton));
      await tester.pumpAndSettle();

      // Both validators should fire.
      expect(find.text(AppStrings.invalidEmail), findsOneWidget);
      expect(find.text(AppStrings.invalidPassword), findsOneWidget);
    });

    testWidgets('shows validation error for invalid email format', (
      tester,
    ) async {
      await tester.pumpWidget(buildLoginScreen());

      await tester.enterText(find.byType(TextFormField).first, 'not-an-email');
      await tester.enterText(find.byType(TextFormField).last, 'password123');

      await tester.tap(find.text(AppStrings.loginButton));
      await tester.pumpAndSettle();

      expect(find.text(AppStrings.invalidEmail), findsOneWidget);
      // Password is valid, so no password error.
      expect(find.text(AppStrings.invalidPassword), findsNothing);
    });

    testWidgets('shows validation error for short password', (tester) async {
      await tester.pumpWidget(buildLoginScreen());

      await tester.enterText(find.byType(TextFormField).first, 'user@test.com');
      await tester.enterText(
        find.byType(TextFormField).last,
        '12345', // Too short (< 6 chars)
      );

      await tester.tap(find.text(AppStrings.loginButton));
      await tester.pumpAndSettle();

      expect(find.text(AppStrings.invalidEmail), findsNothing);
      expect(find.text(AppStrings.invalidPassword), findsOneWidget);
    });

    testWidgets('valid input triggers login and reaches AuthAuthenticated', (
      tester,
    ) async {
      await tester.pumpWidget(buildLoginScreen());

      await tester.enterText(
        find.byType(TextFormField).first,
        'student@smartcampus.dev',
      );
      await tester.enterText(find.byType(TextFormField).last, 'campus123');

      await tester.tap(find.text(AppStrings.loginButton));
      // Let the cubit process.
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      expect(authCubit.state, isA<AuthAuthenticated>());
    });

    testWidgets('password visibility toggle works', (tester) async {
      await tester.pumpWidget(buildLoginScreen());

      // Find the visibility toggle button.
      final toggle = find.byIcon(Icons.visibility_outlined);
      expect(toggle, findsOneWidget);

      await tester.tap(toggle);
      await tester.pump();

      // After toggling, the icon should change.
      expect(find.byIcon(Icons.visibility_off_outlined), findsOneWidget);
    });

    testWidgets('shows demo credentials hint', (tester) async {
      await tester.pumpWidget(buildLoginScreen());

      expect(find.text(AppStrings.demoCredentials), findsOneWidget);
    });
  });
}
