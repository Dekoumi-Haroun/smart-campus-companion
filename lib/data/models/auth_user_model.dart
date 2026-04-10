import '../../domain/entities/auth_user.dart';

/// Data Transfer Object for [AuthUser].
///
/// Handles JSON serialization/deserialization for the auth API response
/// and SecureStorage persistence.
class AuthUserModel {
  final String email;
  final String displayName;
  final String token;
  final DateTime tokenIssuedAt;

  const AuthUserModel({
    required this.email,
    required this.displayName,
    required this.token,
    required this.tokenIssuedAt,
  });

  /// Parse from JSON map (API response).
  factory AuthUserModel.fromJson(Map<String, dynamic> json) {
    return AuthUserModel(
      email: json['email'] ?? '',
      displayName: json['displayName'] ?? '',
      token: json['token'] ?? '',
      tokenIssuedAt:
          DateTime.tryParse(json['issuedAt'] ?? '') ?? DateTime.now(),
    );
  }

  /// Convert to domain entity.
  AuthUser toEntity() {
    return AuthUser(
      email: email,
      displayName: displayName,
      token: token,
      tokenIssuedAt: tokenIssuedAt,
    );
  }
}
