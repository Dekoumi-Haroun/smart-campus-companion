import 'package:equatable/equatable.dart';

import '../../../domain/entities/event.dart';

sealed class EventEvent extends Equatable {
  const EventEvent();

  @override
  List<Object?> get props => [];
}

class FetchEvents extends EventEvent {
  const FetchEvents();
}

class RefreshEvents extends EventEvent {
  const RefreshEvents();
}

class SearchEvents extends EventEvent {
  final String query;
  const SearchEvents(this.query);

  @override
  List<Object?> get props => [query];
}

class ToggleReminder extends EventEvent {
  final String eventId;
  const ToggleReminder(this.eventId);

  @override
  List<Object?> get props => [eventId];
}

class AttachPhoto extends EventEvent {
  final String eventId;
  final String photoPath;
  const AttachPhoto(this.eventId, this.photoPath);

  @override
  List<Object?> get props => [eventId, photoPath];
}

// ── Admin CRUD ──

class CreateEvent extends EventEvent {
  final Event event;
  const CreateEvent(this.event);

  @override
  List<Object?> get props => [event];
}

class UpdateEvent extends EventEvent {
  final Event event;
  const UpdateEvent(this.event);

  @override
  List<Object?> get props => [event];
}

class DeleteEvent extends EventEvent {
  final String eventId;
  const DeleteEvent(this.eventId);

  @override
  List<Object?> get props => [eventId];
}
