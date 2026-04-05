import 'package:equatable/equatable.dart';

sealed class EventEvent extends Equatable {
  const EventEvent();

  @override
  List<Object?> get props => [];
}

/// Load all events from the repository.
class FetchEvents extends EventEvent {
  const FetchEvents();
}

/// Pull-to-refresh — re-fetches and replaces the list.
class RefreshEvents extends EventEvent {
  const RefreshEvents();
}

/// Filter events by search query.
class SearchEvents extends EventEvent {
  final String query;

  const SearchEvents(this.query);

  @override
  List<Object?> get props => [query];
}

/// Toggle the reminder flag for a specific event.
class ToggleReminder extends EventEvent {
  final String eventId;

  const ToggleReminder(this.eventId);

  @override
  List<Object?> get props => [eventId];
}
