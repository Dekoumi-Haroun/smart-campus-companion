import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/errors/app_exceptions.dart';
import '../../../domain/entities/timetable_item.dart';
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
    on<CreateTimetableItem>(_onCreate);
    on<UpdateTimetableItem>(_onUpdate);
    on<DeleteTimetableItem>(_onDelete);
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
    try {
      final filePath = await _repository.exportToJson();
      emit(TimetableExported(filePath));
    } on AppException catch (e) {
      emit(TimetableError(e.message));
    } on Exception {
      emit(const TimetableError('Failed to export schedule.'));
    }
  }

  // ── Admin CRUD ──────────────────────────────────────────────────

  Future<void> _onCreate(
    CreateTimetableItem event,
    Emitter<TimetableState> emit,
  ) async {
    try {
      final created = await _repository.createTimetableItem(event.item);
      emit(TimetableActionSuccess('Class added', [..._currentList(), created]));
    } on AppException catch (e) {
      emit(TimetableError(e.message));
    }
  }

  Future<void> _onUpdate(
    UpdateTimetableItem event,
    Emitter<TimetableState> emit,
  ) async {
    try {
      final updated = await _repository.updateTimetableItem(event.item);
      final newList = _currentList()
          .map((i) => i.id == updated.id ? updated : i)
          .toList();
      emit(TimetableActionSuccess('Class updated', newList));
    } on AppException catch (e) {
      emit(TimetableError(e.message));
    }
  }

  Future<void> _onDelete(
    DeleteTimetableItem event,
    Emitter<TimetableState> emit,
  ) async {
    try {
      await _repository.deleteTimetableItem(event.itemId);
      final newList = _currentList()
          .where((i) => i.id != event.itemId)
          .toList();
      emit(TimetableActionSuccess('Class deleted', newList));
    } on AppException catch (e) {
      emit(TimetableError(e.message));
    }
  }

  List<TimetableItem> _currentList() {
    final s = state;
    return s is TimetableLoaded ? s.items : [];
  }
}
