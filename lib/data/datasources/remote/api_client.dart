import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

import 'mock_data.dart';

// ══════════════════════════════════════════════════════════════════
// OWASP Mobile Security Considerations:
// 1. HTTPS Only: BaseOptions uses https:// scheme exclusively.
//    In production, enforce certificate pinning via Dio's
//    SecurityContext or a native plugin (e.g. ssl_pinning_plugin).
// 2. No Sensitive Data in Logs: LogInterceptor has requestBody: false
//    to avoid logging credentials. In production, disable
//    responseBody logging as well.
// 3. No Hardcoded Secrets: API keys and tokens are stored in
//    FlutterSecureStorage, never in source code. The mock JWT is
//    for development only.
// 4. Input Sanitization: All user input is validated at the form
//    level before being sent to the API.
// 5. Certificate Pinning (concept): In production, add a custom
//    SecurityContext with pinned certificates to Dio's HttpClient.
// ══════════════════════════════════════════════════════════════════

/// Centralized HTTP client for all API communication.
///
/// Configured with proper timeouts, logging, and error handling.
/// During development, a [MockInterceptor] returns hardcoded JSON
/// responses so the app works fully offline.
class ApiClient {
  late final Dio _dio;

  ApiClient({String baseUrl = 'https://api.smartcampus.dev/v1'}) {
    _dio = Dio(
      BaseOptions(
        baseUrl: baseUrl,
        connectTimeout: const Duration(seconds: 10),
        receiveTimeout: const Duration(seconds: 15),
      ),
    );

    _dio.interceptors.addAll([
      MockInterceptor(),
      LogInterceptor(
        requestBody: false,
        responseBody: true,
        logPrint: (obj) => debugPrint('[API] $obj'),
      ),
      ErrorInterceptor(),
    ]);
  }

  /// Generic GET request.
  Future<Response> get(String path) => _dio.get(path);

  /// Generic POST request.
  Future<Response> post(String path, {Map<String, dynamic>? data}) =>
      _dio.post(path, data: data);

  /// GET request that extracts and returns a JSON list.
  Future<List<dynamic>> getList(String path) async {
    final response = await _dio.get(path);
    if (response.data is List) {
      return response.data as List<dynamic>;
    }
    throw DioException(
      requestOptions: response.requestOptions,
      message:
          'Expected a JSON list from $path but got ${response.data.runtimeType}',
    );
  }
}

/// Intercepts requests and returns mock JSON data with a simulated delay.
///
/// Routes handled: /announcements, /events, /timetable.
/// All other paths pass through to the network (or fail if offline).
class MockInterceptor extends Interceptor {
  static const _delay = Duration(milliseconds: 500);

  static final _routes = <String, List<Map<String, dynamic>>>{
    '/announcements': mockAnnouncements,
    '/events': mockEvents,
    '/timetable': mockTimetable,
  };

  @override
  Future<void> onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    // Handle POST /auth/login mock.
    if (options.method == 'POST' && options.path == '/auth/login') {
      await Future.delayed(_delay);
      final data = options.data as Map<String, dynamic>?;
      final email = data?['email'] ?? '';
      final password = data?['password'] ?? '';

      if (email == 'student@smartcampus.dev' && password == 'campus123') {
        handler.resolve(
          Response(
            requestOptions: options,
            statusCode: 200,
            data: {
              'token': 'mock_jwt_${DateTime.now().millisecondsSinceEpoch}',
              'email': email,
              'displayName': 'Maxframe',
              'issuedAt': DateTime.now().toIso8601String(),
            },
          ),
        );
      } else {
        handler.reject(
          DioException(
            requestOptions: options,
            response: Response(
              requestOptions: options,
              statusCode: 401,
              data: {'error': 'Invalid credentials'},
            ),
            type: DioExceptionType.badResponse,
          ),
        );
      }
      return;
    }

    final mockData = _routes[options.path];
    if (mockData != null) {
      // Simulate network latency so loading states are visible.
      await Future.delayed(_delay);
      handler.resolve(
        Response(
          requestOptions: options,
          statusCode: 200,
          data: json.decode(json.encode(mockData)),
        ),
      );
      return;
    }
    // Not a mocked route — let the request continue.
    handler.next(options);
  }
}

/// Maps [DioException] types to user-friendly error messages.
class ErrorInterceptor extends Interceptor {
  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    final String message;
    switch (err.type) {
      case DioExceptionType.connectionTimeout:
        message = 'Connection timed out. Please check your internet.';
      case DioExceptionType.receiveTimeout:
        message = 'Server took too long to respond. Try again later.';
      case DioExceptionType.sendTimeout:
        message = 'Request timed out while sending data.';
      case DioExceptionType.connectionError:
        message = 'No internet connection. Please check your network.';
      case DioExceptionType.badResponse:
        message = _mapStatusCode(err.response?.statusCode);
      case DioExceptionType.cancel:
        message = 'Request was cancelled.';
      case DioExceptionType.badCertificate:
        message = 'Security certificate error. Contact support.';
      case DioExceptionType.unknown:
        message = 'An unexpected error occurred. Please try again.';
    }
    handler.next(
      DioException(
        requestOptions: err.requestOptions,
        response: err.response,
        type: err.type,
        error: err.error,
        message: message,
      ),
    );
  }

  String _mapStatusCode(int? code) {
    return switch (code) {
      400 => 'Bad request. Please check your input.',
      401 => 'Unauthorized. Please log in again.',
      403 => 'Access denied.',
      404 => 'Resource not found.',
      500 => 'Server error. Please try again later.',
      _ => 'Request failed (status $code).',
    };
  }
}
