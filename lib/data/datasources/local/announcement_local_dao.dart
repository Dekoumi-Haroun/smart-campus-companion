import 'package:sqflite/sqflite.dart';

import '../../models/announcement_model.dart';
import 'local_database.dart';

/// Data Access Object for the `announcements` cache table.
class AnnouncementLocalDao {
  final LocalDatabase _localDatabase;

  AnnouncementLocalDao(this._localDatabase);

  /// Replaces the **server-origin** slice of the cache with [items].
  ///
  /// Rows flagged `isLocal = 1` (admin-created or admin-edited) are
  /// preserved across sync so user work survives app restarts.
  Future<void> insertAll(List<AnnouncementModel> items) async {
    final db = await _localDatabase.database;
    final batch = db.batch();
    batch.delete('announcements', where: 'isLocal = 0');
    for (final item in items) {
      // `ignore` so a server row with the same id as an admin-edited
      // local row (isLocal = 1) does not clobber the local edit.
      batch.insert(
        'announcements',
        _toRow(item, isLocal: false),
        conflictAlgorithm: ConflictAlgorithm.ignore,
      );
    }
    await batch.commit(noResult: true);
  }

  /// Inserts or replaces a single **local** (admin-authored) item.
  Future<void> insertOne(AnnouncementModel item) async {
    final db = await _localDatabase.database;
    await db.insert(
      'announcements',
      _toRow(item, isLocal: true),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  /// Updates an existing item by id, pinning it as local so the next
  /// sync does not overwrite the admin edit.
  Future<void> updateOne(AnnouncementModel item) async {
    final db = await _localDatabase.database;
    await db.update(
      'announcements',
      _toRow(item, isLocal: true),
      where: 'id = ?',
      whereArgs: [item.id],
    );
  }

  /// Deletes a single item by id.
  Future<void> deleteById(String id) async {
    final db = await _localDatabase.database;
    await db.delete('announcements', where: 'id = ?', whereArgs: [id]);
  }

  /// Returns every cached announcement.
  Future<List<AnnouncementModel>> getAll() async {
    final db = await _localDatabase.database;
    final rows = await db.query('announcements');
    return rows.map(_fromRow).toList();
  }

  /// Deletes all cached announcements.
  Future<void> clearAll() async {
    final db = await _localDatabase.database;
    await db.delete('announcements');
  }

  Map<String, dynamic> _toRow(AnnouncementModel item, {required bool isLocal}) {
    final json = item.toJson();
    json['isBookmarked'] = item.isBookmarked ? 1 : 0;
    json['isLocal'] = isLocal ? 1 : 0;
    return json;
  }

  AnnouncementModel _fromRow(Map<String, dynamic> row) {
    final json = Map<String, dynamic>.from(row);
    json['isBookmarked'] = (json['isBookmarked'] as int) == 1;
    // isLocal is a DAO-level concern — strip it before handing back to
    // the model so it stays out of JSON round-trips to the API.
    json.remove('isLocal');
    return AnnouncementModel.fromJson(json);
  }
}
