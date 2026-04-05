import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/errors/app_exceptions.dart';
import '../../../domain/repositories/timetable_repository.dart';
import 'timetable_event.dart';
import 'timetable_state.dart';

class TimetableBloc extends Bloc<TimetableEvent, TimetableState> {
  final TimetableRepository _repository;

  TimetableBloc({required TimetableRepository repository})
    : _repository = repository,
      super(const TimetableInitial()) {
    on<FetchTimetable>(_onFetch);
    on<FetchTimetableByDay>(_onFetchByDay);
    on<ExportTimetable>(_onExport);
  }

  Future<void> _onFetch(
    FetchTimetable event,
    Emitter<TimetableState> emit,
  ) async {
    emit(const TimetableLoading());
    try {
      final items = await _repository.getTimetable();
      emit(TimetableLoaded(items));
    } on AppException catch (e) {
      emit(TimetableError(e.message));
    }
  }

  Future<void> _onFetchByDay(
    FetchTimetableByDay event,
    Emitter<TimetableState> emit,
  ) async {
    emit(const TimetableLoading());
    try {
      final items = await _repository.getTimetableByDay(event.day);
      emit(TimetableLoaded(items));
    } on AppException catch (e) {
      emit(TimetableError(e.message));
    }
  }

  Future<void> _onExport(
    ExportTimetable event,
    Emitter<TimetableState> emit,
  ) async {
    // Export doesn't change the displayed list — it just triggers the export.
    // The JSON string could be passed via a separate mechanism (e.g. a callback
    // or a dedicated export state), but for now we re-emit the current loaded
    // state after exporting so the UI knows the operation completed.
    try {
      await _repository.exportToJson();
      // Re-emit current state unchanged; UI can show a success snackbar.
      if (state is TimetableLoaded) {
        final current = state as TimetableLoaded;
        emit(TimetableLoaded(List.of(current.items)));
      }
    } on AppException catch (e) {
      emit(TimetableError(e.message));
    }
  }
}
