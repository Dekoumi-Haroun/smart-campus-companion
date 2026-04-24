import 'package:equatable/equatable.dart';

import '../../../domain/entities/timetable_item.dart';

sealed class TimetableEvent extends Equatable {
  const TimetableEvent();

  @override
  List<Object?> get props => [];
}

class FetchTimetable extends TimetableEvent {
  const FetchTimetable();
}

class FetchTimetableByDay extends TimetableEvent {
  final int day;
  const FetchTimetableByDay(this.day);

  @override
  List<Object?> get props => [day];
}

class ExportTimetable extends TimetableEvent {
  const ExportTimetable();
}

// ── Admin CRUD ──

class CreateTimetableItem extends TimetableEvent {
  final TimetableItem item;
  const CreateTimetableItem(this.item);

  @override
  List<Object?> get props => [item];
}

class UpdateTimetableItem extends TimetableEvent {
  final TimetableItem item;
  const UpdateTimetableItem(this.item);

  @override
  List<Object?> get props => [item];
}

class DeleteTimetableItem extends TimetableEvent {
  final String itemId;
  const DeleteTimetableItem(this.itemId);

  @override
  List<Object?> get props => [itemId];
}
