import 'dart:convert';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:path_provider/path_provider.dart';

import '../../core/errors/app_exceptions.dart';
import '../../domain/entities/timetable_item.dart';
import '../../domain/repositories/timetable_repository.dart';
import '../datasources/local/timetable_local_dao.dart';
import '../datasources/remote/api_client.dart';
import '../models/timetable_item_model.dart';

/// Concrete implementation of [TimetableRepository].
///
/// Applies an offline-first strategy: fetch from remote, cache locally,
/// and fall back to cached data when the network is unavailable.
class TimetableRepositoryImpl implements TimetableRepository {
  final ApiClient _apiClient;
  final TimetableLocalDao _localDao;

  TimetableRepositoryImpl({
    required ApiClient apiClient,
    required TimetableLocalDao localDao,
  }) : _apiClient = apiClient,
       _localDao = localDao;

  @override
  Future<List<TimetableItem>> getTimetable() async {
    try {
      final jsonList = await _apiClient.getList('/timetable');
      final models = jsonList
          .map(
            (json) => TimetableItemModel.fromJson(json as Map<String, dynamic>),
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
  Future<List<TimetableItem>> getTimetableByDay(int dayOfWeek) async {
    final all = await getTimetable();
    return all.where((item) => item.dayOfWeek == dayOfWeek).toList();
  }

  @override
  Future<String> exportToJson() async {
    String jsonString;
    try {
      final jsonList = await _apiClient.getList('/timetable');
      final models = jsonList
          .map(
            (json) => TimetableItemModel.fromJson(json as Map<String, dynamic>),
          )
          .toList();
      await _localDao.insertAll(models);
      jsonString = json.encode(models.map((m) => m.toJson()).toList());
    } on DioException {
      final cached = await _localDao.getAll();
      if (cached.isNotEmpty) {
        jsonString = json.encode(cached.map((m) => m.toJson()).toList());
      } else {
        throw const CacheException();
      }
    }

    final directory = await getApplicationDocumentsDirectory();
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final file = File('${directory.path}/timetable_export_$timestamp.json');
    await file.writeAsString(jsonString);
    return file.path;
  }
}
