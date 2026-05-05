import 'dart:io';

import '../../data/datasources/local/local_database.dart';
import '../../data/repositories/settings_repository.dart';

/// Per-category breakdown of cached data sizes, in bytes.
///
/// Sizes are *approximations* — SQLite stores pages, not individual
/// rows, so we sum text column lengths as a cheap proxy. That is good
/// enough for a user-facing "9.0 MB of cached data" display and does
/// not require an auxiliary table or VACUUM to stay accurate.
class CacheBreakdown {
  final int announcementsBytes;
  final int eventsBytes;
  final int timetableBytes;
  final int imagesBytes;
  final DateTime? lastSynced;

  const CacheBreakdown({
    required this.announcementsBytes,
    required this.eventsBytes,
    required this.timetableBytes,
    required this.imagesBytes,
    required this.lastSynced,
  });

  int get totalBytes =>
      announcementsBytes + eventsBytes + timetableBytes + imagesBytes;

  const CacheBreakdown.empty()
    : announcementsBytes = 0,
      eventsBytes = 0,
      timetableBytes = 0,
      imagesBytes = 0,
      lastSynced = null;
}

/// Computes cache sizes and clears cached data.
///
/// The service is stateless — all reads go to SQLite and the filesystem
/// on each call, which keeps the UI honest (no stale numbers after a
/// clear) and trivially testable with an in-memory [LocalDatabase].
class CacheMetricsService {
  final LocalDatabase _db;
  final SettingsRepository _settings;

  /// File paths of photos that should be included in the "Images" bucket
  /// and removed on [clearAll]. The settings screen feeds this in from
  /// the current [EventBloc] state so the service doesn't need its own
  /// view of domain data.
  final List<String> Function() _photoPathsProvider;

  CacheMetricsService({
    LocalDatabase? database,
    required SettingsRepository settings,
    required List<String> Function() photoPathsProvider,
  }) : _db = database ?? LocalDatabase.instance,
       _settings = settings,
       _photoPathsProvider = photoPathsProvider;

  Future<CacheBreakdown> compute() async {
    final db = await _db.database;

    // Text-column byte sums per table. LENGTH() on a BLOB would return
    // bytes, on TEXT it returns characters — our columns are all TEXT,
    // so the ASCII-dominated mock data is effectively 1 char = 1 byte.
    Future<int> bytesFor(String sql) async {
      final rows = await db.rawQuery(sql);
      final v = rows.isEmpty ? null : rows.first.values.first;
      return (v as int?) ?? 0;
    }

    final announcementsBytes = await bytesFor('''
      SELECT COALESCE(SUM(
        LENGTH(IFNULL(id,'')) + LENGTH(IFNULL(title,'')) +
        LENGTH(IFNULL(body,'')) + LENGTH(IFNULL(category,'')) +
        LENGTH(IFNULL(summary,'')) + LENGTH(IFNULL(source,'')) +
        LENGTH(IFNULL(date,''))
      ), 0) FROM announcements
    ''');

    final eventsBytes = await bytesFor('''
      SELECT COALESCE(SUM(
        LENGTH(IFNULL(id,'')) + LENGTH(IFNULL(title,'')) +
        LENGTH(IFNULL(description,'')) + LENGTH(IFNULL(location,'')) +
        LENGTH(IFNULL(dateTime,'')) + LENGTH(IFNULL(imageUrl,'')) +
        LENGTH(IFNULL(endTime,'')) + LENGTH(IFNULL(category,''))
      ), 0) FROM events
    ''');

    final timetableBytes = await bytesFor('''
      SELECT COALESCE(SUM(
        LENGTH(IFNULL(id,'')) + LENGTH(IFNULL(courseName,'')) +
        LENGTH(IFNULL(instructor,'')) + LENGTH(IFNULL(room,'')) +
        LENGTH(IFNULL(startTime,'')) + LENGTH(IFNULL(endTime,'')) +
        LENGTH(IFNULL(status,''))
      ), 0) FROM timetable_items
    ''');

    // Attached photos live outside the DB; sum file sizes directly.
    int imagesBytes = 0;
    for (final path in _photoPathsProvider()) {
      try {
        final file = File(path);
        if (await file.exists()) {
          imagesBytes += await file.length();
        }
      } catch (_) {
        // Unreadable file — ignore, don't fail the metrics read.
      }
    }

    return CacheBreakdown(
      announcementsBytes: announcementsBytes,
      eventsBytes: eventsBytes,
      timetableBytes: timetableBytes,
      imagesBytes: imagesBytes,
      lastSynced: _settings.getLastSynced(),
    );
  }

  /// Deletes every cached row and every attached photo file, then clears
  /// the last-sync stamp. Callers should refetch their data afterwards.
  Future<void> clearAll() async {
    final db = await _db.database;
    await db.delete('announcements');
    await db.delete('events');
    await db.delete('timetable_items');

    for (final path in _photoPathsProvider()) {
      try {
        final file = File(path);
        if (await file.exists()) await file.delete();
      } catch (_) {
        // Best-effort — a locked file should not abort the whole clear.
      }
    }

    await _settings.clearLastSynced();
  }
}

/// Human-readable size formatter. Uses binary multiples (KiB/MiB) but
/// labels them as KB/MB to match what users see elsewhere in the app.
String formatBytes(int bytes) {
  if (bytes <= 0) return '0 KB';
  const kb = 1024;
  const mb = kb * 1024;
  if (bytes < kb) return '$bytes B';
  if (bytes < mb) return '${(bytes / kb).toStringAsFixed(1)} KB';
  return '${(bytes / mb).toStringAsFixed(1)} MB';
}

/// "Just now" / "5 min ago" / "2 h ago" / "Apr 10, 14:32".
String formatRelativeTime(DateTime? when, {DateTime? now}) {
  if (when == null) return 'Never synced';
  final current = now ?? DateTime.now();
  final diff = current.difference(when);
  if (diff.inSeconds < 30) return 'Just now';
  if (diff.inMinutes < 1) return '${diff.inSeconds} sec ago';
  if (diff.inMinutes < 60) return '${diff.inMinutes} min ago';
  if (diff.inHours < 24) return '${diff.inHours} h ago';
  if (diff.inDays < 7) return '${diff.inDays} d ago';
  final mm = when.month.toString().padLeft(2, '0');
  final dd = when.day.toString().padLeft(2, '0');
  final hh = when.hour.toString().padLeft(2, '0');
  final mi = when.minute.toString().padLeft(2, '0');
  return '$mm-$dd $hh:$mi';
}
