import 'package:equatable/equatable.dart';

import '../../../domain/entities/auth_user.dart';

abstract class AuthState extends Equatable {
  const AuthState();

  @override
  List<Object?> get props => [];
}

/// Initial state — checking stored session.
class AuthUnknown extends AuthState {
  const AuthUnknown();
}

/// Login or session check in progress.
class AuthLoading extends AuthState {
  const AuthLoading();
}

/// User is authenticated with a valid session.
class AuthAuthenticated extends AuthState {
  final AuthUser user;

  const AuthAuthenticated(this.user);

  @override
  List<Object?> get props => [user];
}

/// No valid session — show login screen.
class AuthUnauthenticated extends AuthState {
  const AuthUnauthenticated();
}

/// Valid session exists but biometric verification is required.
class AuthBiometricRequired extends AuthState {
  final AuthUser user;

  const AuthBiometricRequired(this.user);

  @override
  List<Object?> get props => [user];
}

/// Login attempt failed.
class AuthFailure extends AuthState {
  final String message;

  const AuthFailure(this.message);

  @override
  List<Object?> get props => [message];
}
