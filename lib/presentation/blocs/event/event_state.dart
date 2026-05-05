import 'package:equatable/equatable.dart';

import '../../../domain/entities/event.dart';

sealed class EventState extends Equatable {
  const EventState();

  @override
  List<Object?> get props => [];
}

class EventInitial extends EventState {
  const EventInitial();
}

class EventLoading extends EventState {
  const EventLoading();
}

class EventLoaded extends EventState {
  final List<Event> events;

  const EventLoaded(this.events);

  @override
  List<Object?> get props => [events];
}

class EventError extends EventState {
  final String message;

  const EventError(this.message);

  @override
  List<Object?> get props => [message];
}

/// Emitted after a successful admin CRUD operation.
///
/// Extends [EventLoaded] so existing [BlocBuilder] checks continue to work.
class EventActionSuccess extends EventLoaded {
  final String actionMessage;

  const EventActionSuccess(this.actionMessage, List<Event> events)
    : super(events);

  @override
  List<Object?> get props => [actionMessage, events];
}
