import 'package:dio/dio.dart';

import '../../core/errors/app_exceptions.dart';
import '../../domain/entities/announcement.dart';
import '../../domain/repositories/announcement_repository.dart';
import '../datasources/local/announcement_local_dao.dart';
import '../datasources/remote/api_client.dart';
import '../models/announcement_model.dart';
import 'settings_repository.dart';

/// Concrete implementation of [AnnouncementRepository].
///
/// Read: offline-first (API → cache → cached fallback).
/// Write: optimistic-local (API fire-and-forget → always persist to SQLite).
class AnnouncementRepositoryImpl implements AnnouncementRepository {
  final ApiClient _apiClient;
  final AnnouncementLocalDao _localDao;
  final SettingsRepository? _settingsRepo;

  AnnouncementRepositoryImpl({
    required ApiClient apiClient,
    required AnnouncementLocalDao localDao,
    SettingsRepository? settingsRepository,
  }) : _apiClient = apiClient,
       _localDao = localDao,
       _settingsRepo = settingsRepository;

  @override
  Future<List<Announcement>> getAnnouncements() async {
    try {
      final jsonList = await _apiClient.getList('/announcements');
      final models = jsonList
          .map((json) => AnnouncementModel.fromJson(json as Map<String, dynamic>))
          .toList();
      await _localDao.insertAll(models);
      await _settingsRepo?.markSynced();
      return models.map((m) => m.toEntity()).toList();
    } on DioException {
      final cached = await _localDao.getAll();
      if (cached.isNotEmpty) return cached.map((m) => m.toEntity()).toList();
      throw const CacheException();
    }
  }

  @override
  Future<Announcement?> getAnnouncementById(String id) async {
    try {
      final jsonList = await _apiClient.getList('/announcements');
      final models = jsonList
          .map((json) => AnnouncementModel.fromJson(json as Map<String, dynamic>))
          .toList();
      await _localDao.insertAll(models);
      await _settingsRepo?.markSynced();
      final match = models.where((m) => m.id == id).toList();
      return match.isEmpty ? null : match.first.toEntity();
    } on DioException {
      final cached = await _localDao.getAll();
      final match = cached.where((m) => m.id == id).toList();
      return match.isEmpty ? null : match.first.toEntity();
    }
  }

  @override
  Future<Announcement> createAnnouncement(Announcement announcement) async {
    final model = AnnouncementModel.fromEntity(announcement);
    // Fire-and-forget to the API; always persist locally.
    try {
      await _apiClient.post('/announcements', data: model.toJson());
    } on DioException {
      // Offline — still persist locally.
    }
    await _localDao.insertOne(model);
    return announcement;
  }

  @override
  Future<Announcement> updateAnnouncement(Announcement announcement) async {
    final model = AnnouncementModel.fromEntity(announcement);
    try {
      await _apiClient.put(
        '/announcements/${announcement.id}',
        data: model.toJson(),
      );
    } on DioException {
      // Offline — still update locally.
    }
    await _localDao.updateOne(model);
    return announcement;
  }

  @override
  Future<void> deleteAnnouncement(String id) async {
    try {
      await _apiClient.delete('/announcements/$id');
    } on DioException {
      // Offline — still delete locally.
    }
    await _localDao.deleteById(id);
  }
}
