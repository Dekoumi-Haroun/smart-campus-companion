import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/errors/app_exceptions.dart';
import '../../../domain/entities/announcement.dart';
import '../../../domain/repositories/announcement_repository.dart';
import 'announcement_event.dart';
import 'announcement_state.dart';

class AnnouncementBloc extends Bloc<AnnouncementEvent, AnnouncementState> {
  final AnnouncementRepository _repository;

  AnnouncementBloc({required AnnouncementRepository repository})
    : _repository = repository,
      super(const AnnouncementInitial()) {
    on<FetchAnnouncements>(_onFetch);
    on<RefreshAnnouncements>(_onRefresh);
    on<FilterByCategory>(_onFilterByCategory);
    on<SearchAnnouncements>(_onSearch);
    on<CreateAnnouncement>(_onCreate);
    on<UpdateAnnouncement>(_onUpdate);
    on<DeleteAnnouncement>(_onDelete);
  }

  Future<void> _onFetch(
    FetchAnnouncements event,
    Emitter<AnnouncementState> emit,
  ) async {
    emit(const AnnouncementLoading());
    try {
      final announcements = await _repository.getAnnouncements();
      emit(AnnouncementLoaded(announcements));
    } on AppException catch (e) {
      emit(AnnouncementError(e.message));
    }
  }

  Future<void> _onRefresh(
    RefreshAnnouncements event,
    Emitter<AnnouncementState> emit,
  ) async {
    try {
      final announcements = await _repository.getAnnouncements();
      emit(AnnouncementLoaded(announcements));
    } on AppException catch (e) {
      emit(AnnouncementError(e.message));
    }
  }

  Future<void> _onFilterByCategory(
    FilterByCategory event,
    Emitter<AnnouncementState> emit,
  ) async {
    emit(const AnnouncementLoading());
    try {
      final all = await _repository.getAnnouncements();
      if (event.category.isEmpty || event.category.toLowerCase() == 'all') {
        emit(AnnouncementLoaded(all));
      } else {
        final filtered = all
            .where((a) =>
                a.category.toLowerCase() == event.category.toLowerCase())
            .toList();
        emit(AnnouncementLoaded(filtered));
      }
    } on AppException catch (e) {
      emit(AnnouncementError(e.message));
    }
  }

  Future<void> _onSearch(
    SearchAnnouncements event,
    Emitter<AnnouncementState> emit,
  ) async {
    emit(const AnnouncementLoading());
    try {
      final all = await _repository.getAnnouncements();
      if (event.query.isEmpty) {
        emit(AnnouncementLoaded(all));
      } else {
        final query = event.query.toLowerCase();
        final filtered = all
            .where((a) =>
                a.title.toLowerCase().contains(query) ||
                a.body.toLowerCase().contains(query))
            .toList();
        emit(AnnouncementLoaded(filtered));
      }
    } on AppException catch (e) {
      emit(AnnouncementError(e.message));
    }
  }

  // ── Admin CRUD ──────────────────────────────────────────────────

  Future<void> _onCreate(
    CreateAnnouncement event,
    Emitter<AnnouncementState> emit,
  ) async {
    try {
      final created = await _repository.createAnnouncement(event.announcement);
      final current = _currentList();
      emit(AnnouncementActionSuccess('Announcement created', [...current, created]));
    } on AppException catch (e) {
      emit(AnnouncementError(e.message));
    }
  }

  Future<void> _onUpdate(
    UpdateAnnouncement event,
    Emitter<AnnouncementState> emit,
  ) async {
    try {
      final updated = await _repository.updateAnnouncement(event.announcement);
      final current = _currentList();
      final newList = current
          .map((a) => a.id == updated.id ? updated : a)
          .toList();
      emit(AnnouncementActionSuccess('Announcement updated', newList));
    } on AppException catch (e) {
      emit(AnnouncementError(e.message));
    }
  }

  Future<void> _onDelete(
    DeleteAnnouncement event,
    Emitter<AnnouncementState> emit,
  ) async {
    try {
      await _repository.deleteAnnouncement(event.announcementId);
      final newList = _currentList()
          .where((a) => a.id != event.announcementId)
          .toList();
      emit(AnnouncementActionSuccess('Announcement deleted', newList));
    } on AppException catch (e) {
      emit(AnnouncementError(e.message));
    }
  }

  List<Announcement> _currentList() {
    final s = state;
    return s is AnnouncementLoaded ? s.announcements : [];
  }
}
