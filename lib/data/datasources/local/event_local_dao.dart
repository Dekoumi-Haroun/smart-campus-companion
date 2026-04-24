import 'package:sqflite/sqflite.dart';

import '../../models/event_model.dart';
import 'local_database.dart';

/// Data Access Object for the `events` cache table.
class EventLocalDao {
  final LocalDatabase _localDatabase;

  EventLocalDao(this._localDatabase);

  /// Replaces the entire cache with [items].
  Future<void> insertAll(List<EventModel> items) async {
    final db = await _localDatabase.database;
    final batch = db.batch();
    batch.delete('events');
    for (final item in items) {
      batch.insert('events', _toRow(item));
    }
    await batch.commit(noResult: true);
  }

  /// Inserts or replaces a single item.
  Future<void> insertOne(EventModel item) async {
    final db = await _localDatabase.database;
    await db.insert(
      'events',
      _toRow(item),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  /// Updates an existing item by id.
  Future<void> updateOne(EventModel item) async {
    final db = await _localDatabase.database;
    await db.update(
      'events',
      _toRow(item),
      where: 'id = ?',
      whereArgs: [item.id],
    );
  }

  /// Deletes a single item by id.
  Future<void> deleteById(String id) async {
    final db = await _localDatabase.database;
    await db.delete('events', where: 'id = ?', whereArgs: [id]);
  }

  /// Returns every cached event.
  Future<List<EventModel>> getAll() async {
    final db = await _localDatabase.database;
    final rows = await db.query('events');
    return rows.map(_fromRow).toList();
  }

  /// Deletes all cached events.
  Future<void> clearAll() async {
    final db = await _localDatabase.database;
    await db.delete('events');
  }

  Map<String, dynamic> _toRow(EventModel item) {
    final json = item.toJson();
    json['isReminded'] = item.isReminded ? 1 : 0;
    return json;
  }

  EventModel _fromRow(Map<String, dynamic> row) {
    final json = Map<String, dynamic>.from(row);
    json['isReminded'] = (json['isReminded'] as int) == 1;
    return EventModel.fromJson(json);
  }
}
