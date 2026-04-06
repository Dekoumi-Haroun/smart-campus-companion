import 'package:dio/dio.dart';

import '../../core/errors/app_exceptions.dart';
import '../../domain/entities/announcement.dart';
import '../../domain/repositories/announcement_repository.dart';
import '../datasources/local/announcement_local_dao.dart';
import '../datasources/remote/api_client.dart';
import '../models/announcement_model.dart';

/// Concrete implementation of [AnnouncementRepository].
///
/// Applies an offline-first strategy: fetch from remote, cache locally,
/// and fall back to cached data when the network is unavailable.
class AnnouncementRepositoryImpl implements AnnouncementRepository {
  final ApiClient _apiClient;
  final AnnouncementLocalDao _localDao;

  AnnouncementRepositoryImpl({
    required ApiClient apiClient,
    required AnnouncementLocalDao localDao,
  }) : _apiClient = apiClient,
       _localDao = localDao;

  @override
  Future<List<Announcement>> getAnnouncements() async {
    try {
      final jsonList = await _apiClient.getList('/announcements');
      final models = jsonList
          .map(
            (json) => AnnouncementModel.fromJson(json as Map<String, dynamic>),
          )
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
  Future<Announcement?> getAnnouncementById(String id) async {
    try {
      final jsonList = await _apiClient.getList('/announcements');
      final models = jsonList
          .map(
            (json) => AnnouncementModel.fromJson(json as Map<String, dynamic>),
          )
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
