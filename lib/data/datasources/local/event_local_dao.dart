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
      final json = item.toJson();
      // SQLite stores booleans as integers.
      json['isReminded'] = item.isReminded ? 1 : 0;
      batch.insert('events', json);
    }
    await batch.commit(noResult: true);
  }

  /// Returns every cached event.
  Future<List<EventModel>> getAll() async {
    final db = await _localDatabase.database;
    final rows = await db.query('events');
    return rows.map((row) {
      final json = Map<String, dynamic>.from(row);
      // Convert integer back to boolean for the model.
      json['isReminded'] = (json['isReminded'] as int) == 1;
      return EventModel.fromJson(json);
    }).toList();
  }

  /// Deletes all cached events.
  Future<void> clearAll() async {
    final db = await _localDatabase.database;
    await db.delete('events');
  }
}
