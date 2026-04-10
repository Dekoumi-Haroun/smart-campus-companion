import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/errors/app_exceptions.dart';
import '../../../data/repositories/settings_repository.dart';
import '../../../domain/repositories/auth_repository.dart';
import 'auth_state.dart';

/// Manages authentication state: login, logout, session check, and biometrics.
class AuthCubit extends Cubit<AuthState> {
  final AuthRepository _authRepository;
  final SettingsRepository _settingsRepository;

  AuthCubit({
    required AuthRepository authRepository,
    required SettingsRepository settingsRepository,
  }) : _authRepository = authRepository,
       _settingsRepository = settingsRepository,
       super(const AuthUnknown());

  /// Check for an existing valid session on app launch.
  ///
  /// If biometric is enabled and a session exists, emits [AuthBiometricRequired]
  /// so the biometric prompt is shown before granting access.
  Future<void> checkAuthStatus() async {
    try {
      final user = await _authRepository.getStoredSession();
      if (user == null) {
        emit(const AuthUnauthenticated());
        return;
      }

      if (_settingsRepository.getBiometricEnabled()) {
        emit(AuthBiometricRequired(user));
      } else {
        emit(AuthAuthenticated(user));
      }
      // ignore: avoid_catches_without_on_clauses
    } catch (_) {
      // If secure storage is unavailable (e.g. no platform channel in tests),
      // treat as unauthenticated.
      emit(const AuthUnauthenticated());
    }
  }

  /// Authenticate with email and password.
  Future<void> login(String email, String password) async {
    emit(const AuthLoading());
    try {
      final user = await _authRepository.login(email, password);
      emit(AuthAuthenticated(user));
    } on AuthException catch (e) {
      emit(AuthFailure(e.message));
    } on NetworkException catch (e) {
      emit(AuthFailure(e.message));
    } on Exception {
      emit(const AuthFailure('An unexpected error occurred.'));
    }
  }

  /// Clear the session and return to login.
  Future<void> logout() async {
    await _authRepository.logout();
    emit(const AuthUnauthenticated());
  }

  /// Called after successful biometric verification.
  void confirmBiometric() {
    final current = state;
    if (current is AuthBiometricRequired) {
      emit(AuthAuthenticated(current.user));
    }
  }

  /// Called when user opts to skip biometric and use password instead.
  void skipBiometric() {
    emit(const AuthUnauthenticated());
  }
}
