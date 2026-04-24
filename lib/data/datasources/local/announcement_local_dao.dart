import 'package:sqflite/sqflite.dart';

import '../../models/announcement_model.dart';
import 'local_database.dart';

/// Data Access Object for the `announcements` cache table.
class AnnouncementLocalDao {
  final LocalDatabase _localDatabase;

  AnnouncementLocalDao(this._localDatabase);

  /// Replaces the entire cache with [items].
  Future<void> insertAll(List<AnnouncementModel> items) async {
    final db = await _localDatabase.database;
    final batch = db.batch();
    batch.delete('announcements');
    for (final item in items) {
      batch.insert('announcements', _toRow(item));
    }
    await batch.commit(noResult: true);
  }

  /// Inserts or replaces a single item.
  Future<void> insertOne(AnnouncementModel item) async {
    final db = await _localDatabase.database;
    await db.insert(
      'announcements',
      _toRow(item),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  /// Updates an existing item by id.
  Future<void> updateOne(AnnouncementModel item) async {
    final db = await _localDatabase.database;
    await db.update(
      'announcements',
      _toRow(item),
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

  Map<String, dynamic> _toRow(AnnouncementModel item) {
    final json = item.toJson();
    json['isBookmarked'] = item.isBookmarked ? 1 : 0;
    return json;
  }

  AnnouncementModel _fromRow(Map<String, dynamic> row) {
    final json = Map<String, dynamic>.from(row);
    json['isBookmarked'] = (json['isBookmarked'] as int) == 1;
    return AnnouncementModel.fromJson(json);
  }
}
