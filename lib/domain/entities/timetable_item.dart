/// Core TimetableItem entity — pure Dart, no Flutter dependency.
///
/// Represents a single class/session in the student's weekly timetable.
/// Fields cover what's needed for display, notifications (Sprint 5),
/// and JSON export (Sprint 3).
class TimetableItem {
  final String id;
  final String courseName;
  final String instructor;
  final String room;
  final int dayOfWeek; // 1 = Monday, 7 = Sunday
  final String startTime; // "09:30"
  final String endTime; // "11:00"
  final String status; // "Completed" / "In Progress" / "Upcoming"

  const TimetableItem({
    required this.id,
    required this.courseName,
    required this.instructor,
    required this.room,
    required this.dayOfWeek,
    required this.startTime,
    required this.endTime,
    this.status = 'Upcoming',
  });

  TimetableItem copyWith({
    String? id,
    String? courseName,
    String? instructor,
    String? room,
    int? dayOfWeek,
    String? startTime,
    String? endTime,
    String? status,
  }) {
    return TimetableItem(
      id: id ?? this.id,
      courseName: courseName ?? this.courseName,
      instructor: instructor ?? this.instructor,
      room: room ?? this.room,
      dayOfWeek: dayOfWeek ?? this.dayOfWeek,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      status: status ?? this.status,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TimetableItem &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          courseName == other.courseName &&
          instructor == other.instructor &&
          room == other.room &&
          dayOfWeek == other.dayOfWeek &&
          startTime == other.startTime &&
          endTime == other.endTime &&
          status == other.status;

  @override
  int get hashCode => Object.hash(
    id,
    courseName,
    instructor,
    room,
    dayOfWeek,
    startTime,
    endTime,
    status,
  );
}
