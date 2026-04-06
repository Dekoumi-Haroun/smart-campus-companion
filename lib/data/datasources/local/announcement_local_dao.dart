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
      final json = item.toJson();
      // SQLite stores booleans as integers.
      json['isBookmarked'] = item.isBookmarked ? 1 : 0;
      batch.insert('announcements', json);
    }
    await batch.commit(noResult: true);
  }

  /// Returns every cached announcement.
  Future<List<AnnouncementModel>> getAll() async {
    final db = await _localDatabase.database;
    final rows = await db.query('announcements');
    return rows.map((row) {
      final json = Map<String, dynamic>.from(row);
      // Convert integer back to boolean for the model.
      json['isBookmarked'] = (json['isBookmarked'] as int) == 1;
      return AnnouncementModel.fromJson(json);
    }).toList();
  }

  /// Deletes all cached announcements.
  Future<void> clearAll() async {
    final db = await _localDatabase.database;
    await db.delete('announcements');
  }
}
