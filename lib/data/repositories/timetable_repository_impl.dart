import 'dart:io';

import 'package:dio/dio.dart';
import 'package:path_provider/path_provider.dart';

import '../../core/errors/app_exceptions.dart';
import '../../domain/entities/timetable_item.dart';
import '../../domain/repositories/timetable_repository.dart';
import '../datasources/local/timetable_local_dao.dart';
import '../datasources/remote/api_client.dart';
import '../models/timetable_item_model.dart';
import 'settings_repository.dart';

/// Concrete implementation of [TimetableRepository].
///
/// Read: offline-first (API → cache → cached fallback).
/// Write: optimistic-local (API fire-and-forget → always persist to SQLite).
class TimetableRepositoryImpl implements TimetableRepository {
  final ApiClient _apiClient;
  final TimetableLocalDao _localDao;
  final SettingsRepository? _settingsRepo;

  TimetableRepositoryImpl({
    required ApiClient apiClient,
    required TimetableLocalDao localDao,
    SettingsRepository? settingsRepository,
  }) : _apiClient = apiClient,
       _localDao = localDao,
       _settingsRepo = settingsRepository;

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
  Future<List<TimetableItem>> getTimetableByDay(int dayOfWeek) async {
    final all = await getTimetable();
    return all.where((item) => item.dayOfWeek == dayOfWeek).toList();
  }

  @override
  Future<String> exportToJson() async {
    List<TimetableItem> items;

    try {
      final jsonList = await _apiClient.getList('/timetable');
      final models = jsonList
          .map(
            (json) => TimetableItemModel.fromJson(json as Map<String, dynamic>),
          )
          .toList();
      await _localDao.insertAll(models);
      // Export the merged view so admin-authored items are included.
      final merged = await _localDao.getAll();
      items = merged.map((m) => m.toEntity()).toList();
    } on DioException {
      final cached = await _localDao.getAll();
      if (cached.isEmpty) throw const CacheException();
      items = cached.map((m) => m.toEntity()).toList();
    }

    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final filename = 'timetable_export_$timestamp.txt';
    final payload = _formatSchedule(items);

    for (final candidate in await _exportCandidates(filename)) {
      try {
        await candidate.parent.create(recursive: true);
        await candidate.writeAsString(payload, flush: true);
        return candidate.path;
      } on FileSystemException {
        continue;
      }
    }
    throw const CacheException();
  }

  String _formatSchedule(List<TimetableItem> items) {
    const dayNames = [
      'Monday',
      'Tuesday',
      'Wednesday',
      'Thursday',
      'Friday',
      'Saturday',
      'Sunday',
    ];
    final now = DateTime.now();
    final exportedAt =
        '${now.year}-${_pad2(now.month)}-${_pad2(now.day)} '
        '${_pad2(now.hour)}:${_pad2(now.minute)}';

    final buffer = StringBuffer()
      ..writeln('My Class Schedule')
      ..writeln('Exported: $exportedAt')
      ..writeln('Total classes: ${items.length}')
      ..writeln();

    if (items.isEmpty) {
      buffer.writeln('(no classes scheduled)');
      return buffer.toString();
    }

    final byDay = <int, List<TimetableItem>>{};
    for (final item in items) {
      byDay.putIfAbsent(item.dayOfWeek, () => []).add(item);
    }
    for (final list in byDay.values) {
      list.sort((a, b) => a.startTime.compareTo(b.startTime));
    }

    for (var day = 1; day <= 7; day++) {
      final dayItems = byDay[day];
      if (dayItems == null || dayItems.isEmpty) continue;
      buffer
        ..writeln('========== ${dayNames[day - 1].toUpperCase()} ==========')
        ..writeln();
      for (final item in dayItems) {
        buffer
          ..writeln('${item.startTime} - ${item.endTime}   ${item.courseName}')
          ..writeln('  Instructor: ${item.instructor}')
          ..writeln('  Room: ${item.room}')
          ..writeln('  Status: ${item.status}')
          ..writeln();
      }
    }

    return buffer.toString();
  }

  String _pad2(int n) => n.toString().padLeft(2, '0');

  Future<List<File>> _exportCandidates(String filename) async {
    final paths = <File>[];
    if (Platform.isAndroid) {
      // Public Downloads folder — visible in the device Files app.
      paths.add(File('/storage/emulated/0/Download/$filename'));
      // App-specific external dir (Android/data/<pkg>/files) — no permission required.
      final external = await getExternalStorageDirectory();
      if (external != null) paths.add(File('${external.path}/$filename'));
    } else {
      final downloads = await getDownloadsDirectory();
      if (downloads != null) paths.add(File('${downloads.path}/$filename'));
    }
    // Always-writable fallback; persistent and shareable via share_plus.
    final docs = await getApplicationDocumentsDirectory();
    paths.add(File('${docs.path}/$filename'));
    return paths;
  }

  @override
  Future<TimetableItem> createTimetableItem(TimetableItem item) async {
    final model = TimetableItemModel.fromEntity(item);
    try {
      await _apiClient.post('/timetable', data: model.toJson());
    } on DioException {
      // Offline — still persist locally.
    }
    await _localDao.insertOne(model);
    return item;
  }

  @override
  Future<TimetableItem> updateTimetableItem(TimetableItem item) async {
    final model = TimetableItemModel.fromEntity(item);
    try {
      await _apiClient.put('/timetable/${item.id}', data: model.toJson());
    } on DioException {
      // Offline — still update locally.
    }
    await _localDao.updateOne(model);
    return item;
  }

  @override
  Future<void> deleteTimetableItem(String id) async {
    try {
      await _apiClient.delete('/timetable/$id');
    } on DioException {
      // Offline — still delete locally.
    }
    await _localDao.deleteById(id);
  }
}
