import '../../domain/entities/auth_user.dart';

/// Data Transfer Object for [AuthUser].
class AuthUserModel {
  final String email;
  final String displayName;
  final String token;
  final DateTime tokenIssuedAt;
  final bool isAdmin;

  const AuthUserModel({
    required this.email,
    required this.displayName,
    required this.token,
    required this.tokenIssuedAt,
    this.isAdmin = false,
  });

  factory AuthUserModel.fromJson(Map<String, dynamic> json) {
    return AuthUserModel(
      email: json['email']?.toString() ?? '',
      displayName: json['displayName']?.toString() ?? '',
      token: json['token']?.toString() ?? '',
      tokenIssuedAt:
          DateTime.tryParse(json['issuedAt']?.toString() ?? '') ??
          DateTime.now(),
      isAdmin: json['isAdmin'] == true,
    );
  }

  AuthUser toEntity() {
    return AuthUser(
      email: email,
      displayName: displayName,
      token: token,
      tokenIssuedAt: tokenIssuedAt,
      isAdmin: isAdmin,
    );
  }
}
