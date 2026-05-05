import '../entities/auth_user.dart';

/// Contract for authentication operations.
abstract class AuthRepository {
  /// Authenticate with email and password, returning the user session.
  Future<AuthUser> login(String email, String password);

  /// Retrieve a previously stored session, or null if none/expired.
  Future<AuthUser?> getStoredSession();

  /// Check whether the stored token is still within its validity window.
  Future<bool> isSessionValid();

  /// Clear all stored credentials and session data.
  Future<void> logout();
}
