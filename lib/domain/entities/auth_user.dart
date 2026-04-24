import 'package:equatable/equatable.dart';

/// Represents an authenticated user session.
class AuthUser extends Equatable {
  final String email;
  final String displayName;
  final String token;
  final DateTime tokenIssuedAt;
  final bool isAdmin;

  const AuthUser({
    required this.email,
    required this.displayName,
    required this.token,
    required this.tokenIssuedAt,
    this.isAdmin = false,
  });

  @override
  List<Object?> get props => [email, displayName, token, tokenIssuedAt, isAdmin];
}
