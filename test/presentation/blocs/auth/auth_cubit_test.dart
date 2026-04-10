import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:smart_campus/core/errors/app_exceptions.dart';
import 'package:smart_campus/data/repositories/settings_repository.dart';
import 'package:smart_campus/domain/entities/auth_user.dart';
import 'package:smart_campus/domain/repositories/auth_repository.dart';
import 'package:smart_campus/presentation/blocs/auth/auth_cubit.dart';
import 'package:smart_campus/presentation/blocs/auth/auth_state.dart';

/// A fake [AuthRepository] for testing.
class FakeAuthRepository implements AuthRepository {
  AuthUser? storedUser;
  bool loginShouldFail = false;
  String loginError = 'Invalid email or password.';

  @override
  Future<AuthUser> login(String email, String password) async {
    if (loginShouldFail) throw AuthException(loginError);
    final user = AuthUser(
      email: email,
      displayName: 'Test User',
      token: 'mock_token',
      tokenIssuedAt: DateTime.now(),
    );
    storedUser = user;
    return user;
  }

  @override
  Future<AuthUser?> getStoredSession() async => storedUser;

  @override
  Future<bool> isSessionValid() async => storedUser != null;

  @override
  Future<void> logout() async {
    storedUser = null;
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late FakeAuthRepository fakeRepo;
  late SettingsRepository settingsRepo;
  late AuthCubit cubit;

  setUp(() async {
    fakeRepo = FakeAuthRepository();
    SharedPreferences.setMockInitialValues({});
    settingsRepo = SettingsRepository();
    await settingsRepo.init();
  });

  tearDown(() {
    cubit.close();
  });

  AuthCubit createCubit() {
    cubit = AuthCubit(
      authRepository: fakeRepo,
      settingsRepository: settingsRepo,
    );
    return cubit;
  }

  group('AuthCubit', () {
    test('initial state is AuthUnknown', () {
      final c = createCubit();
      expect(c.state, const AuthUnknown());
    });

    test('checkAuthStatus emits AuthUnauthenticated when no session', () async {
      final c = createCubit();
      await c.checkAuthStatus();
      expect(c.state, const AuthUnauthenticated());
    });

    test(
      'checkAuthStatus emits AuthAuthenticated when session exists',
      () async {
        fakeRepo.storedUser = AuthUser(
          email: 'test@test.com',
          displayName: 'Test',
          token: 'tok',
          tokenIssuedAt: DateTime.now(),
        );
        final c = createCubit();
        await c.checkAuthStatus();
        expect(c.state, isA<AuthAuthenticated>());
      },
    );

    test(
      'checkAuthStatus emits AuthBiometricRequired when biometric enabled + session exists',
      () async {
        fakeRepo.storedUser = AuthUser(
          email: 'test@test.com',
          displayName: 'Test',
          token: 'tok',
          tokenIssuedAt: DateTime.now(),
        );
        await settingsRepo.setBiometricEnabled(true);
        final c = createCubit();
        await c.checkAuthStatus();
        expect(c.state, isA<AuthBiometricRequired>());
      },
    );

    test('login with valid credentials emits AuthAuthenticated', () async {
      final c = createCubit();
      await c.login('student@smartcampus.dev', 'campus123');
      expect(c.state, isA<AuthAuthenticated>());
      final authState = c.state as AuthAuthenticated;
      expect(authState.user.email, 'student@smartcampus.dev');
    });

    test('login with invalid credentials emits AuthFailure', () async {
      fakeRepo.loginShouldFail = true;
      final c = createCubit();
      await c.login('wrong@email.com', 'bad');
      expect(c.state, isA<AuthFailure>());
      final failState = c.state as AuthFailure;
      expect(failState.message, 'Invalid email or password.');
    });

    test('logout emits AuthUnauthenticated and clears session', () async {
      final c = createCubit();
      await c.login('student@smartcampus.dev', 'campus123');
      expect(c.state, isA<AuthAuthenticated>());

      await c.logout();
      expect(c.state, const AuthUnauthenticated());
      expect(fakeRepo.storedUser, isNull);
    });

    test(
      'confirmBiometric transitions from BiometricRequired to Authenticated',
      () async {
        fakeRepo.storedUser = AuthUser(
          email: 'test@test.com',
          displayName: 'Test',
          token: 'tok',
          tokenIssuedAt: DateTime.now(),
        );
        await settingsRepo.setBiometricEnabled(true);
        final c = createCubit();
        await c.checkAuthStatus();
        expect(c.state, isA<AuthBiometricRequired>());

        c.confirmBiometric();
        expect(c.state, isA<AuthAuthenticated>());
      },
    );

    test(
      'skipBiometric transitions from BiometricRequired to Unauthenticated',
      () async {
        fakeRepo.storedUser = AuthUser(
          email: 'test@test.com',
          displayName: 'Test',
          token: 'tok',
          tokenIssuedAt: DateTime.now(),
        );
        await settingsRepo.setBiometricEnabled(true);
        final c = createCubit();
        await c.checkAuthStatus();
        expect(c.state, isA<AuthBiometricRequired>());

        c.skipBiometric();
        expect(c.state, const AuthUnauthenticated());
      },
    );
  });
}
