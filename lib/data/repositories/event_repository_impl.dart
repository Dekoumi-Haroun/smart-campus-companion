import 'package:dio/dio.dart';

import '../../core/errors/app_exceptions.dart';
import '../../domain/entities/event.dart';
import '../../domain/repositories/event_repository.dart';
import '../datasources/remote/api_client.dart';
import '../models/event_model.dart';

/// Concrete implementation of [EventRepository].
///
/// Fetches events from the remote API via [ApiClient], converts JSON
/// responses into domain entities, and wraps Dio errors in domain-level
/// [AppException]s.
///
/// Local caching (offline-first fallback) will be added in Sprint 3.
class EventRepositoryImpl implements EventRepository {
  final ApiClient _apiClient;

  EventRepositoryImpl({required ApiClient apiClient}) : _apiClient = apiClient;

  @override
  Future<List<Event>> getEvents() async {
    try {
      final jsonList = await _apiClient.getList('/events');
      return jsonList
          .map((json) => EventModel.fromJson(json as Map<String, dynamic>))
          .map((model) => model.toEntity())
          .toList();
    } on DioException catch (e) {
      throw _mapDioException(e);
    }
  }

  @override
  Future<Event?> getEventById(String id) async {
    try {
      final jsonList = await _apiClient.getList('/events');
      final match = jsonList
          .map((json) => EventModel.fromJson(json as Map<String, dynamic>))
          .where((model) => model.id == id)
          .toList();
      return match.isEmpty ? null : match.first.toEntity();
    } on DioException catch (e) {
      throw _mapDioException(e);
    }
  }

  AppException _mapDioException(DioException e) {
    if (e.type == DioExceptionType.connectionTimeout ||
        e.type == DioExceptionType.connectionError ||
        e.type == DioExceptionType.sendTimeout ||
        e.type == DioExceptionType.receiveTimeout) {
      return const NetworkException();
    }
    return ServerException(
      e.message ?? 'Something went wrong on our end. Please try again later.',
      e.response?.statusCode,
    );
  }
}
