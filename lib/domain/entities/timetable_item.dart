/// Core TimetableItem entity — pure Dart, no Flutter dependency.
///
/// Represents a single class/session in the student's weekly timetable.
/// Fields cover what's needed for display, notifications (Sprint 5),
/// and JSON export (Sprint 3).
///
/// Implementation will be completed in Sprint 2 (Networking).
class TimetableItem {
  final String id;
  final String courseName;
  final String instructor;
  final String room;
  final int dayOfWeek; // 1 = Monday, 7 = Sunday
  final String startTime; // "09:30"
  final String endTime; // "11:00"

  const TimetableItem({
    required this.id,
    required this.courseName,
    required this.instructor,
    required this.room,
    required this.dayOfWeek,
    required this.startTime,
    required this.endTime,
  });
}
