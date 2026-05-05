import '../entities/timetable_item.dart';

abstract class TimetableRepository {
  Future<List<TimetableItem>> getTimetable();
  Future<List<TimetableItem>> getTimetableByDay(int dayOfWeek);
  Future<String> exportToJson();

  // ── Admin CRUD ──
  Future<TimetableItem> createTimetableItem(TimetableItem item);
  Future<TimetableItem> updateTimetableItem(TimetableItem item);
  Future<void> deleteTimetableItem(String id);
}
