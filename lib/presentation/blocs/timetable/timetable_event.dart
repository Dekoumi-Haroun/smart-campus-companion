import 'package:equatable/equatable.dart';

sealed class TimetableEvent extends Equatable {
  const TimetableEvent();

  @override
  List<Object?> get props => [];
}

/// Load the full weekly timetable.
class FetchTimetable extends TimetableEvent {
  const FetchTimetable();
}

/// Load timetable items for a specific day (1 = Monday … 7 = Sunday).
class FetchTimetableByDay extends TimetableEvent {
  final int day;

  const FetchTimetableByDay(this.day);

  @override
  List<Object?> get props => [day];
}

/// Export the timetable as a JSON string.
class ExportTimetable extends TimetableEvent {
  const ExportTimetable();
}
