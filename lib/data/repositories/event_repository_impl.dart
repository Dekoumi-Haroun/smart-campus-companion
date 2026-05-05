import 'package:dio/dio.dart';

import '../../core/errors/app_exceptions.dart';
import '../../domain/entities/event.dart';
import '../../domain/repositories/event_repository.dart';
import '../datasources/local/event_local_dao.dart';
import '../datasources/remote/api_client.dart';
import '../models/event_model.dart';
import 'settings_repository.dart';

/// Concrete implementation of [EventRepository].
///
/// Read: offline-first (API → cache → cached fallback).
/// Write: optimistic-local (API fire-and-forget → always persist to SQLite).
class EventRepositoryImpl implements EventRepository {
  final ApiClient _apiClient;
  final EventLocalDao _localDao;
  final SettingsRepository? _settingsRepo;

  EventRepositoryImpl({
    required ApiClient apiClient,
    required EventLocalDao localDao,
    SettingsRepository? settingsRepository,
  }) : _apiClient = apiClient,
       _localDao = localDao,
       _settingsRepo = settingsRepository;

  @override
  Future<List<Event>> getEvents() async {
    try {
      final jsonList = await _apiClient.getList('/events');
      final models = jsonList
          .map((json) => EventModel.fromJson(json as Map<String, dynamic>))
          .toList();
      await _localDao.insertAll(models);
      await _settingsRepo?.markSynced();
      // Read back from the DAO so admin-created / admin-edited rows
      // (isLocal = 1) are included alongside the refreshed server rows.
      final merged = await _localDao.getAll();
      return merged.map((m) => m.toEntity()).toList();
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
      await _settingsRepo?.markSynced();
      // Source from cache so admin-only rows are discoverable by id.
      final merged = await _localDao.getAll();
      final match = merged.where((m) => m.id == id).toList();
      return match.isEmpty ? null : match.first.toEntity();
    } on DioException {
      final cached = await _localDao.getAll();
      final match = cached.where((m) => m.id == id).toList();
      return match.isEmpty ? null : match.first.toEntity();
    }
  }

  @override
  Future<Event> createEvent(Event event) async {
    final model = EventModel.fromEntity(event);
    try {
      await _apiClient.post('/events', data: model.toJson());
    } on DioException {
      // Offline — still persist locally.
    }
    await _localDao.insertOne(model);
    return event;
  }

  @override
  Future<Event> updateEvent(Event event) async {
    final model = EventModel.fromEntity(event);
    try {
      await _apiClient.put('/events/${event.id}', data: model.toJson());
    } on DioException {
      // Offline — still update locally.
    }
    await _localDao.updateOne(model);
    return event;
  }

  @override
  Future<void> deleteEvent(String id) async {
    try {
      await _apiClient.delete('/events/$id');
    } on DioException {
      // Offline — still delete locally.
    }
    await _localDao.deleteById(id);
  }
}
