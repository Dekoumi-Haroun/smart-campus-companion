import '../entities/timetable_item.dart';

/// Abstract contract for Timetable data access.
///
/// In addition to standard CRUD, this repository supports
/// JSON export (Sprint 3) for the File I/O requirement.
///
/// Concrete implementation: Sprint 2 (remote) + Sprint 3 (local + export).
abstract class TimetableRepository {
  /// Fetch the full weekly timetable.
  Future<List<TimetableItem>> getTimetable();

  /// Fetch items for a specific day (1 = Monday ... 7 = Sunday).
  Future<List<TimetableItem>> getTimetableByDay(int dayOfWeek);

  /// Export the timetable to a JSON file in the app's documents directory.
  ///
  /// Returns the absolute file path of the exported file.
  Future<String> exportToJson();
}
