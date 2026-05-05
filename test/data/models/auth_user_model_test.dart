import 'package:flutter_test/flutter_test.dart';
import 'package:smart_campus/data/models/auth_user_model.dart';

void main() {
  group('AuthUserModel.fromJson', () {
    test('parses valid JSON correctly', () {
      final json = {
        'email': 'test@campus.dev',
        'displayName': 'Test User',
        'token': 'jwt_abc123',
        'issuedAt': '2026-04-01T10:00:00.000',
      };

      final model = AuthUserModel.fromJson(json);

      expect(model.email, 'test@campus.dev');
      expect(model.displayName, 'Test User');
      expect(model.token, 'jwt_abc123');
      expect(model.tokenIssuedAt, DateTime(2026, 4, 1, 10));
    });

    test('handles missing fields with defaults', () {
      final json = <String, dynamic>{};

      final model = AuthUserModel.fromJson(json);

      expect(model.email, '');
      expect(model.displayName, '');
      expect(model.token, '');
      // Falls back to DateTime.now() so year should be current or later
      expect(model.tokenIssuedAt.year, greaterThanOrEqualTo(2025));
    });

    test('handles null values gracefully', () {
      final json = <String, dynamic>{
        'email': null,
        'displayName': null,
        'token': null,
        'issuedAt': null,
      };

      final model = AuthUserModel.fromJson(json);

      expect(model.email, '');
      expect(model.displayName, '');
      expect(model.token, '');
    });

    test('handles invalid date format', () {
      final json = <String, dynamic>{
        'email': 'a@b.com',
        'displayName': 'User',
        'token': 'tok',
        'issuedAt': 'not-a-date',
      };

      final model = AuthUserModel.fromJson(json);
      // DateTime.tryParse fails, falls back to DateTime.now()
      expect(model.tokenIssuedAt.year, greaterThanOrEqualTo(2025));
    });

    test('toEntity produces correct domain entity', () {
      final model = AuthUserModel(
        email: 'x@y.com',
        displayName: 'X',
        token: 't',
        tokenIssuedAt: DateTime(2026, 6, 1),
      );

      final entity = model.toEntity();

      expect(entity.email, 'x@y.com');
      expect(entity.displayName, 'X');
      expect(entity.token, 't');
      expect(entity.tokenIssuedAt, DateTime(2026, 6, 1));
    });
  });
}
