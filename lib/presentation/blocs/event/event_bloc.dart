import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/errors/app_exceptions.dart';
import '../../../domain/entities/event.dart';
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
    on<AttachPhoto>(_onAttachPhoto);
    on<CreateEvent>(_onCreate);
    on<UpdateEvent>(_onUpdate);
    on<DeleteEvent>(_onDelete);
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
            .where((e) =>
                e.title.toLowerCase().contains(query) ||
                e.description.toLowerCase().contains(query) ||
                e.location.toLowerCase().contains(query))
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
      if (e.id == event.eventId) return e.copyWith(isReminded: !e.isReminded);
      return e;
    }).toList();

    emit(EventLoaded(updatedEvents));
  }

  void _onAttachPhoto(AttachPhoto event, Emitter<EventState> emit) {
    final currentState = state;
    if (currentState is! EventLoaded) return;

    final updatedEvents = currentState.events.map((e) {
      if (e.id == event.eventId) return e.copyWith(photoPath: event.photoPath);
      return e;
    }).toList();

    emit(EventLoaded(updatedEvents));
  }

  // ── Admin CRUD ──────────────────────────────────────────────────

  Future<void> _onCreate(CreateEvent event, Emitter<EventState> emit) async {
    try {
      final created = await _repository.createEvent(event.event);
      emit(EventActionSuccess('Event created', [..._currentList(), created]));
    } on AppException catch (e) {
      emit(EventError(e.message));
    }
  }

  Future<void> _onUpdate(UpdateEvent event, Emitter<EventState> emit) async {
    try {
      final updated = await _repository.updateEvent(event.event);
      final newList = _currentList()
          .map((e) => e.id == updated.id ? updated : e)
          .toList();
      emit(EventActionSuccess('Event updated', newList));
    } on AppException catch (e) {
      emit(EventError(e.message));
    }
  }

  Future<void> _onDelete(DeleteEvent event, Emitter<EventState> emit) async {
    try {
      await _repository.deleteEvent(event.eventId);
      final newList = _currentList()
          .where((e) => e.id != event.eventId)
          .toList();
      emit(EventActionSuccess('Event deleted', newList));
    } on AppException catch (e) {
      emit(EventError(e.message));
    }
  }

  List<Event> _currentList() {
    final s = state;
    return s is EventLoaded ? s.events : [];
  }
}
