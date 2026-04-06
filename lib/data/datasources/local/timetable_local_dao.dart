import '../../models/timetable_item_model.dart';
import 'local_database.dart';

/// Data Access Object for the `timetable_items` cache table.
class TimetableLocalDao {
  final LocalDatabase _localDatabase;

  TimetableLocalDao(this._localDatabase);

  /// Replaces the entire cache with [items].
  Future<void> insertAll(List<TimetableItemModel> items) async {
    final db = await _localDatabase.database;
    final batch = db.batch();
    batch.delete('timetable_items');
    for (final item in items) {
      batch.insert('timetable_items', item.toJson());
    }
    await batch.commit(noResult: true);
  }

  /// Returns every cached timetable item.
  Future<List<TimetableItemModel>> getAll() async {
    final db = await _localDatabase.database;
    final rows = await db.query('timetable_items');
    return rows.map(TimetableItemModel.fromJson).toList();
  }

  /// Deletes all cached timetable items.
  Future<void> clearAll() async {
    final db = await _localDatabase.database;
    await db.delete('timetable_items');
  }
}
