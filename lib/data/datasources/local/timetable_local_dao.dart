import 'package:sqflite/sqflite.dart';

import '../../models/timetable_item_model.dart';
import 'local_database.dart';

/// Data Access Object for the `timetable_items` cache table.
class TimetableLocalDao {
  final LocalDatabase _localDatabase;

  TimetableLocalDao(this._localDatabase);

  /// Replaces the **server-origin** slice of the cache with [items].
  ///
  /// Rows flagged `isLocal = 1` (admin-created or admin-edited) are
  /// preserved across sync so user work survives app restarts.
  Future<void> insertAll(List<TimetableItemModel> items) async {
    final db = await _localDatabase.database;
    final batch = db.batch();
    batch.delete('timetable_items', where: 'isLocal = 0');
    for (final item in items) {
      // `ignore` so a server row with the same id as an admin-edited
      // local row (isLocal = 1) does not clobber the local edit.
      batch.insert(
        'timetable_items',
        _toRow(item, isLocal: false),
        conflictAlgorithm: ConflictAlgorithm.ignore,
      );
    }
    await batch.commit(noResult: true);
  }

  /// Inserts or replaces a single **local** (admin-authored) item.
  Future<void> insertOne(TimetableItemModel item) async {
    final db = await _localDatabase.database;
    await db.insert(
      'timetable_items',
      _toRow(item, isLocal: true),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  /// Updates an existing item by id, pinning it as local so the next
  /// sync does not overwrite the admin edit.
  Future<void> updateOne(TimetableItemModel item) async {
    final db = await _localDatabase.database;
    await db.update(
      'timetable_items',
      _toRow(item, isLocal: true),
      where: 'id = ?',
      whereArgs: [item.id],
    );
  }

  /// Deletes a single item by id.
  Future<void> deleteById(String id) async {
    final db = await _localDatabase.database;
    await db.delete('timetable_items', where: 'id = ?', whereArgs: [id]);
  }

  /// Returns every cached timetable item.
  Future<List<TimetableItemModel>> getAll() async {
    final db = await _localDatabase.database;
    final rows = await db.query('timetable_items');
    return rows.map(_fromRow).toList();
  }

  /// Deletes all cached timetable items.
  Future<void> clearAll() async {
    final db = await _localDatabase.database;
    await db.delete('timetable_items');
  }

  Map<String, dynamic> _toRow(
    TimetableItemModel item, {
    required bool isLocal,
  }) {
    final json = item.toJson();
    json['isLocal'] = isLocal ? 1 : 0;
    return json;
  }

  TimetableItemModel _fromRow(Map<String, dynamic> row) {
    final json = Map<String, dynamic>.from(row);
    // isLocal is a DAO-level concern — strip it before handing back to
    // the model so it stays out of JSON round-trips to the API.
    json.remove('isLocal');
    return TimetableItemModel.fromJson(json);
  }
}
