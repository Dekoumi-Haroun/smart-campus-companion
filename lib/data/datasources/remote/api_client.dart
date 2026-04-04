// Remote data source — handles all REST API communication.
//
// This class will be implemented in Sprint 2 using the `dio` package.
// It will include:
// - Base URL configuration
// - Timeout settings (10s connect, 15s receive)
// - Request/response logging interceptor
// - Error mapping (network errors → domain exceptions)
//
// Endpoints planned:
// - GET /announcements
// - GET /events
// - GET /timetable
//
// For now this is a stub to preserve the folder structure.

// TODO: Sprint 2 — Implement with dio
// class ApiClient {
//   final Dio _dio;
//
//   ApiClient()
//       : _dio = Dio(BaseOptions(
//           baseUrl: 'https://your-api-url.com/api',
//           connectTimeout: const Duration(seconds: 10),
//           receiveTimeout: const Duration(seconds: 15),
//         )) {
//     _dio.interceptors.add(LogInterceptor(responseBody: true));
//   }
// }
