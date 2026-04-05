import 'dart:convert';

import 'package:dio/dio.dart';

import '../../core/errors/app_exceptions.dart';
import '../../domain/entities/timetable_item.dart';
import '../../domain/repositories/timetable_repository.dart';
import '../datasources/remote/api_client.dart';
import '../models/timetable_item_model.dart';

/// Concrete implementation of [TimetableRepository].
///
/// Fetches the weekly timetable from the remote API via [ApiClient],
/// converts JSON responses into domain entities, and wraps Dio errors
/// in domain-level [AppException]s.
///
/// Local caching (offline-first fallback) will be added in Sprint 3.
class TimetableRepositoryImpl implements TimetableRepository {
  final ApiClient _apiClient;

  TimetableRepositoryImpl({required ApiClient apiClient})
    : _apiClient = apiClient;

  @override
  Future<List<TimetableItem>> getTimetable() async {
    try {
      final jsonList = await _apiClient.getList('/timetable');
      return jsonList
          .map(
            (json) => TimetableItemModel.fromJson(json as Map<String, dynamic>),
          )
          .map((model) => model.toEntity())
          .toList();
    } on DioException catch (e) {
      throw _mapDioException(e);
    }
  }

  @override
  Future<List<TimetableItem>> getTimetableByDay(int dayOfWeek) async {
    final all = await getTimetable();
    return all.where((item) => item.dayOfWeek == dayOfWeek).toList();
  }

  @override
  Future<String> exportToJson() async {
    try {
      final jsonList = await _apiClient.getList('/timetable');
      final models = jsonList
          .map(
            (json) => TimetableItemModel.fromJson(json as Map<String, dynamic>),
          )
          .toList();
      return json.encode(models.map((m) => m.toJson()).toList());
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
