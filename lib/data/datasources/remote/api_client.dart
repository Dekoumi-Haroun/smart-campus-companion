import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

import 'mock_data.dart';

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
