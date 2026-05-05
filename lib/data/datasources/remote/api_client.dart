import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

import 'mock_data.dart';

// ══════════════════════════════════════════════════════════════════
// OWASP Mobile Security Considerations:
// 1. HTTPS Only: BaseOptions uses https:// scheme exclusively.
// 2. No Sensitive Data in Logs: LogInterceptor has requestBody: false.
// 3. No Hardcoded Secrets: API keys stored in FlutterSecureStorage.
// 4. Input Sanitization: validated at the form level before sending.
// 5. Certificate Pinning (concept): add SecurityContext in production.
// ══════════════════════════════════════════════════════════════════

/// Centralized HTTP client for all API communication.
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

  Future<Response> get(String path) => _dio.get(path);

  Future<Response> post(String path, {Map<String, dynamic>? data}) =>
      _dio.post(path, data: data);

  Future<Response> put(String path, {Map<String, dynamic>? data}) =>
      _dio.put(path, data: data);

  Future<Response> delete(String path) => _dio.delete(path);

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
class MockInterceptor extends Interceptor {
  static const _delay = Duration(milliseconds: 500);

  static final _readRoutes = <String, List<Map<String, dynamic>>>{
    '/announcements': mockAnnouncements,
    '/events': mockEvents,
    '/timetable': mockTimetable,
  };

  @override
  Future<void> onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    await Future.delayed(_delay);

    // ── Auth ──────────────────────────────────────────────────────
    if (options.method == 'POST' && options.path == '/auth/login') {
      final data = options.data as Map<String, dynamic>?;
      final email = data?['email'] ?? '';
      final password = data?['password'] ?? '';

      if (email == 'admin@smartcampus.dev' && password == 'admin123') {
        handler.resolve(
          Response(
            requestOptions: options,
            statusCode: 200,
            data: {
              'token':
                  'mock_admin_jwt_${DateTime.now().millisecondsSinceEpoch}',
              'email': email,
              'displayName': 'Campus Admin',
              'issuedAt': DateTime.now().toIso8601String(),
              'isAdmin': true,
            },
          ),
        );
        return;
      }

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
              'isAdmin': false,
            },
          ),
        );
        return;
      }

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
      return;
    }

    // ── Read (GET list) ───────────────────────────────────────────
    final mockList = _readRoutes[options.path];
    if (mockList != null && options.method == 'GET') {
      handler.resolve(
        Response(
          requestOptions: options,
          statusCode: 200,
          data: json.decode(json.encode(mockList)),
        ),
      );
      return;
    }

    // ── Admin Write Operations ────────────────────────────────────
    // POST /announcements, /events, /timetable — create
    if (options.method == 'POST' && _readRoutes.containsKey(options.path)) {
      final body = Map<String, dynamic>.from(
        options.data as Map<String, dynamic>? ?? {},
      );
      body['id'] ??= 'admin_${DateTime.now().millisecondsSinceEpoch}';
      _readRoutes[options.path]!.add(Map<String, dynamic>.from(body));
      handler.resolve(
        Response(requestOptions: options, statusCode: 201, data: body),
      );
      return;
    }

    // PUT /announcements/:id, /events/:id, /timetable/:id — update
    if (options.method == 'PUT') {
      final match = _matchEntityPath(options.path);
      if (match != null) {
        final body = Map<String, dynamic>.from(
          options.data as Map<String, dynamic>? ?? {},
        );
        final list = _readRoutes[match.basePath]!;
        final idx = list.indexWhere((e) => e['id']?.toString() == match.id);
        if (idx != -1) list[idx] = body;
        handler.resolve(
          Response(requestOptions: options, statusCode: 200, data: body),
        );
        return;
      }
    }

    // DELETE /announcements/:id, /events/:id, /timetable/:id — delete
    if (options.method == 'DELETE') {
      final match = _matchEntityPath(options.path);
      if (match != null) {
        _readRoutes[match.basePath]!.removeWhere(
          (e) => e['id']?.toString() == match.id,
        );
        handler.resolve(
          Response(requestOptions: options, statusCode: 204, data: null),
        );
        return;
      }
    }

    handler.next(options);
  }

  /// Parses a path like `/announcements/abc123` into its base route and id.
  ({String basePath, String id})? _matchEntityPath(String path) {
    for (final base in _readRoutes.keys) {
      if (path.startsWith('$base/')) {
        return (basePath: base, id: path.substring(base.length + 1));
      }
    }
    return null;
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
