import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/errors/app_exceptions.dart';
import '../../../domain/repositories/event_repository.dart';
import 'event_event.dart';
import 'event_state.dart';

class EventBloc extends Bloc<EventEvent, EventState> {
  final EventRepository _repository;

  EventBloc({required EventRepository repository})
    : _repository = repository,
      super(const EventInitial()) {
    on<FetchEvents>(_onFetch);
    on<RefreshEvents>(_onRefresh);
    on<SearchEvents>(_onSearch);
    on<ToggleReminder>(_onToggleReminder);
  }

  Future<void> _onFetch(FetchEvents event, Emitter<EventState> emit) async {
    emit(const EventLoading());
    try {
      final events = await _repository.getEvents();
      emit(EventLoaded(events));
    } on AppException catch (e) {
      emit(EventError(e.message));
    }
  }

  Future<void> _onRefresh(RefreshEvents event, Emitter<EventState> emit) async {
    try {
      final events = await _repository.getEvents();
      emit(EventLoaded(events));
    } on AppException catch (e) {
      emit(EventError(e.message));
    }
  }

  Future<void> _onSearch(SearchEvents event, Emitter<EventState> emit) async {
    emit(const EventLoading());
    try {
      final all = await _repository.getEvents();
      if (event.query.isEmpty) {
        emit(EventLoaded(all));
      } else {
        final query = event.query.toLowerCase();
        final filtered = all
            .where(
              (e) =>
                  e.title.toLowerCase().contains(query) ||
                  e.description.toLowerCase().contains(query) ||
                  e.location.toLowerCase().contains(query),
            )
            .toList();
        emit(EventLoaded(filtered));
      }
    } on AppException catch (e) {
      emit(EventError(e.message));
    }
  }

  Future<void> _onToggleReminder(
    ToggleReminder event,
    Emitter<EventState> emit,
  ) async {
    final currentState = state;
    if (currentState is! EventLoaded) return;

    final updatedEvents = currentState.events.map((e) {
      if (e.id == event.eventId) {
        return e.copyWith(isReminded: !e.isReminded);
      }
      return e;
    }).toList();

    emit(EventLoaded(updatedEvents));
  }
}
