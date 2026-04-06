import 'package:dio/dio.dart';

import '../../core/errors/app_exceptions.dart';
import '../../domain/entities/event.dart';
import '../../domain/repositories/event_repository.dart';
import '../datasources/local/event_local_dao.dart';
import '../datasources/remote/api_client.dart';
import '../models/event_model.dart';

/// Concrete implementation of [EventRepository].
///
/// Applies an offline-first strategy: fetch from remote, cache locally,
/// and fall back to cached data when the network is unavailable.
class EventRepositoryImpl implements EventRepository {
  final ApiClient _apiClient;
  final EventLocalDao _localDao;

  EventRepositoryImpl({
    required ApiClient apiClient,
    required EventLocalDao localDao,
  }) : _apiClient = apiClient,
       _localDao = localDao;

  @override
  Future<List<Event>> getEvents() async {
    try {
      final jsonList = await _apiClient.getList('/events');
      final models = jsonList
          .map((json) => EventModel.fromJson(json as Map<String, dynamic>))
          .toList();
      await _localDao.insertAll(models);
      return models.map((m) => m.toEntity()).toList();
    } on DioException {
      final cached = await _localDao.getAll();
      if (cached.isNotEmpty) return cached.map((m) => m.toEntity()).toList();
      throw const CacheException();
    }
  }

  @override
  Future<Event?> getEventById(String id) async {
    try {
      final jsonList = await _apiClient.getList('/events');
      final models = jsonList
          .map((json) => EventModel.fromJson(json as Map<String, dynamic>))
          .toList();
      await _localDao.insertAll(models);
      final match = models.where((m) => m.id == id).toList();
      return match.isEmpty ? null : match.first.toEntity();
    } on DioException {
      final cached = await _localDao.getAll();
      final match = cached.where((m) => m.id == id).toList();
      return match.isEmpty ? null : match.first.toEntity();
    }
  }
}
